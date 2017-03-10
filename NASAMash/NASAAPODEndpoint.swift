//
//  NASAAPODEndpoint.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum NASAAPODEndpoint {
    case getAPODImage(NasaDate)
}

// computed properties which get the path components we need based on the endpoint being used
extension NASAAPODEndpoint: APIEndpoint {
    
    var apiKey: String {
        return "IIvXddHXar46wtlvGKsGPLXppK98e6qG3yVocF3O"
    }
    
    var baseURL: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        switch self {
        case .getAPODImage:
            return "/planetary/apod"
        }
    }
    
    var parameters: HTTPParameters {
        
        var parameters: HTTPParameters = [:]
        
        // always need the api key
        parameters[Key.api_key.rawValue] = apiKey
        
        
        switch self {
        case .getAPODImage(let nasaDate):
            parameters[Key.date.rawValue] = nasaDate
            parameters[Key.hd.rawValue] = true
        }
        
        return parameters
    }
}
