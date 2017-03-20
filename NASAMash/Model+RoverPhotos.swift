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
    
    internal func fetchRoverPhotos(roverName: RoverName, sol: Sol, context: RoverMode) {
        
        var workingRoverPhotos: [RoverPhoto] = []
        
        if let params = RoverRequestParameters(roverName: roverName, sol: sol, earthDate: nil, cameras: nil, page: nil) {
            
            notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosProcessing.rawValue), object: self)
            
            let endpoint = NASARoverEndpoint.roverPhotosBySol(params)
            client.fetch(request: endpoint.request, parse: NASARoverEndpoint.photosParser) { [ weak self ](result) in
                
                guard let goodSelf = self else { return }
                
                switch result {
                    
                case .success(let photos):
                    
                    goodSelf.roverPhotoStatus.noteSuccessfulResult()
                    
                    workingRoverPhotos += photos
                    
                case .failure(let error):
                    
                    goodSelf.roverPhotoStatus.noteFailedResult()
                    
                    let note = TJMApplicationNotification(title: "Connection Problem", message: "Failed to fetch Rover Photos: \(error.localizedDescription)", fatal: false)
                    note.postMyself()
                }
                
                if goodSelf.roverPhotoStatus.checkComplete() {

                    let roverPhotoResults: RoverPhotoResults
                    
                    var roverPhotosInSections: [ String : [RoverPhoto]] = [:]
                    
                    // get sections
                    let sections = Array(Set(workingRoverPhotos.map { $0.rover.name }))
                    
                    for section in sections {
                        
                        let sectionPhotos = workingRoverPhotos.filter { $0.rover.name == section }
                        
                        roverPhotosInSections[section] = sectionPhotos
                    }
                    
                    roverPhotoResults = RoverPhotoResults(sections: sections, sectionPhotos: roverPhotosInSections)
                    
                    if context == .latest {
                        
                        goodSelf.prefetchedLatestRoverPhotos = roverPhotoResults
                        
                        goodSelf.roverPhotos = goodSelf.prefetchedLatestRoverPhotos
                        
                    } else {
                        
                        goodSelf.roverPhotos = roverPhotoResults
                    }
                    
                    goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: goodSelf)
                    goodSelf.notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosDoneProcessing.rawValue), object: goodSelf)
                }
            }
        }
    }
    
    internal func fetchLatestRoverPhotos() {
        
        guard !roverPhotoStatus.isWorking else { return }
        
        for rover in rovers {
            
            guard let mostRecentManifest = rover.manifests.last  else { break }

            guard let lastManifestDate = rover.earthDateFromSol(sol: mostRecentManifest.sol) else { break }
            
            guard let daysSinceLastManifest = Date.daysBetween(start: lastManifestDate, end: Date()), daysSinceLastManifest < 30 else { break }
            
            roverPhotoStatus.noteSentRequest()
            
            fetchRoverPhotos(roverName: rover.name, sol: mostRecentManifest.sol, context: .latest)
        }
    }
    
//    internal func fetchRandomRoverPhotos() {
//        
//        guard !roverPhotoStatus.isWorking else { return }
//        
//        roverPhotoStatus.noteSentRequests(rovers.count)
//        
//        for rover in rovers {
//            
//            let randomSol = Int.random(range: Range(0...rover.maxSol))
//            
//            fetchRoverPhotos(roverName: rover.name, sol: randomSol, context: .random)
//        }
//    }
    
    func fetchRoverPhotosForSelectedManifest() {
        
        guard !roverPhotoStatus.isWorking else { return }
        
        roverPhotos = nil
        notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
        
        guard let rover = currentRover, let manifest = currentManifest else { return }
        
        roverPhotoStatus.noteSentRequest()
        
        fetchRoverPhotos(roverName: rover.name, sol: manifest.sol, context: .search)
    }
}



