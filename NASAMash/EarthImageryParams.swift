//
//  EarthImageryParams.swift
//  NASAMash
//
//  Created by redBred LLC on 2/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

typealias Latitude = Double
typealias Longitude = Double
typealias BeginDate = NasaDate
typealias EndDate = NasaDate

struct EarthImageryParams {
    
    let lat: Latitude
    let lon: Longitude
    let dim: Double
    let date: NasaDate
    
    init(lat: Latitude, lon: Longitude, dim: Double?, date: NasaDate?) {
        
        self.lat = lat
        self.lon = lon
        
        if let date = date {
            self.date = date
        } else {
            self.date = Date().earthDate
        }
        
        if let dim = dim {
            self.dim = dim
        } else {
            self.dim = 0.025
        }        
    }
}
