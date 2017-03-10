//
//  Model+UserSettings.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - APOD Favorites Handling
extension Model {
    
    // return all favorite APODs from user defaults
    func allFavoriteApods() -> [String] {
        
        guard let favorites = defaults.array(forKey: UserDefaultsKey.favoriteApodImages.rawValue) as? [String] else { return [] }
        
        return favorites
    }
    
    // returns if specified APOD is a favorite
    func isFavoriteApod(apodImage: APODImage) -> Bool {
        
        return allFavoriteApods().contains(apodImage.date.earthDate)
    }
    
    // adds the specified APOD to favorites, if not already there
    func addApodToFavorites(apodImage: APODImage) {
        
        guard !isFavoriteApod(apodImage: apodImage) else { return }
        
        let newFavorites = allFavoriteApods() + [apodImage.date.earthDate]
        
        defaults.set(newFavorites, forKey: UserDefaultsKey.favoriteApodImages.rawValue)
        defaults.synchronize()
        
        // now add it to the array of APODImages
        if !favoriteAPODImages.contains(apodImage) {
            favoriteAPODImages.insert(apodImage, at: 0)
            
            if apodMode == .favorites {
                
                // refresh apodImages to reflect the new state of favoriteApodImages
                apodImages = favoriteAPODImages
                
                notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
            }
        }
    }
    
    //removes the specified APOD from favorites, if present
    func removeApodFromFavorites(apodImage: APODImage) {
        
        var currentFavorites = allFavoriteApods()
        
        if let index = currentFavorites.index(of: apodImage.date.earthDate) {
            currentFavorites.remove(at: index)
        }
        
        defaults.set(currentFavorites, forKey: UserDefaultsKey.favoriteApodImages.rawValue)
        defaults.synchronize()
        
        // now remove it from the array of APODImages
        if let index = favoriteAPODImages.index(of: apodImage) {
            favoriteAPODImages.remove(at: index)
            
            if apodMode == .favorites {
                // refresh apodImages to reflect the new state of favoriteApodImages
                apodImages = favoriteAPODImages
                
                notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
            }
        }
    }
}





///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Other Settings
extension Model {
    
    // has the app been run before (offer welcome)
    func hasBeenRunBefore() -> Bool {
        
        let runBefore = defaults.bool(forKey: UserDefaultsKey.everBeenRunBefore.rawValue)
        
        if runBefore { return true }
        
        defaults.set(true, forKey: UserDefaultsKey.everBeenRunBefore.rawValue)
        defaults.synchronize()
        
        return false
    }
}
