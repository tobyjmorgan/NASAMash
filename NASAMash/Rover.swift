//
//  Rover.swift
//  NASAMash
//
//  Created by redBred LLC on 2/22/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

enum Rover: String {
    case curiosity
    case opportunity
    case spirit
}

extension Rover {
    var cameras: [Camera] {
        switch self {
        case .curiosity:
            return [.FHAZ, .RHAZ, .MAST, .CHEMCAM, .MAHLI, .MARDI, .NAVCAM]
        case .opportunity, .spirit:
            return [.FHAZ, .RHAZ, .NAVCAM, .PANCAM, .MINITES]
        }
    }
}
