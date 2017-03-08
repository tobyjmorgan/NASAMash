//
//  EarthViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/8/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class EarthViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detailsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var noImage: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var saveButtonContainer: UIView!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var latitude: UITextField!
    @IBOutlet var longitude: UITextField!
    @IBOutlet var zoom: UITextField!
    @IBOutlet var zoomSlider: UISlider!
    @IBOutlet var currentLocationButtonContainer: UIView!
    @IBOutlet var mapSearchButtonContainer: UIView!
    @IBOutlet var fetchButton: UIButton!

    @IBAction func onSave() {
        // TODO: - create a GIF and save to Photo Library
    }
    
    @IBAction func onTimeSliderChanged(_ sender: Any) {
        fetchImageForSliderPosition()
    }
    
    @IBAction func onZoomSliderChanged(_ sender: Any) {
        // TODO: - disabled for now
    }
    
    @IBAction func onCurrentLocation() {
        // TODO: - look up position using Location Manager
    }
    
    @IBAction func onMapSearch(_ sender: Any) {
        // TODO: - push map view
    }
    
    @IBAction func onFetch() {
        model.fetchEarthImageAssetList(lat: 52.7229, lon: 4.0561, beginDate: "2000-01-01", endDate: Date().earthDate)
    }
    
    let model = Model.shared
    
    lazy var imageManager: ImageManager = {
        return ImageManager(containingView: self.view, imageView: self.imageView, activityIndicator: self.activityIndicator, noImagImageView: self.noImage, onImageLoaded: nil)
    }()
    
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

        saveButtonContainer.layer.cornerRadius = 3
        currentLocationButtonContainer.layer.cornerRadius = 3
        mapSearchButtonContainer.layer.cornerRadius = 3
        
        // TODO: - these are just default values for now
        zoom.text = "\(0.25)"
        zoomSlider.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onChanges), name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
    }

    func onChanges() {
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(model.earthImages.count - 1)
        timeSlider.value = Float(model.earthImages.count - 1)
        
       fetchImageForSliderPosition()
    }
    
    func fetchImageForSliderPosition() {
        
        let index = Int(timeSlider.value)
        
        guard model.earthImages.indices.contains(index) else { return }
        
        let earthImage = model.earthImages[index]
        
        imageManager.imageURL = earthImage.url
    }
}

//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension EarthViewController {
    
    @IBAction func onShowDetails() {
        // toggle controls
        showDetails = !showDetails
    }
}
