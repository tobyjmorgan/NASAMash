//
//  DictionaryAddValuesFromDictionary.swift
//  MovieNight
//
//  Created by redBred LLC on 12/8/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func addValuesFromDictionary(dictionary:Dictionary) {
        for (key,value) in dictionary {
            self.updateValue(value, forKey:key)
        }
    }
}
