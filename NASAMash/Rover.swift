//
//  Rover.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

typealias RoverName = String

struct Rover {
    
    let id: Int
    let name: RoverName
    let landingDate: NasaDate
    let launchDate: NasaDate
    let status: String
    let maxSol: Sol
    let maxDate: NasaDate
    let totalPhotos: Int
    let cameras: [Camera]
    let manifests: [Manifest]
    
    init(id: Int, name: RoverName, landingDate: NasaDate, launchDate: NasaDate, status: String, maxSol: Sol, maxDate: NasaDate, totalPhotos: Int, cameras: [Camera], manifests: [Manifest]?) {
        
        self.id = id
        self.name = name
        self.landingDate = landingDate
        self.launchDate = launchDate
        self.status = status
        self.maxSol = maxSol
        self.maxDate = maxDate
        self.totalPhotos = totalPhotos
        self.cameras = cameras
        
        if let manifests = manifests {
            self.manifests = manifests
        } else {
            self.manifests = []
        }
    }
}
