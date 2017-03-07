//
//  PhotoViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/4/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    lazy var imageManager: ImageManager = {
        return ImageManager(containingView: self.view, imageView: self.imageView, activityIndicator: self.activityIndicator, noImagImageView: self.noImage) { [unowned self] (image) in
            
            self.imageView.bounds = self.imageView.bounds.changingOnlySize(size: image.size)
            self.view.layoutIfNeeded()
            self.setZoomScale()
            self.applyPadding()
        }
    }()

    var imageURLString: String? = nil
    var details: NSAttributedString? = nil

    var showDetails: Bool = true {
        didSet {
            // when value changes, makes sure controls are shown/hidden accordingly
            if showDetails {
                detailsViewBottomConstraint.constant = 0
            } else {
                detailsViewBottomConstraint.constant = -150
            }
            
            // this animates the changes to the constraint
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailsLabel: UITextView!
    @IBOutlet var detailsViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet var noImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.maximumZoomScale = 6.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // note that these steps need to happen AFTER subviews have been laid out
        setZoomScale()
        applyPadding()
        detailsLabel.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageManager.imageURL = imageURLString
        
        if let details = details,
           details.length > 0 {

            detailsLabel.attributedText = details
            detailsLabel.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UIScrollViewDelegate
extension PhotoViewController: UIScrollViewDelegate {
    
    func setZoomScale() {
        
        // here we calculate the ratios between the widths and heights
        // of the scroll view and image view
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        // now we choose the smallest since this will ensure the image is
        // scaled to Aspect Fit, if we chose the largest ratio, that
        // would give us Aspect Fill
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    func applyPadding() {
        
        // here we are essentially centering the image, by placing vertical
        // OR horizontal padding (whichever is needed). If we don't do this
        // then the image will stick to the top left corner of the
        // scroll view
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    // here we tell the scrollview what view we will be zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // when the zooming is complete, make sure it is centered, if
    // the whole image is visible
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        applyPadding()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // nothing yet
    }
}





//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension PhotoViewController {
    
    @IBAction func onShowDetails() {
        // toggle controls
        showDetails = !showDetails
    }
}
