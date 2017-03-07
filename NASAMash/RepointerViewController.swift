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
                    break
                    
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

        // Do any additional setup after loading the view.
    }
}
