//
//  RoverPhotoCell.swift
//  NASAMash
//
//  Created by redBred LLC on 3/6/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class RoverPhotoCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cameraLabel: UILabel!
    @IBOutlet var noImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var postcardButton: UIButton!
    @IBOutlet var downloadButton: UIButton!

    lazy var imageManager: ImageManager = {
        return ImageManager(containingView: self, imageView: self.imageView, activityIndicator: self.activityIndicator, noImagImageView: self.noImage) { [unowned self] (image) in
            
            self.postcardButton.isEnabled = true
            self.downloadButton.isEnabled = true
        }
    }()
    
    @IBAction func onPostcard() {
        onPostcardClosure?(self)
    }
    
    @IBAction func onDownload() {
        onDownloadClosure?(self)
    }
    
    var onPostcardClosure: ((RoverPhotoCell) -> Void)? = nil
    var onDownloadClosure: ((RoverPhotoCell) -> Void)? = nil
    
    var imageURL: String? = nil {
        didSet {
            
            // only try to fetch image if the url is non-nil
            guard let imageURL = imageURL else {
                imageManager.imageState = .noImageFound
                return
            }
            
            imageManager.imageURL = imageURL
        }
    }
    
    func resetCell() {
        imageView.image = UIImage()
        imageURL = nil
        dateLabel.text = ""
        cameraLabel.text = ""
        onDownloadClosure = nil
        setNeedsDisplay()
    }
}
