//
//  RepointerViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/5/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class RepointerViewController: UIViewController {

    var feature: Feature? = nil {
        didSet {
            if let nav = navigationController,
                let feature = feature {
                
                switch feature {
                case .astronomy:
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "AstronomyVC") {
                        nav.viewControllers[0] = vc
                    }
                    
                case .earth:
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "LocationVC") as? LocationViewController {
                        
                        let lastLocation = ModelAccess.shared.model.getLastLocation()

                        if lastLocation.0 != 0 && lastLocation.1 != 0 {
                        
                            vc.initialLocation = lastLocation
                        }
                        
                        nav.viewControllers[0] = vc
                    }
                    
                case .rovers:
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "RoverPhotosVC") {
                        nav.viewControllers[0] = vc
                    }
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(FeatureViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
        
    }
}
