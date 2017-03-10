//
//  Model+APOD.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - APOD Image Handling
extension Model {
    
    static var daysOfAPODImagesForLatest: Int {
        return 6
    }

    internal func fetchAPODImage(nasaDate: NasaDate, context: APODMode, finalOfBatch: Bool) {
        
        let endpoint = NASAAPODEndpoint.getAPODImage(nasaDate)
        client.fetch(request: endpoint.request, parse: APODImage.init) { [ unowned self ] (result) in
            
            switch result {
                
            case .success(let image):
                
                switch context {
                    
                case .favorites:
                    // there is the possibility of duplicates, so prevent them and sort the results
                    if !self.favoriteAPODImages.contains(image) {
                        
                        self.favoriteAPODImages.append(image)
                        self.favoriteAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                    }
                    
                    if finalOfBatch {
                        // if we are currently in "favorites" APOD mode then make these results the working results
                        if self.apodMode == .favorites { self.apodImages = self.favoriteAPODImages }
                        
                        self.notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
                    }
                    
                case .latest:
                    if !self.prefetchedAPODImages.contains(image) {
                        
                        self.prefetchedAPODImages.append(image)
                        self.prefetchedAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                    }
                    
                    if finalOfBatch {
                        // if we are currently in "latest" APOD mode then make these results the working results
                        if self.apodMode == .latest { self.apodImages = self.prefetchedAPODImages }
                        
                        self.notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
                    }
                    
                }
                
            case .failure(let error):
                
                let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Astronomy Photo information: \(error.localizedDescription)", fatal: false)
                note.postMyself()
            }
        }
    }
    
    internal func fetchLatestAPODImages(lastFetchDate: Date) {
        
        for daysBefore in 0...Model.daysOfAPODImagesForLatest {
            
            if let fetchDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: lastFetchDate) {
                
                fetchAPODImage(nasaDate: fetchDate.earthDate, context: .latest, finalOfBatch: daysBefore == Model.daysOfAPODImagesForLatest)
            }
        }
    }
    
    internal func fetchFavoriteAPODImages() {
        
        for favoriteDate in allFavoriteApods() {
            
            fetchAPODImage(nasaDate: favoriteDate, context: .favorites, finalOfBatch: false)
        }
    }
}
