//
//  AttributedStringDescription.swift
//  NASAMash
//
//  Created by redBred LLC on 3/5/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAttributes

protocol AttributedStringDescription {
    func attributedStringDescription(baseFontSize: CGFloat, headerColor: UIColor, bodyColor: UIColor) -> NSAttributedString
}

extension APODImage: AttributedStringDescription {
    
    func attributedStringDescription(baseFontSize: CGFloat, headerColor: UIColor, bodyColor: UIColor) -> NSAttributedString {
        
        let titleAS =
            "Title: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
                (title + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let dateAS =
            "Date: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
                (date.earthDate + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let explanationAS =
            "Explanation:\n".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (explanation + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        if let copyright = copyright {
            
            let copyrightAS =
                "Copyright: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
                    (copyright + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
            
            return titleAS + copyrightAS + dateAS + explanationAS
            
        } else {
            
            return titleAS + dateAS + explanationAS
        }
    }
}

extension RoverPhoto: AttributedStringDescription {
    
    func attributedStringDescription(baseFontSize: CGFloat, headerColor: UIColor, bodyColor: UIColor) -> NSAttributedString {
        
        let nameAS =
            "Rover: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (rover.name + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let cameraAS =
            "Camera: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (camera.fullName + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let dateAS =
            "Date Taken: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (earthDate + " (Sol: \(sol))\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let dividerAS =
            "---------------------------------------\nRover Details\n".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor)
        
        let launchAS =
            "Launch Date: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (rover.launchDate + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let landingAS =
            "Landing Date: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (rover.landingDate + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let statusAS =
            "Status: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (rover.status + "\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let maxDateAS =
            "Max Date: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            (rover.maxDate + " (Sol: \(rover.maxSol))\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        let totalPhotosAS =
            "Total Photos: ".withFont(.boldSystemFont(ofSize: baseFontSize)).withTextColor(headerColor) +
            ("\(rover.totalPhotos)\n").withFont(.systemFont(ofSize: 16)).withTextColor(bodyColor)
        
        return nameAS + cameraAS + dateAS + dividerAS + launchAS + landingAS + statusAS + maxDateAS + totalPhotosAS
    }
}
