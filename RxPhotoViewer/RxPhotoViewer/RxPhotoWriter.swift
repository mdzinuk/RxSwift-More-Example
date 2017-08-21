//
//  RxPhotoWriter.swift
//  RxPhotoViewer
//
//  Created by Md. Arafat Hossain zinuk on 7/29/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import Foundation
import RxSwift

class RxPhotoWriter: NSObject {
    typealias Callback = (Error?) -> Void
    
    private var callback: Callback
    
    private init(callback: @escaping Callback) {
        self.callback = callback
    }
    
    @objc func image(_ image: UIImage, didfinishWithSavingError error: Error?, contextInfo: UnsafeRawPointer) {
        callback(error)
    }
    
    // Converting plain function to Reactive manner
    static func save(_ image: UIImage) -> Observable<Void> {
        // Creating a custom observable
        return Observable.create({ observable in
            let writer = RxPhotoWriter(callback: { error in
                if let error = error {
                    observable.onError(error)
                } else {
                    observable.onCompleted()
                }
            })
            
            UIImageWriteToSavedPhotosAlbum(image, writer, #selector(RxPhotoWriter.image(_:didfinishWithSavingError:contextInfo:)), nil)
            return Disposables.create() // return a Disposable out of that closure
        })
    }
    
}
