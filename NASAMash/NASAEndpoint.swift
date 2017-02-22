//
//  NASAEndpoint.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum NASAEndpoint {
    case roverPhotosBySol(RoverRequestParameters)
    case roverPhotosByEarthDate(RoverRequestParameters)
}

// computed properties which get the path components we need based on the endpoint being used
extension NASAEndpoint: APIEndpoint {
    
    var baseURL: String {
        return "https://api.nasa.gov/mars-photos/api/v1/rovers/"
    }
    
    var path: String {
        
        switch self {
            
        case .roverPhotosBySol(let params), .roverPhotosByEarthDate(let params):
            return "\(params.rover.rawValue)/photos/"
        }
    }
    
    var parameters: HTTPParameters {
        
//        switch self {
//            
//        case .roverPhotosBySol(let params), .roverPhotosByEarthDate(let params) :
//            break
//        }
        
        return [:]
    }
}
