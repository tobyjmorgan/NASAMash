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
    case notSet
}

class Model: NSObject {

    ///////////////////////////////////////////////////////////////////
    // singleton stuff
    static let shared = Model()
    
    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
        
        startUp()
    }
    ///////////////////////////////////////////////////////////////////

    
    
    
    
    static let daysOfAPODImagesForLatest = 6
    static let maxEarthImageCount: Int = 20
    
    enum Notifications: String {
        case modelReady
        case selectedRoverChanged
        case selectedManifestChanged
        case roverPhotosChanged
        case roverPhotosProcessing
        case roverPhotosDoneProcessing
        case roverModeChanged
        case apodImagesChanged
        case earthImagesChanged
        case earthImageAssetsProcessing
        case earthImageAssetsDoneProcessing
    }
    
    var rovers: [Rover] = []
    var apodImages: [APODImage] = []
    var roverPhotos: [RoverPhoto] = []
    var earthImages: [EarthImagery] = []
    var failedEarthImageCount: Int = 0
    
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

    var roverMode: RoverMode = .notSet {
        
        didSet {
            
            // if the value has changed, update the available images and send a notification
            if oldValue != roverMode {
                
                switch roverMode {
                case .notSet:
                    // do nothing
                    break
                    
                case .latest:
                    roverPhotos = prefetchedLatestRoverPhotos
                    
                case .random:
                    roverPhotos = []
                    fetchRandomRoverPhotos()
                    
                case .search:
                    roverPhotos = []
                }
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverModeChanged.rawValue), object: self)
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
            }
        }
    }
    
    var selectedRoverIndex: Int? = nil {
        
        didSet {
            
            // try to unwrap the value
            if let unwrappedRoverIndex = selectedRoverIndex {
                
                // check that this is a valid rover index, otherwise clear everything out and return
                guard rovers.indices.contains(unwrappedRoverIndex) else {
                    selectedRoverIndex = nil
                    selectedManifestIndex = nil
                    return
                }
                
                selectedManifestIndex = maxManifestIndex
                
            } else {
                // it was nil, so make sure the manifest index is nil too
                selectedManifestIndex = nil
            }
            
            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.selectedRoverChanged.rawValue), object: self)
        }
    }
    
    var currentRover: Rover? {
        
        guard let roverIndex = selectedRoverIndex,
              rovers.indices.contains(roverIndex) else { return nil }
        
        return rovers[roverIndex]
    }
    
    var maxManifestIndex: Int? {
        
        // try to unwrap the rover index
        if let unwrappedRoverIndex = selectedRoverIndex {
            
            // check that this is a valid rover index, otherwise we have to return nil
            guard rovers.indices.contains(unwrappedRoverIndex) else {
                return nil
            }
            
            // get the rover and the manifest count
            let rover = rovers[unwrappedRoverIndex]
            let manifestCount = rover.manifests.count
            
            // if there are manifests, set the max to count - 1
            if manifestCount > 0 {
                return manifestCount - 1 // the max possible index
            } else {
                return nil // no manifests, so return nil
            }
            
            
        } else {
            // it was nil, so make sure the max index is nil too
            return nil
        }
    }
    
    var selectedManifestIndex: Int? = nil {
        didSet {
            
            // unwrap new value since it may be nil
            if let unwrappedManifestIndex = selectedManifestIndex {
            
                // unwrap max possible index for current rover, because
                // again it may be nil
                if let maxManifestIndex = maxManifestIndex {
                    
                    // manifest index cannot be less than zero
                    if unwrappedManifestIndex < 0 {
                        selectedManifestIndex = 0
                    }
                    
                    // and it cannot be greater than the max
                    if unwrappedManifestIndex > maxManifestIndex {
                        selectedManifestIndex = maxManifestIndex
                    }
                    
                } else {
                    selectedManifestIndex = nil
                }
            }

            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.selectedManifestChanged.rawValue), object: self)
        }
    }
    
    var currentManifest: Manifest? {
        
        guard let rover = currentRover,
              let manifestIndex = selectedManifestIndex,
              rover.manifests.indices.contains(manifestIndex) else { return nil }
        
        return rover.manifests[manifestIndex]
    }
    
    internal var prefetchedAPODImages: [APODImage] = []
    internal var favoriteAPODImages: [APODImage] = []
    internal var prefetchedLatestRoverPhotos: [RoverPhoto] = []
    internal let client = NASAAPIClient()
    internal let defaults = UserDefaults.standard
    

    
    internal func startUp() {
        
        fetchRovers()
        fetchLatestAPODImages(lastFetchDate: Date())
        fetchFavoriteAPODImages()
    }
    
    internal func checkPrefetchRequestsComplete() {
        
        for rover in rovers {
            if rover.manifests.count == 0 {
                // manifest not yet loaded for this rover
                return
            }
        }

        if rovers.count > 0 {
            
            selectedRoverIndex = 0
            
            if let max = maxManifestIndex {
                
                selectedManifestIndex = max
            }
        }
        
        // if we made it here, then everything is ready
        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.modelReady.rawValue), object: self)
    }
}

    



