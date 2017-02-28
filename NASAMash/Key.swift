//
//  Key.swift
//  MovieNight
//
//  Created by redBred LLC on 12/7/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

enum Key: HTTPKey {

    case api_key
    
    // Rover API
    case sol
    case earth_date
    case camera
    case page
    case photos
    case id
    case rover_id
    case name
    case full_name
    case img_src
    case rover
    case landing_date
    case launch_date
    case status
    case max_sol
    case max_date
    case total_photos
    case cameras
    case photo_manifest
    case rovers
    
    // Earth Imagery API
    case lat
    case lon
    case dim
    case date
    case cloud_score
    case url
    case count
    case results
    case begin
    case end
    
    
    // APOD API
    case hd
    case explanation
    case hdurl
    case media_type
    case service_version
    case title
}
