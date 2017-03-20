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
        return 7
    }

    internal func fetchAPODImage(nasaDate: NasaDate, context: APODMode, totalInBatch: Int) {
        
        apodStatus.noteSentRequests(totalInBatch)

        let endpoint = NASAAPODEndpoint.getAPODImage(nasaDate)
        client.fetch(request: endpoint.request, parse: APODImage.init) { [ weak self ] (result) in
            
            guard let goodSelf = self else { return }
            
            switch result {
                
            case .success(let image):
                
                goodSelf.apodStatus.noteSuccessfulResult()
                
                switch context {
                    
                case .favorites:
                    // there is the possibility of duplicates, so prevent them and sort the results
                    if !goodSelf.favoriteAPODImages.contains(image) {
                        
                        goodSelf.favoriteAPODImages.append(image)
                        goodSelf.favoriteAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                    }
                    
                case .latest:
                    if !goodSelf.prefetchedAPODImages.contains(image) {
                        
                        goodSelf.prefetchedAPODImages.append(image)
                        goodSelf.prefetchedAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                    }
                    
                }
                
            case .failure(let error):
                
                goodSelf.apodStatus.noteFailedResult()
                
                let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Astronomy Photo information: \(error.localizedDescription)", fatal: false)
                note.postMyself()
            }
            
            
            
            if goodSelf.apodStatus.checkComplete() {
                
                switch context {
                case .favorites:
                        // if we are currently in "favorites" APOD mode then make these results the working results
                        if goodSelf.apodMode == .favorites { goodSelf.apodImages = goodSelf.favoriteAPODImages }
                        
                        goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: goodSelf)

                case .latest:
                    // if we are currently in "latest" APOD mode then make these results the working results
                    if goodSelf.apodMode == .latest { goodSelf.apodImages = goodSelf.prefetchedAPODImages }
                    
                    goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: goodSelf)
                }
            }
        }
    }
    
    internal func fetchLatestAPODImages() {
        
        let useDate: Date
        let startIndex: Int

        if prefetchedAPODImages.count == 0 {
            useDate = Date()
            startIndex = 0
        } else {
            useDate = prefetchedAPODImages.last!.date
            startIndex = 1
        }
        
        for daysBefore in startIndex..<Model.daysOfAPODImagesForLatest {
            
            if let fetchDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: useDate) {

                delay(0.2) {
                    self.fetchAPODImage(nasaDate: fetchDate.earthDate, context: .latest, totalInBatch: Model.daysOfAPODImagesForLatest-startIndex)
                }
            }
        }
    }
    
    internal func fetchFavoriteAPODImages() {
        
        let favorites = allFavoriteApods()
        
        for favoriteDate in favorites {
            
            fetchAPODImage(nasaDate: favoriteDate, context: .favorites, totalInBatch: favorites.count)
        }
    }
    
    func fetchMoreLatestAPODImages() {
        
        guard !apodStatus.isWorking else { return }
        
        // if there are any already, it will try to fetch more
        fetchLatestAPODImages()
    }
}

extension Model {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}
