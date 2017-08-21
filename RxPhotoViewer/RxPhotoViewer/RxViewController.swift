//
//  RxViewController.swift
//  RxPhotoViewer
//
//  Created by Md. Arafat Hossain zinuk on 7/16/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import UIKit
import RxSwift

class RxViewController: UIViewController {
    /*
     To create tidy dispose we'll use disposeBag othewise we've to put subscrib.dispose() in everywhere.
    */
    private let disposeBag = DisposeBag() // Terminate the subscription so that it would not emit anything.
    private let images = Variable<[UIImage]>([]) //Observable image array
    private var imageCache = [Int]()
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images.asObservable()
            .do(onNext: { [weak self] in
                // enable/disable UIs(buttons mainly)
                self?.updateUI($0)
            })
            .subscribe(onNext: { [weak self] (photos:[UIImage]?) in
                guard let preview = self?.imagePreview else { return }
                // Add image to imagePreview
                preview.image = UIImage.collage(images: photos!,size: preview.frame.size)
            })
            .addDisposableTo(disposeBag) // adding to disposeBag.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // advanced debugging feature of RxSwift called Resources, which gives you the number of current allocations of observables, observers, and disposables. By default RxSwift
        print(" Resource cou t: \(RxSwift.Resources.total)")
    }
    
    private func updateUI(_ photos: [UIImage]) {
        saveButton.isEnabled = photos.count > 0 && photos.count % 2 == 0
        clearButton.isEnabled = photos.count > 0
        addButton.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        // Talking to other View Controller
        
        let photosViewController = storyboard!.instantiateViewController(
            withIdentifier: "kRxPhotoCollectionViewController") as! RxPhotoCollectionViewController
        let newPhoto = photosViewController.selectedPhotos
        newPhoto
            .takeWhile { [weak self] image in
                // Take value untill the six selection
                return (self?.images.value.count ?? 0) < 6
            }
            .filter({ newImage in
                // Take only landsape images
                return newImage.size.width > newImage.size.height
            })
            .filter({[weak self] newImage in
                // Adding images without duplication to imageCache
                let len = UIImagePNGRepresentation(newImage)?.count ?? 0
                guard self?.imageCache.contains(len) == false else {
                    return false
                }
                self?.imageCache.append(len)
                return true
            })
            .subscribe(onNext: { [weak self] newImage in
                guard let images = self?.images else { return }
                // Add to Observable
                images.value.append(newImage)
                }, onDisposed: {
                    print("completed photo selection")
            })
            .addDisposableTo(photosViewController.bag)// Dispose to RxPhotoCollectionView
        
        // Add new subscription to add thumb to navigation item
        newPhoto
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?.updateNavigationItem()
            }).addDisposableTo(photosViewController.bag)
        
        navigationController!.pushViewController(photosViewController, animated: true)
    }

    @IBAction func clearPreview(_ sender: UIButton) {
        images.value = []
        imageCache = []
    }
    
    @IBAction func savePreview(_ sender: UIButton) {
        guard let image = self.imagePreview.image else { return }
        // Subscribe the custom observable to either save image or saving error.
        RxPhotoWriter.save(image).subscribe(onError: { [weak self] error in
            self?.showMessage("Error", description: error.localizedDescription)
            }, onCompleted: { [weak self] in
                self?.showMessage("Saved")
                self?.clearPreview(UIButton())
        })
        .addDisposableTo(disposeBag)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        // Subscribe the custom reactive alert to show message
        showAlert(title, description: description)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func updateNavigationItem() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
}
