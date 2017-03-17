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
    
    func onDownloadImage(urlString: String?) {
        
        guard let urlString = urlString else { return }
        
        // only allow secure requests - if it fails then no image will show
        let secureURLString = urlString.replacingOccurrences(of: "http://", with: "https://")
        
        // ok download image in the background
        UIImage.getImageAsynchronously(urlString: secureURLString) { [ weak self ] (image, error) in
            
            guard let goodSelf = self else { return }
            
            guard let image = image else {
                // failed to download image
                let note = TJMApplicationNotification(title: "Oops!", message: "Unable to download high-definition image from the server", fatal: false)
                note.postMyself()
                return
            }
            
            // success - save to Photo Library
            goodSelf.onSaveImagetoPhotoLibrary(image: image)
        }
    }
    
    func onSaveImagetoPhotoLibrary(image: UIImage) {
        
        // make sure we have permission to save to the Photo Library
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            
            switch authorizationStatus {
                
            case .authorized:
                
                // success - save to Photo Library
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(UIViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            default:
                // we don't have permission, so notify the user that this feature can't be used
                let note = TJMApplicationNotification(title: "Oops!", message: "This app does not have permission to access your Photo Library. You can change this in Settings if you want save images in future", fatal: false)
                note.postMyself()
            }
        }
    }

    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        guard error == nil else {
            // failed to save image
            let note = TJMApplicationNotification(title: "Oops!", message: "Unable to save image to Photo Library", fatal: false)
            note.postMyself()
            return
        }
        
        // image saved successfully
        let note = TJMApplicationNotification(title: "Photo Saved!", message: "Image successfully saved to Photo Library", fatal: false)
        note.postMyself()
    }
}
