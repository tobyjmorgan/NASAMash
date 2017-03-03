//
//  RoverPhotosViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/3/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class RoverPhotosViewController: UIViewController {

    let model = Model.shared
    
    var showSearchControls: Bool = false {
        didSet {
            // when value changes, makes sure controls are shown/hidden accordingly
            if showSearchControls {
                searchControlsBottomConstraint.constant = 0
            } else {
                searchControlsBottomConstraint.constant = -120
            }
            
            // this animates the changes to the constraint
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var roverModeSegmentedControl: UISegmentedControl!

    @IBOutlet var searchControlsContainer: UIView!
    @IBOutlet var searchControlsButton: UIButton!
    
    @IBOutlet var searchControlsRoverPicker: UIPickerView!
    @IBOutlet var searchControlsSeg: UISegmentedControl!
    @IBOutlet var searchControlsDateLabel: UILabel!
    @IBOutlet var searchControlsSlider: UISlider!
    @IBOutlet var searchControlsPickerViewContainer: UIView!
    
    @IBOutlet var searchControlsRoverLabelContainer: UIView!
    @IBOutlet var searchControlsBottomConstraint: NSLayoutConstraint!
    
    @IBAction func onSearchControlsButton() {
        guard model.roverMode == .search else { return }
        
        // toggle controls
        showSearchControls = !showSearchControls
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchControlsContainer.isHidden = true
        searchControlsPickerViewContainer.layer.cornerRadius = 10
        searchControlsRoverLabelContainer.layer.cornerRadius = 3
        
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onChanges), name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onRoverChanges), name: Notification.Name(Model.Notifications.roversChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
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
    
    func configureCell(cell: APODCell, roverPhoto: RoverPhoto, indexPath: IndexPath) {
        
        cell.title.text = roverPhoto.rover.name
        cell.imageURL = roverPhoto.imageURL
        
        cell.subtitle.text = roverPhoto.camera.fullName
        
        
        // we provide the APODCell with a closure telling it what to do when the user
        // taps the favorite button
//        cell.onFavoriteClosure = { [weak self] (cell) in
//            
//            // get the index path for the cell if it exists
//            // if it doesn't for some strange reason, then do nothing
//            guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
//            
//            let model = Model.shared
//            
//            // unwrap weak self and get the image information
//            guard model.roverPhotos.indices.contains(indexPath.item) else { return }
//            
//            let apodImage = model.roverPhotos[indexPath.item]
//            
//            // check to see if it is already a favorite
//            if model.isFavoriteRoverPhoto(roverPhoto: roverPhoto) {
//                
//                // yes, so unfavorite it
//                model.removeRoverPhotoFromFavorites(roverPhoto: roverPhoto)
//                cell.isFavorite = false
//                
//            } else {
//                
//                // no so favorite it
//                model.addRoverPhotoToFavorites(roverPhoto: roverPhoto)
//                cell.isFavorite = true
//            }
//        }
        
        // we provide the APODCell with a closure telling it what to do when the user
        // taps the download button
        cell.onDownloadClosure = { [weak self] (cell) in
            
            // get the index path for the cell if it exists
            // if it doesn't for some strange reason, then do nothing
            guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
            
            let model = Model.shared
            
            guard model.roverPhotos.indices.contains(indexPath.row) else { return }
            
            let roverPhoto = model.roverPhotos[indexPath.item]
            
            // go do the download processing and disable the download button, so repeated downloads don't occur
            self?.onDownload(urlString: roverPhoto.imageURL)
            
            cell.downloadButton.isEnabled = false
        }
    }
    
    func onChanges() {
        collectionView.reloadData()
    }
    
    func onRoverChanges() {
        searchControlsRoverPicker.reloadAllComponents()
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension RoverPhotosViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.roverPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "APODCell", for: indexPath) as! APODCell
        
        cell.resetCell()
        
        let roverPhoto = model.roverPhotos[indexPath.item]
        configureCell(cell: cell, roverPhoto: roverPhoto, indexPath: indexPath)
        cell.setNeedsDisplay()
        
        return cell
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegateFlowLayout
extension RoverPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width/3
        
        return CGSize(width: width, height: width/3*2)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegate
extension RoverPhotosViewController: UICollectionViewDelegate {
    
    
}




//////////////////////////////////////////////////////////////
// MARK: - UIPickerViewDataSource
extension RoverPhotosViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.rovers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return model.rovers[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: model.rovers[row].name, attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }
}



//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension RoverPhotosViewController {
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        guard let mode = RoverMode(rawValue: sender.selectedSegmentIndex) else { return }

        model.roverMode = mode
        
        if mode == .search {
            showSearchControls = true
            searchControlsContainer.isHidden = false
        } else {
            showSearchControls = false
            searchControlsContainer.isHidden = true
        }
    }
}
