//
//  UIViewController+TJMApplicationNotification.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/29/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension UIViewController {
    
    // display notifications
    func onApplicationNotification(notification: Notification) {
        
        guard self.isViewLoaded && (self.view.window != nil),
              let details = TJMApplicationNotification.getDetailsFromNotification(notification: notification) else { return }
        
        let alert = UIAlertController(title: details.title, message: details.message, preferredStyle: .alert)
        let action:UIAlertAction
        
        if details.fatal {
            action = UIAlertAction(title: "OK", style: .default) {(action) in
                fatalError()
            }
        } else {
            action = UIAlertAction(title: "OK", style: .default, handler: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func onDownload(urlString: String) {
        
        // make sure we have permission to save to the Photo Library
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            
            switch authorizationStatus {
                
            case .authorized:
                
                // only allow secure requests - if it fails then no image will show
                let secureURLString = urlString.replacingOccurrences(of: "http://", with: "https://")
                
                // ok download image in the background
                UIImage.getImageAsynchronously(urlString: secureURLString) { (image) in
                    
                    guard let image = image else {
                        // failed to download image
                        let note = TJMApplicationNotification(title: "Oops!", message: "Unable to download high-definition image from the server", fatal: false)
                        note.postMyself()
                        return
                    }
                    
                    // success - save to Photo Library
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(APODViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
            default:
                // we don't have permission, so notify the user that this feature can't be used
                let note = TJMApplicationNotification(title: "Oops!", message: "This app does not have permission to access your Photo Library. You can change this in Settings if you want download images in future", fatal: false)
                note.postMyself()
            }
        }
    }
}
