//
//  EarthViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/8/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ImageWithDate: NSObject {
    
    let dateTaken: Date
    let image: UIImage
    
    init(image: UIImage, dateTaken: Date) {

        self.image = image
        self.dateTaken = dateTaken
        
        super.init()
    }
}

class EarthViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var saveButtonContainer: UIView!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var imageDateLabel: UILabel!
    @IBOutlet var deleteFrameButtonContainer: UIView!

    enum LeftOrRight: Int {
        case left = -1
        case right = 1
    }
    
    let model = ModelAccess.shared.model
    var selectedLocation: (Double, Double)?
    var images: [ImageWithDate] = []
    var imageFetchFails: Int = 0
        
    // will handle fetching location info
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButtonContainer.layer.cornerRadius = 3
        deleteFrameButtonContainer.layer.cornerRadius = 3
        
        activityIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onChanges), name: Notification.Name(Model.Notifications.earthImagesChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onStartProcessing), name: Notification.Name(Model.Notifications.earthImageAssetsProcessing.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onStopProcessing), name: Notification.Name(Model.Notifications.earthImageAssetsDoneProcessing.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(EarthViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        onFetch()
    }
    
    func onStartProcessing() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func onStopProcessing() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func onChanges() {
        
        clearOut()
        onStartProcessing()
        
        for earthImage in model.earthImages {
            
            UIImage.getImageAsynchronously(urlString: earthImage.url, completion: { [weak self] (image, error) in
                
                guard let goodSelf = self else { return }
                
                if let image = image {
                
                    let imageWithDate = ImageWithDate(image: image, dateTaken: earthImage.dateTime)
                    goodSelf.images.append(imageWithDate)
                    
                    goodSelf.images = goodSelf.images.sorted(by: { (firstImage, secondImage) -> Bool in
                        return firstImage.dateTaken < secondImage.dateTaken
                    })
                    
                } else {
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    goodSelf.imageFetchFails += 1
                }
                
                if (goodSelf.imageFetchFails + goodSelf.images.count) == ModelAccess.shared.model.earthImages.count {
                    
                    goodSelf.refreshSliderForCurrentImages(tryToUseIndex: nil)
    
                    goodSelf.onStopProcessing()
                }
            })
        }
        
    }
    
    func refreshSliderForCurrentImages(tryToUseIndex: Int?) {
        
        guard images.count > 0 else {
            timeSlider.value = 0
            timeSlider.isEnabled = false
            return
        }
        
        timeSlider.minimumValue = 0
        timeSlider.maximumValue = Float(self.images.count - 1)
        
        if let index = tryToUseIndex,
            images.indices.contains(index) {
            
            timeSlider.value = Float(index)
        
        } else {
            
            timeSlider.value = Float(self.images.count - 1)
        }

        timeSlider.isEnabled = true
        
        fetchImageForSliderPosition()
    }
    
    func fetchImageForSliderPosition() {
        
        let index = Int(timeSlider.value)
        
        guard images.indices.contains(index) else {
            imageView.image = UIImage()
            imageDateLabel.text = "Date: "
            return
        }
        
        imageView.image = images[index].image
        imageDateLabel.text = "Date: " + images[index].dateTaken.earthDate
    }
    
    func clearOut() {

        imageView.image = UIImage()
        imageDateLabel.text = "Date: "
        images = []
        timeSlider.isEnabled = false
        timeSlider.minimumValue = 0.0
        timeSlider.minimumValue = 1.0
        timeSlider.value = 0.5
    }
    
    func tryToMoveSlider(leftOrRight: LeftOrRight) {
        
        let sliderIndex = Int(timeSlider.value)
        let candidateIndex = sliderIndex + leftOrRight.rawValue
        
        guard images.indices.contains(candidateIndex) else { return }
        
        timeSlider.value = Float(candidateIndex)
        fetchImageForSliderPosition()
    }
    
    func onFetch() {
        
        clearOut()
        
        let location = model.getLastLocation()
        
        model.fetchEarthImageAssetList(lat: location.0, lon: location.1, beginDate: "2000-01-01", endDate: Date().earthDate)
    }
}





//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension EarthViewController {
    
    @IBAction func onEmailGIF() {
        
        guard MFMailComposeViewController.canSendMail() else {
            let note = TJMApplicationNotification(title: "Oops!", message: "Email services are not available on this device. Sorry.", fatal: false)
            note.postMyself()
            return
        }
        
        guard images.count > 0 else {
            let note = TJMApplicationNotification(title: "Oops!", message: "There are no images available to use!", fatal: false)
            note.postMyself()
            return
        }
        
        let alert = UIAlertController(title: "Animated GIF", message: "Do you want to create an animated time-lapse GIF and send it by email?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes!", style: .default) { [weak self ] (action) in
            
            guard let happySelf = self else { return }
                
            let flattenedImages = happySelf.images.flatMap { $0.image }
            
            guard let gifData = UIImage.createGIF(with: flattenedImages, loopCount: 10, frameDelay: 0.2) else {
                
                let note = TJMApplicationNotification(title: "Oops!", message: "There was a problem creating the GIF", fatal: false)
                note.postMyself()
                return
            }
            
            happySelf.sendEmail(imageData: gifData)
        }
        
        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onTimeSliderChanged(_ sender: Any) {
        fetchImageForSliderPosition()
    }
    
    @IBAction func onRemoveCurrentFrame() {
        
        let index = Int(timeSlider.value)
        
        guard images.indices.contains(index) else { return }
        
        images.remove(at: index)
        refreshSliderForCurrentImages(tryToUseIndex: index)
    }
    
    @IBAction func onBumpLeft() {
        tryToMoveSlider(leftOrRight: .left)
    }
    
    @IBAction func onBumpRight() {
        tryToMoveSlider(leftOrRight: .right)
    }
}




import MessageUI

extension EarthViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail(imageData: Data) {
        
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        
        mailVC.setSubject("Earth Image Time-Lapse")
        mailVC.addAttachmentData(imageData, mimeType: "image/gif", fileName: "EarthImageGIF.gif")
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .saved, .sent:
            controller.dismiss(animated: true, completion: { self.dismiss(animated: true, completion: nil) })
            
        case .failed:
            controller.dismiss(animated: true, completion: {
                let note = TJMApplicationNotification(title: "Nope!", message: "That didn't work for some reason: \(error?.localizedDescription)", fatal: false)
                note.postMyself()
            })
            
        case .cancelled:
            controller.dismiss(animated: true, completion: nil)
        }
    }
}




