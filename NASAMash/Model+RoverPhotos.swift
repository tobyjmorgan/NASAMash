//
//  Model+RoverPhotos.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Rover Photo Handling
extension Model {
    
    internal func fetchRoverPhotos(roverName: RoverName, sol: Sol, context: RoverMode, lastInBatch: Bool) {
        
        if let params = RoverRequestParameters(roverName: roverName, sol: sol, earthDate: nil, cameras: nil, page: nil) {
            
            notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosProcessing.rawValue), object: self)
            
            let endpoint = NASARoverEndpoint.roverPhotosBySol(params)
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.photosParser) { [ unowned self ](result) in
                
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
                    self.notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
                    self.notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosDoneProcessing.rawValue), object: self)
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
        notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
        
        guard let rover = currentRover, let manifest = currentManifest else { return }
        
        fetchRoverPhotos(roverName: rover.name, sol: manifest.sol, context: .search, lastInBatch: true)
    }
}
