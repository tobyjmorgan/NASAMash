//
//  StarWarsAPIUseCase.swift
//  APIAwakens
//
//  Created by redBred LLC on 12/5/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

// some typealiases to make our code more readable
typealias PersonID = Int
typealias VehicleID = Int
typealias StarshipID = Int
typealias PlanetID = Int
typealias SWAPIURLString = String

// each way in which we can interact with our API client
enum StarWarsAPIUseCase {
    case people(PersonID?)
    case vehicles(VehicleID?)
    case starships(StarshipID?)
    case planets(PlanetID?)
    case nextPage(SWAPIURLString)
}

// computed properties which get the path components we need based on the
// use case being used
extension StarWarsAPIUseCase: APIUseCase {
    var baseURL: String {
        
        return "https://swapi.co/api/"
    }
    
    var path: String {
        
        switch self {
            
        case .people(let id):
            if let id = id {
                return "people/\(id)/"
            }
            
            return "people/"
            
        case .vehicles(let id):
            if let id = id {
                return "vehicles/\(id)/"
            }
            
            return "vehicles/"
            
        case .starships(let id):
            if let id = id {
                return "starships/\(id)/"
            }
            
            return "starships/"
            
        case .planets(let id):
            if let id = id {
                return "planets/\(id)/"
            }
            
            return "planets/"
            
        case .nextPage(let urlString):
            // extrapolate the request type (people, vehicles etc) by looking at 
            // the last path component
            let url = URL(string: urlString)!
            let lastPathComponent = url.lastPathComponent

            // we need the query bit on the end too
            let query = url.query!
            
            return "\(lastPathComponent)/?\(query)"
        }
    }
}

// extending with a method that returns the appropriate parser for
// the use case
extension StarWarsAPIUseCase {
    
    func getParser() -> (JSON) -> ResultsPage? {
        
        switch self {
        case .people(let id), .vehicles(let id), .starships(let id), .planets(let id):
            return { json in
                
                // are we calling with an id?
                if id != nil {
                    
                    // we will be getting one json item
                    return ResultsPage(nextPageURLString: nil, results: [json])
                    
                } else {
                    
                    // we will be getting an array of items
                    if let arrayOfItems = json["results"] as? [JSON] {
                        
                        // return a results page
                        let page = ResultsPage(nextPageURLString: json["next"] as? String, results: arrayOfItems)
                        return page
                        
                    } else {
                        
                        // malformed json data
                        return nil
                    }
                }
            }
            
        case .nextPage:
            return { json in
                
                // this was a next page request so it will always be a page of results
                if let arrayOfItems = json["results"] as? [JSON] {
                    let page = ResultsPage(nextPageURLString: json["next"] as? String, results: arrayOfItems)
                    return page
                } else {
                    return nil
                }
            }
        }
        
    }
}

// associating each entity context to a use case in our API client
extension EntityContext {
    var useCase: StarWarsAPIUseCase {
        switch self {
        case .characters:
            return .people(nil)
        case .vehicles:
            return .vehicles(nil)
        case .starships:
            return .starships(nil)
        }
    }
}

