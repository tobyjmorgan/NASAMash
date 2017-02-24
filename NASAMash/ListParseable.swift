//
//  ListParseable.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

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
