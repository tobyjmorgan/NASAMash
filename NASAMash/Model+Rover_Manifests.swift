//
//  Model+Rover_Manifests.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

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
                
                if self.rovers.count > 0 {
                    
                    // now go and get all available manifests for each of the rovers
                    self.fetchManifestsForRovers()
                    
                    // and get the latest rover photos
                    self.fetchLatestRoverPhotos()
                
                } else {
                    
                    // no rovers found, so try to proceed with no rovers
                    self.checkPrefetchRequestsComplete()
                }
                
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
