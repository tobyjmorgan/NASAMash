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
    
    let rover: Rover
    let sol: Sol?
    let earthDate: EarthDate?
    let cameras: [Camera]?
    let page: Page?
    
    init?(rover: Rover, sol: Sol?, earthDate: Date?, cameras: [Camera]?, page: Page?) {
        
        // sol and earthdate cannot both be nil
        guard !(sol == nil && earthDate == nil) else { return nil }
        
        self.rover = rover
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

