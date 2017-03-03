//
//  Model.swift
//  NASAMash
//
//  Created by redBred LLC on 2/24/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import GameKit

enum APODMode: Int {
    case latest
    case favorites
}

enum RoverMode: Int {
    case latest
    case random
    case search
}

class Model: NSObject {

    static let maxDaysBefore = 6
    
    enum Notifications: String {
        case roversChanged
        case apodImagesChanged
        case roverPhotosChanged
    }
    
    var rovers: [Rover] = []
    
    var apodImages: [APODImage] = []
    var apodMode: APODMode = .latest {
        
        didSet {
            
            // if the value has changed, update the available images and send a notification
            if oldValue != apodMode {
                
                switch apodMode {
                case .latest:
                    apodImages = prefetchedAPODImages
                case .favorites:
                    apodImages = favoriteAPODImages
                }
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
            }
        }
    }

    var roverPhotos: [RoverPhoto] = []
    var roverMode: RoverMode = .latest {
        
        didSet {
            
            // if the value has changed, update the available images and send a notification
            if oldValue != roverMode {
                
                switch roverMode {
                case .latest:
                    roverPhotos = []
                    fetchLatestRoverPhotos()
                    
                case .random:
                    roverPhotos = []
                    fetchRandomRoverPhotos()
                    
                case .search:
                    roverPhotos = []
                }
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
            }
        }
    }

    internal var prefetchedAPODImages: [APODImage] = []
    internal var favoriteAPODImages: [APODImage] = []
    
    internal let client = NASAAPIClient()
    internal let defaults = UserDefaults.standard
    

    
    // singleton stuff
    static let shared = Model()
    
    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
        
        startUp()
    }
    
    private func startUp() {
        
        fetchRovers()
        fetchLatestAPODImages(lastFetchDate: Date())
        fetchFavoriteAPODImages()
        
//        if let roverParams = RoverRequestParameters(roverName: "curiosity", sol: 1000, earthDate: nil, cameras: nil, page: nil) {
//            
//            let endpoint = NASARoverEndpoint.roverPhotosBySol(roverParams)
//            
//            client.fetch(request: endpoint.request, parse: NASAEndpoint.photosParser) { (result) in
//                switch result {
//                case .success:
//                    print("Success!")
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
        
//        let endpoint = NASAEarthImageryEndpoint.getAssets(52.7229, -4.0561, "2011-01-01", "2017-01-01")
//        client.fetch(request: endpoint.request, parse: NASAEarthImageryEndpoint.assetsParser) { (result) in
//            switch result {
//            case .success(let assets):
//                print(assets)
//            case .failure(let error):
//                print(error)
//                
//            }
//        }
        
        
//        let earthParams = EarthImageryParams(lat: 52.7229, lon: -4.0561, dim: nil, date: nil)
//        let endpoint = NASAEarthImageryEndpoint.getImageForLocation(earthParams)
//        client.fetch(request: endpoint.request, parse: EarthImagery.init) { (result) in
//            switch result {
//            case .success(let imagery):
//                print(imagery)
//            case .failure(let error):
//                print(error)
//                
//            }
//        }

    }
    
    private func fetchAPODImage(nasaDate: NasaDate, contextApodMode: APODMode, finalOfBatch: Bool) {
        
        let endpoint = NASAAPODEndpoint.getAPODImage(nasaDate)
        
        client.fetch(request: endpoint.request, parse: APODImage.init) { (result) in
            
            switch result {
                
            case .success(let image):
                
                switch contextApodMode {
                    
                case .favorites:
                    if !self.favoriteAPODImages.contains(image) {
                        
                        self.favoriteAPODImages.append(image)
                        self.favoriteAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                        
                        if finalOfBatch {
                            if self.apodMode == .favorites { self.apodImages = self.favoriteAPODImages }
                            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
                        }
                    }

                case .latest:
                    if !self.prefetchedAPODImages.contains(image) {
                        
                        self.prefetchedAPODImages.append(image)
                        self.prefetchedAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                            return firstImage.date > secondImage.date
                        })
                        
                        if finalOfBatch {
                            if self.apodMode == .latest { self.apodImages = self.prefetchedAPODImages }
                            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    private func fetchLatestAPODImages(lastFetchDate: Date) {
        
        for daysBefore in 0...Model.maxDaysBefore {
            
            if let fetchDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: lastFetchDate) {
                
                fetchAPODImage(nasaDate: fetchDate.earthDate, contextApodMode: .latest, finalOfBatch: daysBefore == Model.maxDaysBefore)
            }
        }
    }
    
    private func fetchFavoriteAPODImages() {
        
        for favoriteDate in allFavoriteApods() {
            
            fetchAPODImage(nasaDate: favoriteDate, contextApodMode: .favorites, finalOfBatch: false)
        }
    }
    
    func fetchRovers() {
        
        let endpoint = NASARoverEndpoint.rovers
        client.fetch(request: endpoint.request, parse: NASARoverEndpoint.roversParser) { (result) in
            
            DispatchQueue.main.async {
                
                switch result {

                case .failure(let error):
                    // TODO: handle error correctly
                    print(error)
                
                case .success(let rovers):
                    self.rovers = rovers
                    self.fetchManifestsForRovers()
                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roversChanged.rawValue), object: self)
                
                }
            }
        }
    }
    
    func fetchManifestsForRovers() {
        
        for (index, rover) in rovers.enumerated() {
            
            let endpoint = NASARoverEndpoint.manifest(rover.name)
            
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.manifestParser) { (result) in
                
                switch result {

                case .success(let manifests):
                    
                    DispatchQueue.main.async {
                        
                        // update the relevant rover in the list of rovers with the returned manifests
                        let newRover = rover.roverWithManifests(manifests: manifests)
                        
                        // quick check nothing has changed during the asynchronous call
                        if self.rovers.indices.contains(index) {
                            
                            self.rovers[index] = newRover
                        }
                    }
                    
                case .failure(let error):
                    // TODO: report error to whoever can present an error message
                    print("Failed to fetch manifests: \(error)")
                    break
                }
            }
        }
    }
    
    func fetchRoverPhotos(roverName: RoverName, sol: Sol, lastInBatch: Bool) {
        
        if let params = RoverRequestParameters(roverName: roverName, sol: sol, earthDate: nil, cameras: nil, page: nil) {
            
            let endpoint = NASARoverEndpoint.roverPhotosBySol(params)
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.photosParser) {(result) in
                
                DispatchQueue.main.async {
                    
                    switch result {
                        
                    case .failure(let error):
                        // TODO: handle error correctly
                        print(error)
                        
                    case .success(let photos):
                        self.roverPhotos = self.roverPhotos + photos
                        print("RoverPhotos: \(self.roverPhotos.count)")
                        if lastInBatch {
                            print("notifying")
                            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
                        }
                    }
                }
            }
        }
    }
    
    func fetchLatestRoverPhotos() {
        
        for rover in rovers {
            
            guard let lastRover = rovers.last else { break }
            
            fetchRoverPhotos(roverName: rover.name, sol: rover.maxSol, lastInBatch: rover==lastRover)
        }
    }
    
    func fetchRandomRoverPhotos() {
        
        for rover in rovers {

            guard let lastRover = rovers.last else { break }
            
            let randomSol = Int.random(range: Range(0...rover.maxSol))
            
            fetchRoverPhotos(roverName: rover.name, sol: randomSol, lastInBatch: rover==lastRover)
        }
    }
}

// MARK: - Favorite APOD
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
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
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
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
            }
        }
    }
}

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
