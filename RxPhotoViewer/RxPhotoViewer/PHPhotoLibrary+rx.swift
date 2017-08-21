//
//  PHPhotoLibrary+rx.swift
//  RxPhotoViewer
//
//  Created by Md. Arafat Hossain zinuk on 7/30/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import Foundation

import Foundation
import Photos
import RxSwift
extension PHPhotoLibrary {
    // Custom Observable to authorize PHLibrary
    static var authorized: Observable<Bool> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization { newStatus in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
