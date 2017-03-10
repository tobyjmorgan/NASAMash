//
//  LocationManager.swift
//  DailyDiary
//
//  Created by redBred LLC on 1/29/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

// to simplify unit testing
extension CLLocationManager {
    func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
}

class LocationManager: NSObject {

    let manager: CLLocationManager
    let geocoder: CLGeocoder
   
    // dependency injection for presenting alerts
    let alertPresentingViewController: UIViewController
    
    init(manager: CLLocationManager, geocoder: CLGeocoder, alertPresentingViewController: UIViewController) {
        self.manager = manager
        self.geocoder = geocoder
        self.alertPresentingViewController = alertPresentingViewController
        super.init()
        
        manager.delegate = self
    }

    // split initialization so that CLLocationManager and CLGeocoder
    // can be injected if desired (i.e. for unit testing)
    convenience init(alertPresentingViewController: UIViewController) {
        self.init(manager: CLLocationManager(), geocoder: CLGeocoder(), alertPresentingViewController: alertPresentingViewController)
    }
    
    // a closure for what to do when successfully geolocated
    internal var onLocationFix: ((CLLocation) -> Void)?

    // used when requesting current location
    func getLocation(completion: @escaping (CLLocation) -> Void) {

        // capture the completion handler for use later
        onLocationFix = completion
        
        // what permissions do we have for using CLLocationManager?
        // changed CLLocationManager.authorizationStatus() to a call to my extension
        // this makes unit testing with dependency injection easier
        switch manager.authorizationStatus() {
        
        case .authorizedAlways:
            // ask for permission
            manager.startUpdatingLocation()
            
        case .notDetermined:
            // ask for permission
            manager.requestWhenInUseAuthorization()
        
        case .authorizedWhenInUse:
            // yay - lets go!
            manager.startUpdatingLocation()
            
        case .restricted, .denied:
            // present an alert showing how to change the settings if the user wants to
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "If you want to add your location to your diary entries, please open this app's settings and set location access to 'When In Use'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            alertController.addAction(openAction)
            
            alertPresentingViewController.present(alertController, animated: true, completion: nil)
        }        
    }
    
    // used when requesting a location be converted in to placement
    func getPlacement(latitude: Double, longitude: Double, completion: @escaping (String) -> Void) {

        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            // make sure this happens on the main queue
            // just in case there is any GUI code inside the completion handler
            DispatchQueue.main.async {
                
                guard let placemark = placemarks?.first else {
                    
                    completion("Unable to get location description")
                    return
                }
                
                completion(placemark.prettyDescription)
            }

        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // present alert with details of why geolocation failed
        let alertController = UIAlertController(
            title: "Location Error",
            message: "Unable to determine location: \(error).",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertPresentingViewController.present(alertController, animated: true, completion: nil)
    }

    // found our location
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else { return }
        
        if let onLocationFix = onLocationFix {
            
            // make sure this happens on the main queue
            // just in case there is any GUI code inside the onLocationFix completion handler
            DispatchQueue.main.async {
                // call the closure for successful location
                onLocationFix(location)
            }
        }
        
        manager.stopUpdatingLocation()
    }
}
