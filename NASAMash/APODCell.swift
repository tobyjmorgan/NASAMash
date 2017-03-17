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
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var faveButton: UIButton!
    @IBOutlet var fullHeartImage: UIImageView!
    
    @IBAction func onFavorite() {
        onFavoriteClosure?(self)
    }
    
    @IBAction func onDownload() {
        onDownloadClosure?(self)
    }

    // closures that get called when the favorite / download buttons get tapped
    var onFavoriteClosure: ((APODCell) -> Void)? = nil
    var onDownloadClosure: ((APODCell) -> Void)? = nil
    
    var isFavorite: Bool = false {
        didSet {
            refreshFavorite()
        }
    }
    
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
    
    func startHeartAnimation() {
        // start the heartbeat animation
        
        fullHeartImage.layer.removeAllAnimations()
        
        let throb = CAKeyframeAnimation(keyPath: "transform.scale")
        throb.values = [ 1.0, 0.8, 1.0 ]
        throb.keyTimes = [ NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 0.5), NSNumber(floatLiteral: 1.0)]
        throb.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        throb.repeatCount = 1000
        throb.duration = 1.0
        fullHeartImage.layer.add(throb, forKey: "throb")
        
    }
    
    func resetCell() {
        image.image = UIImage()
        imageURL = nil
        title.text = ""
        subtitle.text = ""
        onFavoriteClosure = nil
        onDownloadClosure = nil
        isFavorite = false
        
        // restore after possible transformations due to animation
        alpha = 1.0
        transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        setNeedsDisplay()
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
            
            UIImage.getImageAsynchronously(urlString: secureURLString) { [ weak self ] (image, error) in
                
                guard let goodSelf = self else { return }
                
                guard let image = image else {
                    goodSelf.imageState = .noImageFound
                    return
                }
                
                goodSelf.image.image = image
                SAMCache.shared().setImage(image, forKey: secureURLString)
                goodSelf.imageState = .imageFound
            }
        }
        
        setNeedsDisplay()
    }
    
    func refreshFavorite() {
        
        if isFavorite {

            // show the beating heart animation
            fullHeartImage.isHidden = false
            
            // replace the button image with an empty image
            faveButton.setImage(UIImage(), for: .normal)
            
            startHeartAnimation()
            
        } else {
            
            // hide the beating heart N.B. couldn't find a good way of stopping the beating heart animation
            fullHeartImage.isHidden = true
            
            // ensure the button image is the empty heart image 
            faveButton.setImage(#imageLiteral(resourceName: "EmptyHeart"), for: .normal)
        }
        
        setNeedsDisplay()
    }
}

