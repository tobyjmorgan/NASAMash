//: Playground - noun: a place where people can play

import UIKit

typealias JSON = [String : AnyObject]
typealias HTTPKey = String
typealias HTTPParameters = [HTTPKey : Any]


// anything that can be instantiated from JSON (failable intializer)
protocol JSONInitable {
    init?(json: JSON)
}

protocol ListParseable: JSONInitable {
    static var listKey: HTTPKey { get }
    static func listParser(json: JSON) -> [Self]?
}

extension ListParseable {
    
    static func listParser(json: JSON) -> [Self]? {
        
        guard let results = json[Self.listKey] as? [JSON] else {
            return nil
        }
        
        var array: [Self] = []
        
        for result in results {
            
            guard let item = Self(json: result) else {
                return nil
            }
            
            array.append(item)
        }
        
        return array
    }
}


struct RoverPhoto {
    
    let id: Int
}

extension RoverPhoto: ListParseable {
    
    init?(json: JSON) {
        
        guard let id = json["id"] as? Int else {
            return nil
        }
        
        self.id = id
    }
    
    static var listKey: HTTPKey {
        return "photos"
    }
}

//func getParser() -> (JSON) -> [JSONInitable]? {
//    
//    let parser: (JSON) -> [RoverPhoto]? = RoverPhoto.listParser
//    return parser
//}