///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - APOD Image Handling
extension Model {

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
                        
                        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
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
                        
                        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
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

    
    
    
    
///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Rover and Manifest Handling
extension Model {

    // this  method is only called once when the app starts up
    // TODO: - may want to do this periodically if the app is not closed for a 
    // day, then the user may have out of date manifests
    internal func fetchRovers() {
        
        let endpoint = NASARoverEndpoint.rovers
        client.fetch(request: endpoint.request, parse: NASARoverEndpoint.roversParser) { [ unowned self ] (result) in
        
            switch result {
                
            case .success(let rovers):

                self.rovers = rovers
                
                // now go and get all available manifests for each of the rovers
                self.fetchManifestsForRovers()
                
                // and get the latest rover photos
                self.fetchLatestRoverPhotos()
                
            case .failure(let error):
                
                let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Mars Rover information: \(error.localizedDescription)", fatal: true)
                note.postMyself()
            }
        }
    }
    
    internal func fetchManifestsForRovers() {
        
        for (index, rover) in rovers.enumerated() {
            
            let endpoint = NASARoverEndpoint.manifest(rover.name)
            
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.manifestParser) { [ unowned self ] (result) in
                
                switch result {

                case .success(let manifests):
                    
                    // update the relevant rover in the list of rovers with the returned manifests
                    let newRover = rover.roverWithManifests(manifests: manifests)
                    
                    // quick check nothing has changed during the asynchronous call
                    if self.rovers.indices.contains(index) {
                        
                        // replace the previous instance with the new instance
                        self.rovers[index] = newRover                        
                    }
                    
                    self.checkPrefetchRequestsComplete()

                case .failure(let error):
                    
                    let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Manifest information for Mars Rovers: \(error.localizedDescription)", fatal: true)
                    note.postMyself()
                }
            }
        }
    }
}





///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Rover Photo Handling
extension Model {
    
    internal func fetchRoverPhotos(roverName: RoverName, sol: Sol, context: RoverMode, lastInBatch: Bool) {
        
        if let params = RoverRequestParameters(roverName: roverName, sol: sol, earthDate: nil, cameras: nil, page: nil) {
            
            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosProcessing.rawValue), object: self)
            
