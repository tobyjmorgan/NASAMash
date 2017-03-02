//
//  UIViewController+TJMApplicationNotification.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/29/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit

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
}
