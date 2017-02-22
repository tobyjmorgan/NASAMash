//
//  String+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

extension String {
    
    static func concatenateWithCommas(arrayOfItems: [CustomStringConvertible]) -> String {
        
        var returnString = ""
        
        for item in arrayOfItems {
            
            if returnString == "" {
                
                returnString += "\(item)"
                
            } else {
                
                returnString += ", \(item)"
            }
        }
        
        return returnString
    }
}
