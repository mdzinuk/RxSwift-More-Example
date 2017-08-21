//
//  PhotosViewController.swift
//  RxPhotoViewer
//
//  Created by Md. Arafat Hossain zinuk on 7/16/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "PhotoCellIdentifer"

class RxPhotoCollectionViewController: UICollectionViewController {

    let bag = DisposeBag()

    // MARK: private properties
    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    private lazy var photos = RxPhotoCollectionViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Authorize PHPhotoLibrary with custom Observable
        let authorized = PHPhotoLibrary.authorized.share()
        
        authorized
            .skipWhile { $0 == false } // skip the photo transform untill the authrozation
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.photos = RxPhotoCollectionViewController.loadPhotos()
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            })
            .disposed(by: bag)
        
        authorized
            .skip(1) // If user unauthorize library access for first time
            .takeLast(1) // Take the latest unauthorization
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage)
            })
            .disposed(by: bag)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell

        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            if(cell.representedAssetIdentifier == asset.localIdentifier) {
                cell.thumb.image = image
            }
        })
        return cell
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // mark signal to finish emition
        selectedPhotosSubject.onCompleted()
    }
    
    
    // MARK: UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?.selectedPhotosSubject.onNext(image)
            }
        })
    }
    
    private func errorMessage() {
        // Error message show in mainThread
        showAlert("No access to Camera Roll", description: "You can grant access to RxPhotoViewer from the Settings app")
            .take(5.0, scheduler: MainScheduler.instance)
            .subscribe(onDisposed: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }

}


class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var thumb: UIImageView!
    
    
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //imageView.image = nil
    }
    
    func flash() {
        thumb.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.thumb.alpha = 1
        })
    }
}
