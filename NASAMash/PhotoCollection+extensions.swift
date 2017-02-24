//
//  PhotoCollection+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/23/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension PhotoCollection: JSONInitable {
    
    init?(json: JSON) {
        
        guard let sol               = json[Key.sol.rawValue] as? Sol,
              let totalPhotos       = json[Key.total_photos.rawValue] as? Int,
              let cameraNames       = json[Key.cameras.rawValue] as? [CameraName] else {
            return nil
        }
        
        self.sol = sol
        self.totalPhotos = totalPhotos
        self.cameraNames = cameraNames
    }
}

extension PhotoCollection: ListParseable {
    
    static var listKey: HTTPKey {
        return Key.photos.rawValue
    }
}

