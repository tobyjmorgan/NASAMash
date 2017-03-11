//
//  RoverPhotosViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/3/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import SwiftyAttributes

class RoverPhotosViewController: UIViewController {

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
    @IBOutlet var searchControlsPhotoCountLabel: UILabel!
    @IBOutlet var searchControlsFetchButton: UIButton!
    @IBOutlet var searchControlsFetchButtonContainer: UIView!
    @IBOutlet var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var showHideSearchControls: UIButton!
    
    let model = ModelAccess.shared.model
    
    var minimizeSearchControls: Bool = false {
        didSet {
            // when value changes, makes sure controls are shown/hidden accordingly
            if minimizeSearchControls {
                searchControlsBottomConstraint.constant = -150
                showHideSearchControls.setImage(#imageLiteral(resourceName: "DownArrow"), for: .normal)
            } else {
                searchControlsBottomConstraint.constant = 0
                showHideSearchControls.setImage(#imageLiteral(resourceName: "UpArrow"), for: .normal)
            }
            
            // this animates the changes to the constraint
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var lastTouchedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchControlsContainer.isHidden = true
        searchControlsPickerViewContainer.layer.cornerRadius = 10
        searchControlsRoverLabelContainer.layer.cornerRadius = 3

        searchControlsSlider.isEnabled = false
        searchControlsFetchButton.isEnabled = false
        
        refreshSlider()
        refreshSearchDateLabel()
        refreshPhotoCountLabel()
        
        activityIndicator.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onChanges), name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onProcessing), name: Notification.Name(Model.Notifications.roverPhotosProcessing.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onDoneProcessing), name: Notification.Name(Model.Notifications.roverPhotosDoneProcessing.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onRoverModeChanged), name: Notification.Name(Model.Notifications.roverModeChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onSelectedRoverChanged), name: Notification.Name(Model.Notifications.selectedRoverChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onSelectedManifestChanged), name: Notification.Name(Model.Notifications.selectedManifestChanged.rawValue), object: model)
        NotificationCenter.default.addObserver(self, selector: #selector(RoverPhotosViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchControlsFetchButtonContainer.layer.cornerRadius = searchControlsFetchButtonContainer.frame.size.height/4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoViewController {
            
            guard let indexPath = lastTouchedIndexPath,
                  model.roverPhotos.indices.contains(indexPath.item) else { return }
            
            let roverPhoto = model.roverPhotos[indexPath.item]
            
            vc.photoVCMode = .roverPhoto
            vc.imageURLString = roverPhoto.imageURL
            vc.details = roverPhoto.attributedStringDescription(baseFontSize: 14, headerColor: .green, bodyColor: .white)
            
        } else if let vc = segue.destination as? PostcardViewController {
            
            guard let indexPath = lastTouchedIndexPath,
                  model.roverPhotos.indices.contains(indexPath.item) else { return }

            let roverPhoto = model.roverPhotos[indexPath.item]
            vc.imageURLString = roverPhoto.imageURL
        }
    }
    
    func configureCell(cell: RoverPhotoCell, roverPhoto: RoverPhoto, indexPath: IndexPath) {
        
        cell.dateLabel.text = roverPhoto.earthDate
        cell.cameraLabel.text = roverPhoto.camera.name
        cell.imageURL = roverPhoto.imageURL
        
        // we provide the APODCell with a closure telling it what to do when the user
        // taps the download button
        cell.onDownloadClosure = { [weak self] (cell) in
            
            // get the index path for the cell if it exists
            // if it doesn't for some strange reason, then do nothing
            guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
            
            let model = ModelAccess.shared.model
            
            guard model.roverPhotos.indices.contains(indexPath.row) else { return }
            
            let roverPhoto = model.roverPhotos[indexPath.item]
            
            let alert = UIAlertController(title: "Download Image", message: "Do you want to download this image to your Photo Library?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let save = UIAlertAction(title: "Save Image", style: .default) { [ weak self ] (action) in
                
                guard let happySelf = self else { return }
                
                // go do the download processing
                happySelf.onDownloadImage(urlString: roverPhoto.imageURL)
                
                // disable the download button, so repeated downloads don't occur
                cell.downloadButton.isEnabled = false
            }
            
            alert.addAction(cancel)
            alert.addAction(save)
            
            self?.present(alert, animated: true, completion: nil)
        }
        
        cell.onPostcardClosure = { [weak self] (cell) in

            // get the index path for the cell if it exists
            // if it doesn't for some strange reason, then do nothing
            guard let indexPath = self?.collectionView.indexPath(for: cell) else { return }
            
            self?.lastTouchedIndexPath = indexPath
            self?.performSegue(withIdentifier: "ShowPostcard", sender: self)
        }
    }
    
