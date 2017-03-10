//
//  NASAEarthImageryEndpoint.swift
//  NASAMash
//
//  Created by redBred LLC on 2/27/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum NASAEarthImageryEndpoint {
    case getImageForLocation(EarthImageryParams)
    case getAssets(Latitude, Longitude, BeginDate, EndDate)
    case getImageForID(String)
}

// computed properties which get the path components we need based on the endpoint being used
extension NASAEarthImageryEndpoint: APIEndpoint {
    
    var apiKey: String {
        return "IIvXddHXar46wtlvGKsGPLXppK98e6qG3yVocF3O"
    }
    
    var baseURL: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .getImageForLocation, .getImageForID:
            return "/planetary/earth/imagery"
        case .getAssets:
            return "/planetary/earth/assets"
        }
    }
    
    var parameters: HTTPParameters {
        
        var parameters: HTTPParameters = [:]
        
        // always need the api key
        parameters[Key.api_key.rawValue] = apiKey
        
        
        switch self {
        case .getAssets(let lat, let lon, let beginDate, let endDate):
            parameters[Key.lat.rawValue] = lat
            parameters[Key.lon.rawValue] = lon
            parameters[Key.begin.rawValue] = beginDate
            parameters[Key.end.rawValue] = endDate
            
        case .getImageForLocation(let params):
            parameters[Key.lat.rawValue] = params.lat
            parameters[Key.lon.rawValue] = params.lon
// Not working in API            parameters[Key.dim.rawValue] = params.dim
            parameters[Key.date.rawValue] = params.date
//            parameters[Key.cloud_score.rawValue] = true
            
        case .getImageForID(let id):
            parameters[Key.id.rawValue] = id
            
        }
        
        return parameters
    }
}

extension NASAEarthImageryEndpoint {
    
    static var assetsParser: (JSON) -> [EarthImageAsset]? {
        return EarthImageAsset.listParser
    }    
}
