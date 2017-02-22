//
//  RoverRequestParameters.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

typealias Sol = Int
typealias Page = Int
typealias EarthDate = String

struct RoverRequestParameters {
    
    let roverName: RoverName
    let sol: Sol?
    let earthDate: EarthDate?
    let cameras: [CameraName]?
    let page: Page?
    
    init?(roverName: RoverName, sol: Sol?, earthDate: Date?, cameras: [CameraName]?, page: Page?) {
        
        // sol and earthdate cannot both be nil
        guard !(sol == nil && earthDate == nil) else { return nil }
        
        self.roverName = roverName
        self.sol = sol
        self.cameras = cameras
        self.page = page
        
        // if the date was passed in, convert into the string format expected
        if let date = earthDate {
            
            self.earthDate = date.earthDate
            
        } else {
            
            self.earthDate = nil
        }
    }
}

