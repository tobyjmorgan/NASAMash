//
//  RoverPhoto+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension RoverPhoto: JSONInitable {
    
    init?(json: JSON) {
        
        guard let id            = json[Key.id.rawValue] as? Int,
            let rawCamera     = json[Key.camera.rawValue] as? JSON,
            let earthDate     = json[Key.earth_date.rawValue] as? NasaDate,
            let sol           = json[Key.max_sol.rawValue] as? Int,
            let imageURL      = json[Key.img_src.rawValue] as? String,
            let rawRover      = json[Key.rover.rawValue] as? JSON else {
                return nil
        }
        
        guard let camera = Camera(json: rawCamera), let rover = Rover(json: rawRover) else { return nil }
        
        self.id = id
        self.earthDate = earthDate
        self.sol = sol
        self.imageURL = imageURL
        self.camera = camera
        self.rover = rover
    }
}

extension RoverPhoto: HasListParser {
    static var listKey: HTTPKey {
        return Key.photos.rawValue
    }
}
