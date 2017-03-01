//
//  APODCell.swift
//  NASAMash
//
//  Created by redBred LLC on 3/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class APODCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var faveButton: UIButton!
    @IBOutlet var downloadButton: UIButton!
    
    var imageURL: String? = nil {
        didSet {
            // TODO: fetch the image (cached?)
        }
    }
}
