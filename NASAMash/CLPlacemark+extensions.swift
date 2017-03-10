//
//  CLPlacemark+extensions.swift
//  HereUGo
//
//  Created by redBred LLC on 2/14/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    
    // provides a pretty concatenation of placemark address elements
    public var prettyDescription: String {
        
        var address : String?
        
        if let name = self.name {
            address?.append(name)
        }
        
        if let addrList = self.addressDictionary?["FormattedAddressLines"] as? [String] {
            address =  addrList.joined(separator: ", ")
        }
        
        return address ?? ""
    }
}
