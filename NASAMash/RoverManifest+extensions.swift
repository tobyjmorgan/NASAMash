//
//  RoverManifest+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/23/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension RoverManifest: JSONInitable {
    
    init?(json: JSON) {
        
        guard let manifest  = json[Key.photo_manifest.rawValue] as? JSON,
              let name      = manifest[Key.name.rawValue] as? RoverName else {
            return nil
        }
        
        let listParser = PhotoCollection.listParser
        
        guard let photoCollections = listParser(manifest) else {
            return nil
        }

        self.roverName = name
        self.photoCollections = photoCollections
    }
}

