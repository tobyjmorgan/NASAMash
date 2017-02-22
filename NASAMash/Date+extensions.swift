//
//  Date+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

typealias NasaDate = String

extension Date {
    var earthDate: NasaDate {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    init?(earthDate: NasaDate) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let newDate = formatter.date(from: earthDate) else { return nil }
        
        self.init(timeInterval:0, since:newDate)
    }
}
