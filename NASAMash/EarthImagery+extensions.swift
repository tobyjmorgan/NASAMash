//
//  EarthImagery+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension EarthImagery: JSONInitable {
    
    init?(json: JSON) {
        
        guard let id        = json[Key.id.rawValue] as? String,
              let rawDate   = json[Key.date.rawValue] as? NasaDateTime,
              let url       = json[Key.url.rawValue] as? String else {
            return nil
        }
        
        guard let dateTime = Date(nasaDateTime: rawDate) else { return nil }
        
        self.id = id
        self.dateTime = dateTime
        self.url = url
    }
}
