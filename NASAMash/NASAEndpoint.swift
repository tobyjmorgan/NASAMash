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
    
    var apiKey: String {
        return "GCPIr7WPD2SiwQwqWrddqNMJOFMvXkf57rhRX4sx"
    }
    
    var baseURL: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        
        switch self {
            
        case .roverPhotosBySol(let params), .roverPhotosByEarthDate(let params):
            return "/mars-photos/api/v1/rovers/\(params.rover.rawValue)/photos"
        }
    }
    
    var parameters: HTTPParameters {

        func getCommonRoverParams(_ requestParams: RoverRequestParameters) -> HTTPParameters {
            
            var parameters: HTTPParameters = [:]
            
            if let cameras = requestParams.cameras,
                cameras.count > 0 {

                let stringCameras: [String] = cameras.map { $0.rawValue }
                let concatenatedCameras = String.concatenateWithCommas(arrayOfItems: stringCameras)
                parameters[Key.camera.rawValue] = "\(concatenatedCameras)"
            }

            if let page = requestParams.page {
                parameters[Key.page.rawValue] = page
            }
            
            return parameters
        }
        
        var parameters: HTTPParameters = [:]
        
        // always need the api key
        parameters[Key.api_key.rawValue] = apiKey
        
        
        switch self {
            
        case .roverPhotosBySol(let requestParams) :
            
            if let sol = requestParams.sol {
                parameters[Key.sol.rawValue] = sol
            }
            
            parameters.addValuesFromDictionary(dictionary: getCommonRoverParams(requestParams))
            
        case .roverPhotosByEarthDate(let requestParams) :

            if let earthDate = requestParams.earthDate {
                parameters[Key.earth_date.rawValue] = earthDate
            }
            
            parameters.addValuesFromDictionary(dictionary: getCommonRoverParams(requestParams))
            
        }
        
        return parameters
    }
}
