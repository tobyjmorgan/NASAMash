//
//  Model+EarthImagery.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Earth Image Handling
extension Model {
    
    static var maxEarthImageCount: Int {
        return 20
    }
    
    internal func fetchEarthImage(date: Date, lat: Double, lon: Double, expectedCount: Int) {
        
        let params = EarthImageryParams(lat: lat, lon: lon, dim: nil, date: date.earthDate)
        let endpoint = NASAEarthImageryEndpoint.getImageForLocation(params)
        client.fetch(request: endpoint.request, parse: EarthImagery.init) { [ weak self ] (result) in
            
            guard let goodSelf = self else { return }
            
            switch result {
                
            case .success(let earthImage):
                goodSelf.earthImages.append(earthImage)
                goodSelf.earthImages.sort(by: { (firstImage, secondImage) -> Bool in
                    return firstImage.dateTime > secondImage.dateTime
                })
                
            case .failure(let error):
                // just ignore and keep count for now
                print(error)
                goodSelf.failedEarthImageCount += 1
                break
                
            }
            
            if (goodSelf.earthImages.count + goodSelf.failedEarthImageCount) == expectedCount {
                goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: goodSelf)
                goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: goodSelf)
                
                if goodSelf.earthImages.count == 0 {
                    goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: goodSelf)
                    let note = TJMApplicationNotification(title: "No Assets Retrieved", message: "Failed to retrieve any image assets for this location", fatal: false)
                    note.postMyself()
                }
            }
        }
    }
    
    // Only works intermitently - so avoiding using id as param see replacement func above
    //    internal func fetchEarthImage(id: String, expectedCount: Int) {
    //
    //        let endpoint = NASAEarthImageryEndpoint.getImageForID(id)
    //        client.fetch(request: endpoint.request, parse: EarthImagery.init) {(result) in
    //
    //            switch result {
    //
    //            case .success(let earthImage):
    //                self.earthImages.append(earthImage)
    //                self.earthImages.sort(by: { (firstImage, secondImage) -> Bool in
    //                    return firstImage.dateTime > secondImage.dateTime
    //                })
    //
    //            case .failure(let error):
    //                // just ignore and keep count for now
    //                print(error)
    //                self.failedEarthImageCount += 1
    //                break
    //
    //            }
    //
    //            if (self.earthImages.count + self.failedEarthImageCount) == expectedCount {
    //                notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
    //                notificationCenter.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: self)
    //
    //                if self.earthImages.count == 0 {
    //                    notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
    //                    let note = TJMApplicationNotification(title: "No Assets Retrieved", message: "Failed to retrieve any image assets for this location", fatal: false)
    //                    note.postMyself()
    //                }
    //            }
    //        }
    //    }
    
    internal func fetchEarthImageAssetList(lat: Double, lon: Double, beginDate: NasaDate, endDate: NasaDate) {
        
        earthImages = []
        notificationCenter.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: self)
        
        let endpoint = NASAEarthImageryEndpoint.getAssets(lat, lon, beginDate, endDate)
        
        notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsProcessing.rawValue), object: self)
        
        client.fetch(request: endpoint.request, parse: NASAEarthImageryEndpoint.assetsParser) { [ weak self ] (result) in
            
            guard let goodSelf = self else { return }
            
            switch result {
                
            case .success(let assets):
                
                guard assets.count > 0 else {
                    goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: goodSelf)
                    let note = TJMApplicationNotification(title: "No Assets Found", message: "Failed to find any image assets for this location", fatal: false)
                    note.postMyself()
                    return
                }
                
                // the API has a cap on how many requests can be sent in a burst, so
                // selectively getting a spread of images over time
                
                var usageRate = 1 // default usage rate
                
                // calculate the usage rate based on how many assets are available
                if assets.count > Model.maxEarthImageCount {
                    usageRate = Int(assets.count / Model.maxEarthImageCount)
                }
                
                // make a list of the desired indices
                var useThese: [Int] = []
                
                for i in 0 ..< Model.maxEarthImageCount {
                    let candidateIndex = i*usageRate
                    useThese.append(candidateIndex)
                }
                
                // keep track of how many requests fail, so we know when we are done
                goodSelf.failedEarthImageCount = 0
                
                // focus on getting most recent first
                let reversedAssets = assets.reversed()
                
                // take each asset and fetch the corresponding EarthImagery entry
                for (index, reversedAssets) in reversedAssets.enumerated() {
                    
                    if useThese.contains(index) {
                        goodSelf.fetchEarthImage(date: reversedAssets.dateTime, lat: lat, lon: lon, expectedCount: Model.maxEarthImageCount)
                    }
                    
                    // intermittent success getting assets with id search, using a different approach now
                    //                    self.fetchEarthImage(id: asset.id, expectedCount: 1); break
                    //                    self.fetchEarthImage(id: asset.id, expectedCount: assets.count)
                }
                
            case .failure(let error):
                
                goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: goodSelf)
                let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Rover Photos: \(error.localizedDescription)", fatal: false)
                note.postMyself()
            }
        }
    }
}
