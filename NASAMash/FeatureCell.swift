//
//  FeatureCell.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class FeatureCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet var frameView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        frameView.layer.cornerRadius = frameView.layer.frame.size.height/4
        frameView.layer.borderColor = UIColor.white.cgColor
        frameView.layer.borderWidth = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        contentView.backgroundColor = UIColor.clear
        
        if selected {
            frameView.backgroundColor = UIColor.lightGray
        } else {
            frameView.backgroundColor = UIColor.clear
        }
    }

    
}
