//
//  JSONInitable.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

// anything that can be instantiated from JSON (failable intializer)
protocol JSONInitable {
    init?(json: JSON)
}

