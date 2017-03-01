//
//  APODImage+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension APODImage: JSONInitable {
    
    init?(json: JSON) {
        
        guard let title             = json[Key.title.rawValue] as? String,
              let explanation       = json[Key.explanation.rawValue] as? String,
              let rawDate           = json[Key.date.rawValue] as? String,
              let hdUrl             = json[Key.hdurl.rawValue] as? String,
              let url               = json[Key.url.rawValue] as? String,
              let mediaType         = json[Key.media_type.rawValue] as? String,
              let serviceVersion    = json[Key.service_version.rawValue] as? String else {
            return nil
        }
        
        guard let date = Date(earthDate: rawDate) else { return nil }
        
        self.title = title
        self.explanation = explanation
        self.date = date
        self.hdUrl = hdUrl
        self.url = url
        self.mediaType = mediaType
        self.serviceVersion = serviceVersion
        
        if let copyright = json[Key.copyright.rawValue] as? String {
            self.copyright = copyright
        } else {
            self.copyright = nil
        }
    }
}

extension APODImage: Equatable { }

func == (lhs: APODImage, rhs: APODImage) -> Bool {
    return lhs.title == rhs.title && lhs.date == rhs.date
}
