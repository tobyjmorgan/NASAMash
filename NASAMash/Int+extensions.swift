//
//  Int+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 3/3/17.
//  Copyright © 2017 redBred. All rights reserved.
//


// thanks to: Ted van Gaalen
// http://stackoverflow.com/questions/24132399/how-does-one-make-random-number-between-range-for-arc4random-uniform

import Foundation

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.lowerBound < 0   // allow negative ranges
        {
            offset = abs(range.lowerBound)
        }
        
        let mini = UInt32(range.lowerBound + offset)
        let maxi = UInt32(range.upperBound + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