            let endpoint = NASARoverEndpoint.roverPhotosBySol(params)
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.photosParser) {(result) in
                
                switch result {
                    
                case .success(let photos):
                    
                    if context == .latest {
                        
                        self.prefetchedLatestRoverPhotos = self.prefetchedLatestRoverPhotos + photos
                        
                        self.roverPhotos = self.prefetchedLatestRoverPhotos
                        
                    } else {
                        
                        self.roverPhotos = self.roverPhotos + photos
                    }
                    
                case .failure(let error):
                    
                    let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Rover Photos: \(error.localizedDescription)", fatal: false)
                    note.postMyself()
                }
                
                if lastInBatch {
                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosDoneProcessing.rawValue), object: self)
                }
            }
        }
    }
    
    internal func fetchLatestRoverPhotos() {
        
        for rover in rovers {
            
            guard let lastRover = rovers.last else { break }
            
            fetchRoverPhotos(roverName: rover.name, sol: rover.maxSol, context: .latest, lastInBatch: rover==lastRover)
        }
    }
    
    internal func fetchRandomRoverPhotos() {
        
        for rover in rovers {

            guard let lastRover = rovers.last else { break }
            
            let randomSol = Int.random(range: Range(0...rover.maxSol))
            
            fetchRoverPhotos(roverName: rover.name, sol: randomSol, context: .random, lastInBatch: rover==lastRover)
        }
    }
    
    func fetchRoverPhotosForSelectedManifest() {
        
        roverPhotos = []
        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
        
        guard let rover = currentRover, let manifest = currentManifest else { return }
        
        fetchRoverPhotos(roverName: rover.name, sol: manifest.sol, context: .search, lastInBatch: true)
    }
}





///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Earth Image Handling
extension Model {
    
    internal func fetchEarthImage(date: Date, lat: Double, lon: Double, expectedCount: Int) {

        let params = EarthImageryParams(lat: lat, lon: lon, dim: nil, date: date.earthDate)
        let endpoint = NASAEarthImageryEndpoint.getImageForLocation(params)
        client.fetch(request: endpoint.request, parse: EarthImagery.init) { [ unowned self ] (result) in
            
            switch result {
                
            case .success(let earthImage):
                self.earthImages.append(earthImage)
                self.earthImages.sort(by: { (firstImage, secondImage) -> Bool in
                    return firstImage.dateTime > secondImage.dateTime
                })
                
            case .failure(let error):
                // just ignore and keep count for now
                print(error)
                self.failedEarthImageCount += 1
                break
                
            }
            
            print("TJM earthImages.count: \(self.earthImages.count)")
            print("TJM failedEarthImageCount: \(self.failedEarthImageCount)")
            print("TJM expectedCount: \(expectedCount)")
            
            if (self.earthImages.count + self.failedEarthImageCount) == expectedCount {
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: self)
                
                if self.earthImages.count == 0 {
                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
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
//                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
//                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: self)
//                
//                if self.earthImages.count == 0 {
//                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
//                    let note = TJMApplicationNotification(title: "No Assets Retrieved", message: "Failed to retrieve any image assets for this location", fatal: false)
//                    note.postMyself()
//                }
//            }
//        }
//    }
    
    internal func fetchEarthImageAssetList(lat: Double, lon: Double, beginDate: NasaDate, endDate: NasaDate) {
        
        earthImages = []
        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: self)
        
        let endpoint = NASAEarthImageryEndpoint.getAssets(lat, lon, beginDate, endDate)
        
        NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsProcessing.rawValue), object: self)
            
        client.fetch(request: endpoint.request, parse: NASAEarthImageryEndpoint.assetsParser) {(result) in
                
            switch result {
                
            case .success(let assets):
                
                guard assets.count > 0 else {
                    NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
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
                self.failedEarthImageCount = 0
                
                // focus on getting most recent first
                let reversedAssets = assets.reversed()
                
                // take each asset and fetch the corresponding EarthImagery entry
                for (index, reversedAssets) in reversedAssets.enumerated() {
                    
                    if useThese.contains(index) {
                        self.fetchEarthImage(date: reversedAssets.dateTime, lat: lat, lon: lon, expectedCount: Model.maxEarthImageCount)
                    }
                    
// intermittent success getting assets with id search, using a different approach now
//                    self.fetchEarthImage(id: asset.id, expectedCount: 1); break
//                    self.fetchEarthImage(id: asset.id, expectedCount: assets.count)
                }
                
            case .failure(let error):
                
                NotificationCenter.default.post(name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: self)
                let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Rover Photos: \(error.localizedDescription)", fatal: false)
                note.postMyself()
            }
        }
    }
}





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
