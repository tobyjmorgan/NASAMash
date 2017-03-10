//
//  ImageManager.swift
//  NASAMash
//
//  Created by redBred LLC on 3/5/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import UIKit
import SAMCache

class ImageManager: NSObject {

    enum ImageState {
        case lookingForImage
        case noImageFound
        case imageFound
    }
    
    let containingView: UIView
    let imageView: UIImageView
    var activityIndicator: UIActivityIndicatorView? = nil
    var noImagImageView: UIImageView? = nil
    var onImageLoaded: ((UIImage) -> ())? = nil
    
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
    
    init(containingView: UIView, imageView: UIImageView, activityIndicator: UIActivityIndicatorView?, noImagImageView: UIImageView?, onImageLoaded: ((UIImage) -> ())?) {
        
        // mandatory
        self.containingView = containingView
        self.imageView = imageView
        
        super.init()
        
        // optional
        self.activityIndicator = activityIndicator
        self.noImagImageView = noImagImageView
        self.onImageLoaded = onImageLoaded
    }
    
    private func fetchImage(newImageUrl: String) {
        
        imageState = .lookingForImage
        
        // only allow secure requests - if it fails then no image will show
        let secureURLString = newImageUrl.replacingOccurrences(of: "http://", with: "https://")
        
        if let cachedImage = SAMCache.shared().image(forKey: secureURLString) {
            
            imageView.image = cachedImage
            imageState = .imageFound
            containingView.setNeedsDisplay()
            
            onImageLoaded?(cachedImage)
            
        } else {
            
            UIImage.getImageAsynchronously(urlString: secureURLString) { (image, error) in
                
                guard let image = image else {
                    self.imageState = .noImageFound
                    return
                }
                
                self.imageView.image = image
                SAMCache.shared().setImage(image, forKey: secureURLString)
                self.imageState = .imageFound
                self.containingView.setNeedsDisplay()
                
                self.onImageLoaded?(image)
            }
        }
        
    }

    func refreshForImageState(newImageState: ImageState) {
        
        switch newImageState {
            
        case .lookingForImage:
            activityIndicator?.startAnimating()
            activityIndicator?.isHidden = false
            noImagImageView?.isHidden = true
            imageView.isHidden = true
            
        case .noImageFound:
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            noImagImageView?.isHidden = false
            imageView.isHidden = true
            
        case .imageFound:
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            noImagImageView?.isHidden = true
            imageView.isHidden = false
            
        }
    }
}
