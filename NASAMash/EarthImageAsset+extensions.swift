//
//  EarthImageAsset+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension EarthImageAsset: JSONInitable {
    
    init?(json: JSON) {
        
        guard let id        = json[Key.id.rawValue] as? String,
              let rawDate   = json[Key.date.rawValue] as? NasaDateTime else {
            return nil
        }
        
        guard let dateTime = Date(nasaDateTime: rawDate) else { return nil }
        
        self.id = id
        self.dateTime = dateTime
    }
}

extension EarthImageAsset: ListParseable {
    
    static var listKey: HTTPKey {
        return Key.results.rawValue
    }
}
