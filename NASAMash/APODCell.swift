//
//  APODCell.swift
//  NASAMash
//
//  Created by redBred LLC on 3/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import SAMCache

class APODCell: UICollectionViewCell {
    
    enum ImageState {
        case lookingForImage
        case noImageFound
        case imageFound
    }
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var subtitle: UILabel!
    @IBOutlet var noImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyHeart: UIImageView!
    @IBOutlet var fullHeart: UIImageView!
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var faveButton: UIButton!
    
    @IBAction func onFavorite() {
        onFavoriteClosure?(self)
    }
    
    @IBAction func onDownload() {
        onDownloadClosure?(self)
    }

    var onFavoriteClosure: ((UICollectionViewCell) -> Void)? = nil
    var onDownloadClosure: ((UICollectionViewCell) -> Void)? = nil
    
    var imageState: ImageState = .lookingForImage {
        didSet {
            refreshForImageState(newImageState: imageState)
        }
    }
    
    var imageURL: String? = nil {
        didSet {

            // only try to fetch image if the url is non-nil
            guard let imageURL = imageURL else {
                imageState = .noImageFound
                return
            }
            
            fetchImage(newImageUrl: imageURL)
        }
    }
    
    func resetCell() {
        image.image = UIImage()
        imageURL = nil
        title.text = ""
        subtitle.text = ""
        onFavoriteClosure = nil
        onDownloadClosure = nil
    }
    
    func refreshForImageState(newImageState: ImageState) {
        
        switch newImageState {
            
        case .lookingForImage:
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
            noImage.isHidden = true
            image.isHidden = true
            downloadButton.isEnabled = false
            faveButton.isEnabled = false
            
        case .noImageFound:
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            noImage.isHidden = false
            image.isHidden = true
            downloadButton.isEnabled = false
            faveButton.isEnabled = false
            
        case .imageFound:
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            noImage.isHidden = true
            image.isHidden = false
            downloadButton.isEnabled = true
            faveButton.isEnabled = true
            
        }
    }
    
    func fetchImage(newImageUrl: String) {
        
        imageState = .lookingForImage
        
        // only allow secure requests - if it fails then no image will show
        let secureURLString = newImageUrl.replacingOccurrences(of: "http://", with: "https://")
        
        if let cachedImage = SAMCache.shared().image(forKey: secureURLString) {
            
            image.image = cachedImage
            imageState = .imageFound
            
        } else {
            
            UIImage.getImageAsynchronously(urlString: secureURLString) { image in
                
                guard let image = image else {
                    self.imageState = .noImageFound
                    return
                }
                
                self.image.image = image
                SAMCache.shared().setImage(image, forKey: secureURLString)
                self.imageState = .imageFound
            }
        }
        
        setNeedsDisplay()
    }
}

