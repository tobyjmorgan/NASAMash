//
//  APODViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import Photos

class APODViewController: UIViewController {

    let model = Model.shared
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var apodModeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(APODViewController.onChanges), name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(APODViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshApodMode()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
        
    }
    
    func onChanges() {
        collectionView.reloadData()
    }
    
    func refreshApodMode() {
        
        let apodMode = model.apodMode
        
        if apodMode.rawValue <= apodModeSegmentedControl.numberOfSegments {
            apodModeSegmentedControl.selectedSegmentIndex = apodMode.rawValue
        }
    }

    func onFavorite(indexPath: IndexPath) {
        
    }
    
    func onDownload(indexPath: IndexPath) {
        
        let apodImage = model.apodImages[indexPath.item]
        
        // make sure we have permission to save to the Photo Library
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            
            switch authorizationStatus {

            case .authorized:
                
                // only allow secure requests - if it fails then no image will show
                let secureURLString = apodImage.hdUrl.replacingOccurrences(of: "http://", with: "https://")
                
                // ok download image in the background
                UIImage.getImageAsynchronously(urlString: secureURLString) { (image) in
                    
                    guard let image = image else {
                        // failed to download image
                        let note = TJMApplicationNotification(title: "Oops!", message: "Unable to download high-definition image from the server", fatal: false)
                        note.postMyself()
                        return
                    }
                    
                    // success - save to Photo Library
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(APODViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }

            default:
                // we don't have permission, so notify the user that this feature can't be used
                let note = TJMApplicationNotification(title: "Oops!", message: "This app does not have permission to access your Photo Library. You can change this in Settings if you want download images in future", fatal: false)
                note.postMyself()
            }
        }
        
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    
        guard error == nil else {
            // failed to save image
            let note = TJMApplicationNotification(title: "Oops!", message: "Unable to save image to Photo Library", fatal: false)
            note.postMyself()
            return
        }
        
        // image saved successfully
        let note = TJMApplicationNotification(title: "Photo Saved!", message: "Image successfully saved to Photo Library", fatal: false)
        note.postMyself()
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.apodImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "APODCell", for: indexPath) as! APODCell
        
        cell.resetCell()
        
        let apodImage = model.apodImages[indexPath.item]
        
        cell.title.text = apodImage.title
        cell.imageURL = apodImage.url
        
        if let copyright = apodImage.copyright {
            cell.subtitle.text = copyright
        } else {
            cell.subtitle.text = ""
        }
        
        cell.onFavoriteClosure = { (cell) in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            
            self.onFavorite(indexPath: indexPath)
        }

        cell.onDownloadClosure = { (cell) in
            guard let indexPath = collectionView.indexPath(for: cell) else { return }
            
            self.onDownload(indexPath: indexPath)
        }

        return cell
    }
    
    
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        
        if indexPath.item == 0 {
            width = collectionView.frame.size.width
        } else {
            width = collectionView.frame.size.width/2
        }
        
        return CGSize(width: width, height: width/3*2)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDelegate {
    
    
}




//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension APODViewController {
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        guard let mode = APODMode(rawValue: sender.selectedSegmentIndex) else { return }
        
        model.apodMode = mode
    }
}




