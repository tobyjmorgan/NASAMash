//
//  LocationViewController.swift
//  HereUGo
//
//  Created by redBred LLC on 2/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var searchBarContainerView: UIView!
    @IBOutlet var buttonContainer: UIView!
    
    @IBAction func onNext() {
        performSegue(withIdentifier: "ShowImagery", sender: self)
    }
    
    var initialLocation: (Double, Double)? = nil
    
    // will handle fetching location info
    lazy var locationManager: LocationManager = {
        return LocationManager(alertPresentingViewController: self)
    }()
    
    lazy var resultsTableController: SearchResultsTableViewController = {
        
        let rc = self.storyboard!.instantiateViewController(withIdentifier: "SearchResults") as! SearchResultsTableViewController
        rc.tableView.delegate = self
        
        return rc
    }()
    
    lazy var searchController: UISearchController = {
        
        let sc = UISearchController(searchResultsController: self.resultsTableController)
        sc.searchResultsUpdater = self

        sc.delegate = self
        sc.hidesNavigationBarDuringPresentation = false
        sc.dimsBackgroundDuringPresentation = true
        
        self.definesPresentationContext = true
        
        return sc
    }()
    
    var currentPin: MKPlacemark? = nil
    let searchCompleter = MKLocalSearchCompleter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        buttonContainer.layer.cornerRadius = 3
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LocationViewController.handleLongPress(gestureReconizer:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        searchCompleter.delegate = self
        searchCompleter.region = mapView.region
        searchCompleter.filterType = .locationsAndQueries
        
        if let location = initialLocation {
            
            let coordinate = CLLocationCoordinate2D(latitude: location.0, longitude: location.1)
            let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            
            addMapAnnotationForPlacemark(placemark: placemark, refreshRegion: true)
            
        } else {
            
            locationManager.getLocation { (location) in
                
                print("Location: \(location)")
                
                self.setMapViewRegion(coordinate: location.coordinate)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchController.searchBar.barTintColor = .white
        
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleRightMargin]
        searchBarContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.updateConstraints()
        searchController.searchBar.setNeedsDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Thanks to André Slotta
        // http://stackoverflow.com/questions/36164647/uisearchcontroller-search-bar-initially-too-wide
        var searchBarFrame = searchController.searchBar.frame
        searchBarFrame.size.width = searchBarContainerView.frame.size.width
        searchController.searchBar.frame = searchBarFrame
    }
    
    func setMapViewRegion(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: true)
        searchCompleter.region = region
    }
    
    func addMapAnnotationForPlacemark(placemark: MKPlacemark, refreshRegion: Bool) {
        
        // keep for later so when we want to change the circle overlay, we have the center of the circle
        currentPin = placemark
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        if refreshRegion {
            
            self.setMapViewRegion(coordinate: annotation.coordinate)
        }
    }
}



extension LocationViewController: UISearchControllerDelegate {
}

extension LocationViewController: UITableViewDelegate {
    
    // when a row is selected, we need to go get a placemark,record selected location and plot it on the map
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let completion = resultsTableController.searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, _) in
            
            DispatchQueue.main.async {
                
                if let response = response, let mapItem = response.mapItems.first {
                    
                    let placemark = mapItem.placemark
                    
                    // record the last selected location
                    ModelAccess.shared.model.setLastLocation(latitude: placemark.coordinate.latitude,
                                                             longitude: placemark.coordinate.longitude)
                    
                    // display the placemark on the map
                    self.presentMapViewWithPlacemark(placemark: placemark)
                }

            }
        }

    }
    
    func presentMapViewWithPlacemark(placemark: MKPlacemark) {
        
        addMapAnnotationForPlacemark(placemark: placemark, refreshRegion: true)
        
        // present mapView
        dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        // give the search text to the search completer
        searchCompleter.queryFragment = searchText
    }
}

extension LocationViewController: MKMapViewDelegate {
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        let locationPoint = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(locationPoint,toCoordinateFrom: mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        locationManager.geocoder.reverseGeocodeLocation(location) { [ weak self ] (placemarks, error) in
            
            guard let goodSelf = self else { return }
            
            guard let rawPlacemark = placemarks?.first else { return }
            
            let placemark = MKPlacemark(placemark: rawPlacemark)
            
            DispatchQueue.main.async {
                
                // record the last selected location
                ModelAccess.shared.model.setLastLocation(latitude: placemark.coordinate.latitude,
                                                         longitude: placemark.coordinate.longitude)

                
                goodSelf.addMapAnnotationForPlacemark(placemark: placemark, refreshRegion: false)
            }
        }
    }
}

extension LocationViewController: MKLocalSearchCompleterDelegate {
    
    // add the search results to the table view's data
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        self.resultsTableController.searchResults = completer.results
        self.resultsTableController.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        self.resultsTableController.searchResults = completer.results
        self.resultsTableController.tableView.reloadData()
    }
}





