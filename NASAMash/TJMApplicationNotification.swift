//
//  TJMApplicationNotification.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

// provides a standard app-wide user notification
struct TJMApplicationNotification {
    
    static let ApplicationNotification = Notification.Name("TJMApplicationNotification")
    static let DetailsKey = "DetailsKey"
    
    let title: String
    let message: String
    let fatal: Bool
    
    // wrap this notification's details up in a userInfo dictionary
    private func makeUserInfoDict() -> [String : Any] {
        return [TJMApplicationNotification.DetailsKey : TJMApplicationNotification(title: title, message: message, fatal: fatal)]
    }
    
    // post a notification containing these details
    func postMyself() {
        NotificationCenter.default.post(name: TJMApplicationNotification.ApplicationNotification, object: self, userInfo: makeUserInfoDict())
    }
    
    // unwrap the details from the notification
    static func getDetailsFromNotification(notification: Notification) -> TJMApplicationNotification? {
    
        guard let userInfo = notification.userInfo as? [String: Any],
              let details = userInfo[TJMApplicationNotification.DetailsKey] as? TJMApplicationNotification else { return nil }
        
        return details
    }
}
