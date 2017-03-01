//
//  Feature+extensions.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit

extension Feature {
    
    static var allValues: [Feature] {
        return [.astronomy, .earth, .rovers]
    }
    
    static var count: Int {
        return Feature.allValues.count
    }
    
    var description: String {
        switch self {
        case .astronomy:
            return "Astronomy Picture of the Day"
        case .earth:
            return "Earth Imagery"
        case .rovers:
            return "Mars Rovers"
        }
    }
    
    var largeIcon: UIImage {
        switch self {
        case .astronomy:
            return #imageLiteral(resourceName: "AstronomyIcon")
        case .earth:
            return #imageLiteral(resourceName: "EarthIcon")
        case .rovers:
            return #imageLiteral(resourceName: "RoversIcon")
        }
    }
    
    var smallIcon: String {
        switch self {
        case .astronomy:
            return "Astronomy Picture of the Day"
        case .earth:
            return "Earth Imagery"
        case .rovers:
            return "Mars Rovers"
        }
    }
}
