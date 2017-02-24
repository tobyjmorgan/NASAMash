//
//  Rover+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension Rover: JSONInitable {
    
    init?(json: JSON) {
        
        guard let id            = json[Key.id.rawValue] as? Int,
            let name          = json[Key.name.rawValue] as? RoverName,
            let landingDate   = json[Key.landing_date.rawValue] as? NasaDate,
            let launchDate    = json[Key.launch_date.rawValue] as? NasaDate,
            let status        = json[Key.status.rawValue] as? String,
            let maxDate       = json[Key.max_date.rawValue] as? NasaDate,
            let maxSol        = json[Key.max_sol.rawValue] as? Int,
            let totalPhotos   = json[Key.total_photos.rawValue] as? Int else {
                return nil
        }
        
        let listParser = Camera.listParser
        
        guard let cameras = listParser(json) else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.landingDate = landingDate
        self.launchDate = launchDate
        self.status = status
        self.maxDate = maxDate
        self.maxSol = maxSol
        self.totalPhotos = totalPhotos
        self.cameras = cameras
    }
}

extension Rover: ListParseable {
    static var listKey: HTTPKey {
        return Key.rovers.rawValue
    }
}
