//
//  NASARoverEndpoint.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum NASARoverEndpoint {
    case rovers
    case roverPhotosBySol(RoverRequestParameters)
    case roverPhotosByEarthDate(RoverRequestParameters)
    case manifest(RoverName)
}

// computed properties which get the path components we need based on the endpoint being used
extension NASARoverEndpoint: APIEndpoint {
    
    var apiKey: String {
        return "GCPIr7WPD2SiwQwqWrddqNMJOFMvXkf57rhRX4sx"
    }
    
    var baseURL: String {
        return "https://api.nasa.gov"
    }
    
    var path: String {
        
        switch self {
            
        case .rovers:
            return "/mars-photos/api/v1/rovers/"
            
        case .roverPhotosBySol(let params), .roverPhotosByEarthDate(let params):
            return "/mars-photos/api/v1/rovers/\(params.roverName)/photos"
            
        case .manifest(let roverName):
            return "/mars-photos/api/v1/manifests/\(roverName)"
            
        }
    }
    
    var parameters: HTTPParameters {

        func getCommonRoverParams(_ requestParams: RoverRequestParameters) -> HTTPParameters {
            
            var parameters: HTTPParameters = [:]
            
            if let cameras = requestParams.cameras,
                cameras.count > 0 {

                let concatenatedCameras = String.concatenateWithCommas(arrayOfItems: cameras)
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
            
        case .rovers, .manifest:
            // no parameters other than api_key
            break
        }
        
        return parameters
    }
}

extension NASARoverEndpoint {
    
    static var roversParser: (JSON) -> [Rover]? {
        return Rover.listParser
    }

    static var photosParser: (JSON) -> [RoverPhoto]? {
        return RoverPhoto.listParser
    }
    
    static var manifestParser: (JSON) -> [Manifest]? {
        
        func parseManifest(json: JSON) -> [Manifest]? {
            
            guard let manifestsJSON = json[Key.photo_manifest.rawValue] as? JSON,
                  let manifests     = Manifest.listParser(json: manifestsJSON) else {
                return nil
            }
            
            return manifests
        }
        
        return parseManifest
    }
    
    // conforming closures cannot be returned from functions (and cannot cast a closure)
//    var parser: (JSON) -> [JSONInitable]? {
//        switch self {
//        case .rovers:
//            let roversParser = Rover.listParser
//            return roversParser
//        }
//    }
}
