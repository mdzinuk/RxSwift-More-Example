//
//  AlertViewController+rx.swift
//  RxPhotoViewer
//
//  Created by Md. Arafat Hossain zinuk on 7/30/17.
//  Copyright © 2017 Md. Arafat Hossain zinuk. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension UIViewController {
    // Reactive custom alert observable with action
    func showAlert(_ title: String, description: String? = nil) -> Observable<Void> {
        return Observable.create ({ [weak self](observer) in
            let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                observer.onCompleted()
            }))
            
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
