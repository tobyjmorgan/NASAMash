//
//  Model.swift
//  NASAMash
//
//  Created by redBred LLC on 2/24/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum APODMode: Int {
    case latest
    case favorites
}

class Model: NSObject {
    
    enum Notifications: String {
        case roversChanged
        case apodImagesChanged
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
    
    private var prefetchedAPODImages: [APODImage] = []
    private var favoriteAPODImages: [APODImage] = []
    
    private let client = NASAAPIClient()
    
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
        fetchAPODImages(lastFetchDate: Date())
        
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
    
    func fetchAPODImages(lastFetchDate: Date) {
        
        for daysBefore in 0...6 {
            
            if let fetchDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: lastFetchDate) {
                
                let endpoint = NASAAPODEndpoint.getAPODImage(fetchDate.earthDate)
                
                client.fetch(request: endpoint.request, parse: APODImage.init) { (result) in
                    switch result {
                    
                    case .success(let image):
                        if !self.prefetchedAPODImages.contains(image) {
                            
                            self.prefetchedAPODImages.append(image)
                            self.prefetchedAPODImages.sort(by: { (firstImage, secondImage) -> Bool in
                                return firstImage.date > secondImage.date
                            })
                            
                            self.apodImages = self.prefetchedAPODImages
                            NotificationCenter.default.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
                        }
                        
                    case .failure(let error):
                        print(error)
                        
                    }
                }
            }
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
}
