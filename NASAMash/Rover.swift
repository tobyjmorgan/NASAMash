//
//  Rover.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

typealias RoverName = String

struct Rover {
    
    let id: Int
    let name: RoverName
    let landingDate: NasaDate
    let launchDate: NasaDate
    let status: String
    let maxSol: Sol
    let maxDate: NasaDate
    let totalPhotos: Int
    let cameras: [Camera]
}
