//
//  Camera+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension Camera: JSONInitable {
    
    init?(json: JSON) {
        
        guard let name  = json[Key.name.rawValue] as? CameraName,
            let fullName  = json[Key.full_name.rawValue] as? String else {
                return nil
        }
        
        self.name = name
        self.fullName = fullName
    }
}

