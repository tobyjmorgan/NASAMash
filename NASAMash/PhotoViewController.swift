//
//  PhotoViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/4/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

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
    @IBOutlet var downloadButton: UIButton!
    @IBOutlet var faveButton: UIButton!
    @IBOutlet var fullHeartImageView: UIImageView!
    @IBOutlet var postcardButton: UIButton!
    
    enum PhotoVCMode {
        case notSet
        case apodImage
        case roverPhoto
    }
    
    lazy var imageManager: ImageManager = {
        return ImageManager(containingView: self.view, imageView: self.imageView, activityIndicator: self.activityIndicator, noImagImageView: self.noImage) { [unowned self] (image) in
            
            self.imageView.bounds = self.imageView.bounds.changingOnlySize(size: image.size)
            self.view.layoutIfNeeded()
            self.setZoomScale()
            self.applyPadding()
        }
    }()

    let model = ModelAccess.shared.model
    var photoVCMode: PhotoVCMode = .notSet
    var imageURLString: String? = nil
    var details: NSAttributedString? = nil
    var apodImage: APODImage? = nil
    
    var isFavorite: Bool = false {
        didSet {
            refreshFavorite()
        }
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.maximumZoomScale = 6.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
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
        
        refreshSpecialButtons()
        
        if let apodImage = apodImage {
            if model.isFavoriteApod(apodImage: apodImage) {
                isFavorite = true
            }
        }
        
        if let details = details,
           details.length > 0 {

            detailsLabel.attributedText = details
            detailsLabel.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PostcardViewController {
            vc.imageURLString = imageURLString
        }
    }
    
    func refreshFavorite() {
        
        if isFavorite {
            
            // show the beating heart animation
            fullHeartImageView.isHidden = false
            
            // replace the button image with an empty image
            faveButton.setImage(UIImage(), for: .normal)
            
            startHeartAnimation()
            
        } else {
            
            // hide the beating heart N.B. couldn't find a good way of stopping the beating heart animation
            fullHeartImageView.isHidden = true
            
            // ensure the button image is the empty heart image
            faveButton.setImage(#imageLiteral(resourceName: "EmptyHeart"), for: .normal)
        }
        
        view.setNeedsDisplay()
    }
    
    func startHeartAnimation() {
        // start the heartbeat animation
        
        fullHeartImageView.layer.removeAllAnimations()
        
        let throb = CAKeyframeAnimation(keyPath: "transform.scale")
        throb.values = [ 1.0, 0.8, 1.0 ]
        throb.keyTimes = [ NSNumber(floatLiteral: 0.0), NSNumber(floatLiteral: 0.5), NSNumber(floatLiteral: 1.0)]
        throb.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        throb.repeatCount = 1000
        throb.duration = 1.0
        fullHeartImageView.layer.add(throb, forKey: "throb")
    }

    func refreshSpecialButtons() {
        
        switch photoVCMode {
        case .apodImage:
            postcardButton.isHidden = true
            faveButton.isHidden = false
            refreshFavorite()
        case .roverPhoto:
            postcardButton.isHidden = false
            faveButton.isHidden = true
            fullHeartImageView.isHidden = true
        default:
            break
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
    
    @IBAction func onPostcard() {
        performSegue(withIdentifier: "ShowPostcard", sender: self)
    }
    
    @IBAction func onFave() {

        guard let apodImage = apodImage else { return }
                
        // check to see if it is already a favorite
        if model.isFavoriteApod(apodImage: apodImage) {
            
            // yes, so unfavorite it
            model.removeApodFromFavorites(apodImage: apodImage)
            isFavorite = false
            
        } else {
            
            // no so favorite it
            model.addApodToFavorites(apodImage: apodImage)
            isFavorite = true
        }
    }
    
    @IBAction func onDownload() {
        
        let alert = UIAlertController(title: "Download Image", message: "Do you want to download this image to your Photo Library?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let save = UIAlertAction(title: "Save Image", style: .default) { [ weak self ] (action) in
            
            guard let happySelf = self else { return }
            
            // go do the download processing
            happySelf.onDownloadImage(urlString: happySelf.imageURLString)
            
            // disable the download button, so repeated downloads don't occur
            happySelf.downloadButton.isEnabled = false
        }
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        present(alert, animated: true, completion: nil)
    }
}
