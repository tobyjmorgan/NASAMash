//
//  HasListParser.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

protocol HasListParser {
    static var listKey: HTTPKey { get }
    static func listParser<T: JSONInitable & HasListParser>(json: JSON) -> [T]?
}

extension HasListParser {
    
    static var listKey: HTTPKey {
        return "items"
    }
    
    static func listParser<T: JSONInitable & HasListParser>(json: JSON) -> [T]? {
        
        guard let results = json[T.listKey] as? [JSON] else {
            return nil
        }
        
        var array: [T] = []
        
        for result in results {
            
            guard let item = T(json: result) else {
                return nil
            }
            
            array.append(item)
        }
        
        return array
    }
}