    func onProcessing() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
    }
    
    func onDoneProcessing() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
    }
    
    func onChanges() {
        collectionView.reloadData()
    }
    
    func onRoverModeChanged() {
        onSelectedRoverChanged()
    }
    
    func onSelectedRoverChanged() {
        refreshSlider()
        refreshSearchDateLabel()
        refreshPhotoCountLabel()
    }
    
    func onSelectedManifestChanged() {
        refreshSearchDateLabel()
        refreshPhotoCountLabel()
    }
    
    func refreshView() {
        
        if model.roverMode == .notSet {
            // ok, lets set it to latest
            model.roverMode = .latest
        }
        
        if model.selectedRoverIndex == nil &&
            model.rovers.count > 0 {
            model.selectedRoverIndex = 0
        }
        
        refreshRoverMode()
        
        switch model.roverMode {

        case .search:
            refreshRoverPicker()
            refreshSlider()
            refreshSearchDateLabel()
            refreshPhotoCountLabel()
            
        default:
            break
        }
        
        refreshSearchControls()
        onChanges()
    }
    
    func refreshRoverMode() {
        
        let roverMode = model.roverMode
        
        if roverMode.rawValue <= roverModeSegmentedControl.numberOfSegments {
            roverModeSegmentedControl.selectedSegmentIndex = roverMode.rawValue
        }
    }
    
    func refreshSearchControls() {
        
        let mode = model.roverMode
        
        if mode == .search {
            minimizeSearchControls = false
            stackViewBottomConstraint.constant = 30
            searchControlsContainer.isHidden = false
            
        } else {
            minimizeSearchControls = true
            stackViewBottomConstraint.constant = 0
            searchControlsContainer.isHidden = true
        }
    }
    
    func refreshRoverPicker() {
        searchControlsRoverPicker.reloadAllComponents()
    }
    
    func refreshSlider() {
        
        guard let maxManifestIndex = model.maxManifestIndex else {
              
            searchControlsSlider.isEnabled = false
            searchControlsSlider.minimumValue = 0
            searchControlsSlider.maximumValue = 1.0
            searchControlsSlider.value = 0.5
            
            // disable the fetch button too
            searchControlsFetchButton.isEnabled = false
            
            return
        }
        
        searchControlsSlider.isEnabled = true
        searchControlsSlider.minimumValue = 0
        searchControlsSlider.maximumValue = Float(maxManifestIndex)
        searchControlsSlider.value = Float(maxManifestIndex)
        
        // enable the fetch button
        searchControlsFetchButton.isEnabled = true
    }
    
    func refreshSearchDateLabel() {
        
        guard let rover = model.currentRover,
              let manifest = model.currentManifest else {
                
            searchControlsDateLabel.text = ""
            return
        }
        
        if searchControlsSeg.selectedSegmentIndex == 0 {
            
            searchControlsDateLabel.text = "Sol: \(manifest.sol)"
        
        } else {
            
            guard let landingDate = Date(earthDate: rover.landingDate),
                  let earthDate = Calendar.current.date(byAdding: .day, value: manifest.sol, to: landingDate) else {
                    
                searchControlsDateLabel.text = "Error Getting Earth Date"
                return
            }
            
            searchControlsDateLabel.text = "Earth Date: \(earthDate.earthDate)"
        }
    }
    
    func refreshPhotoCountLabel() {
        if let manifest = model.currentManifest {
            searchControlsPhotoCountLabel.text = "Photos: \(manifest.totalPhotos)"
        } else {
            searchControlsPhotoCountLabel.text = ""
        }
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension RoverPhotosViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // get unique rovers in results set
//        let sectionCount = Set(model.roverPhotos.map { $0.rover.name }).count
                
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.roverPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoverPhotoCell", for: indexPath) as! RoverPhotoCell
        
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
        
        var width = collectionView.frame.size.width / 2
        if width > 200 {
            width = collectionView.frame.size.width / 3
        }
        
        return CGSize(width: width, height: width/3*2)
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDelegate
extension RoverPhotosViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lastTouchedIndexPath = indexPath
        performSegue(withIdentifier: "ShowPhoto", sender: self)
    }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        model.selectedRoverIndex = row
    }
}





//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension RoverPhotosViewController {
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        guard let mode = RoverMode(rawValue: sender.selectedSegmentIndex) else { return }
        
        model.roverMode = mode
        
        refreshSearchControls()
    }

    @IBAction func onSearchControlsButton() {
        guard model.roverMode == .search else { return }
        
        // toggle controls
        minimizeSearchControls = !minimizeSearchControls
    }
    
    @IBAction func onManifestSliderChanged(_ sender: UISlider) {
        model.selectedManifestIndex = Int(sender.value)
    }
    
    @IBAction func onSolEarthDateSegChanged(_ sender: UISegmentedControl) {
        refreshSearchDateLabel()
    }
    
    @IBAction func onBumpLeft() {
        guard let selectedManifestIndex = model.selectedManifestIndex else { return }
        
        model.selectedManifestIndex = selectedManifestIndex - 1
    }
    
    @IBAction func onBumpRight() {
        guard let selectedManifestIndex = model.selectedManifestIndex else { return }
        
        model.selectedManifestIndex = selectedManifestIndex + 1
    }
    
    @IBAction func onFetch() {

        model.fetchRoverPhotosForSelectedManifest()
    }
}
