//
//  APODViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class APODViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var apodModeSegmentedControl: UISegmentedControl!
    
    let model = ModelAccess.shared.model
    var lastTouchedIndexPath: IndexPath? = nil
    let scrollThresholdToTriggerFetch: CGFloat = 100
    
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
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
        
        collectionView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoViewController {
            
            guard let indexPath = lastTouchedIndexPath,
                  model.apodImages.indices.contains(indexPath.item) else { return }
            
            let apodImage = model.apodImages[indexPath.item]
            
            vc.photoVCMode = .apodImage
            
            if apodImage.mediaType == "image" {
                vc.imageURLString = apodImage.hdUrl
            }

            vc.details = apodImage.attributedStringDescription(baseFontSize: 14, headerColor: .green, bodyColor: .white)
            vc.apodImage = apodImage
        }
    }
    
    func configureCell(cell: APODCell, apodImage: APODImage, indexPath: IndexPath) {
        
        cell.title.text = apodImage.title
        
        // only do these parts if it is an image
        if apodImage.mediaType == "image" {
            
            cell.imageURL = apodImage.url
            
            
            // we provide the APODCell with a closure telling it what to do when the user
            // taps the download button
            cell.onDownloadClosure = { [weak self] (cell) in
                
                // get the index path for the cell if it exists
                // if it doesn't for some strange reason, then do nothing
                guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
                
                let model = ModelAccess.shared.model
                
                guard model.apodImages.indices.contains(indexPath.row) else { return }
                
                let apodImage = model.apodImages[indexPath.item]
                
                let alert = UIAlertController(title: "Download Image", message: "Do you want to download this image to your Photo Library?", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let save = UIAlertAction(title: "Save Image", style: .default) { [ weak self ] (action) in
                    
                    // go do the download processing
                    self?.onDownloadImage(urlString: apodImage.hdUrl)
                    
                    // disable the download button, so repeated downloads don't occur
                    cell.downloadButton.isEnabled = false
                }
                
                alert.addAction(cancel)
                alert.addAction(save)
                
                self?.present(alert, animated: true, completion: nil)
            }

        }
        
        if let copyright = apodImage.copyright {
            cell.subtitle.text = copyright
        } else {
            cell.subtitle.text = ""
        }
        
        cell.isFavorite = model.isFavoriteApod(apodImage: apodImage)
        
        // we provide the APODCell with a closure telling it what to do when the user
        // taps the favorite button
        cell.onFavoriteClosure = { [weak self] (cell) in
            
            // get the index path for the cell if it exists
            // if it doesn't for some strange reason, then do nothing
            guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
            
            let model = ModelAccess.shared.model
            
            // ensure the image exists in the model
            guard model.apodImages.indices.contains(indexPath.item) else { return }
            
            let apodImage = model.apodImages[indexPath.item]
            
            // check to see if it is already a favorite
            if model.isFavoriteApod(apodImage: apodImage) {
                
                // yes, so unfavorite it
                
                
                // if we are in favorites mode, do a little animation
                if model.apodMode == .favorites {
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        cell.alpha = 0.0
                    }, completion: { (result) in
                        model.removeApodFromFavorites(apodImage: apodImage)
                        cell.isFavorite = false
                    })

                } else {
                    
                    model.removeApodFromFavorites(apodImage: apodImage)
                    cell.isFavorite = false
                }
                
            } else {
                
                // no so favorite it
                model.addApodToFavorites(apodImage: apodImage)
                cell.isFavorite = true
            }
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
        configureCell(cell: cell, apodImage: apodImage, indexPath: indexPath)
        cell.setNeedsDisplay()
        
        return cell
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegateFlowLayout
extension APODViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        
        if model.apodMode == .latest {
            
            if indexPath.item == 0 {
                width = collectionView.frame.size.width
            } else {
                width = collectionView.frame.size.width/2
            }

        } else {
            
            width = collectionView.frame.size.width/2
        }
        
        return CGSize(width: width, height: width/3*2)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegate
extension APODViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lastTouchedIndexPath = indexPath
        performSegue(withIdentifier: "ShowPhoto", sender: self)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension APODViewController {
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        guard let mode = APODMode(rawValue: sender.selectedSegmentIndex) else { return }
        
        model.apodMode = mode
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UIScrollViewDelegate
extension APODViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard model.apodMode == .latest else { return }
        
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !model.working && (maximumOffset - contentOffset <= scrollThresholdToTriggerFetch) {

            // Get more data - API call
            model.fetchMoreLatestAPODImages()
        }
    }
}



