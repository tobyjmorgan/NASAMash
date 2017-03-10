//
//  LocationManagerTests.swift
//  DailyDiary
//
//  Created by redBred LLC on 2/2/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest
import CoreLocation

@testable import NASAMash


class LocationManagerTests: XCTestCase {
    
    static let testLatitude: Double = 37.3317
    static let testLongitude: Double = 122.0307
    
    class MockUIViewController: UIViewController {
        
        var didPresentController: Bool = false
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            
            didPresentController = true
        }
    }
    
    enum StateLocationManagerRequestedAuthorization {
        case none
        case requestWhenInUseAuthorization
        case startUpdatingLocation
        case stopUpdatingLocation
    }

    class MockCLLocationManager: CLLocationManager {
        
        var requestedAuthorization: Bool = false
        var startedUpdatingLocation: Bool = false
        var stoppedUpdatingLocation: Bool = false
        
        override func requestWhenInUseAuthorization() {
            requestedAuthorization = true
            
            delegate?.locationManager!(self, didChangeAuthorization: CLAuthorizationStatus.authorizedWhenInUse)
        }
        
        override func startUpdatingLocation() {
            startedUpdatingLocation = true
            
            let location = CLLocation(latitude: LocationManagerTests.testLatitude,
                                      longitude: LocationManagerTests.testLongitude)
            delegate?.locationManager!(self, didUpdateLocations: [location])
        }

        override func stopUpdatingLocation() {
            stoppedUpdatingLocation = true            
        }
    }
    
    class MockCLLocationManagerAlwaysDenies: MockCLLocationManager {

        override func authorizationStatus() -> CLAuthorizationStatus {
            return CLAuthorizationStatus.denied
        }
    }

    class MockCLLocationManagerAlwaysNotDetermined: MockCLLocationManager {
        
        override func authorizationStatus() -> CLAuthorizationStatus {
            return CLAuthorizationStatus.notDetermined
        }
    }

    class MockCLLocationManagerAlwaysAuthorized: MockCLLocationManager {
        
        override func authorizationStatus() -> CLAuthorizationStatus {
            return CLAuthorizationStatus.authorizedWhenInUse
        }
    }
    
    class MockCLLocationManagerAlwaysFails: MockCLLocationManagerAlwaysAuthorized {
        
        override func startUpdatingLocation() {
            startedUpdatingLocation = true
            
            let error = NSError(domain: "Unit Tests", code: 9999, userInfo: [:])
            delegate?.locationManager!(self, didFailWithError: error)
        }
    }
    
    
    class MockCLGeocoder: CLGeocoder {
    
        var placementWasRequested: Bool = false
        
        override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
            placementWasRequested = true
            
            let placemark = CLPlacemark()
            completionHandler([placemark], nil)
        }
    }
    
    let vc = MockUIViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeniedSoAlertForSettings() {
        
        XCTAssertFalse(vc.didPresentController, "Mock View Controller in wrong initial state")
        
        let clManager = MockCLLocationManagerAlwaysDenies()
        let locationManager = LocationManager(manager: clManager, geocoder: CLGeocoder(), alertPresentingViewController: vc)
        
        locationManager.getLocation(completion: { (location) in
                print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
            })
        
        XCTAssertTrue(vc.didPresentController, "Location Manager should have presented an alert controller")
    }
    
    func testAuthorizationNotDeterminedSoRequestPermission() {
        
        let clManager = MockCLLocationManagerAlwaysNotDetermined()

        XCTAssertFalse(clManager.requestedAuthorization, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.startedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.stoppedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        
        let locationManager = LocationManager(manager: clManager, geocoder: CLGeocoder(), alertPresentingViewController: vc)
        
        locationManager.getLocation(completion: { (location) in
            print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
        })
        
        XCTAssertTrue(clManager.requestedAuthorization, "Location Manager should have requested whenInUse authorization")
        XCTAssertTrue(clManager.startedUpdatingLocation, "Location Manager should have started updating location")
        XCTAssertTrue(clManager.stoppedUpdatingLocation, "Location Manager should have stopped updating location")
    }

    func testAuthorizedSoProcessLocation() {
        
        let clManager = MockCLLocationManagerAlwaysAuthorized()

        XCTAssertFalse(clManager.requestedAuthorization, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.startedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.stoppedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        
        let locationManager = LocationManager(manager: clManager, geocoder: CLGeocoder(), alertPresentingViewController: vc)
        
        locationManager.getLocation(completion: { (location) in
            print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
        })
        
        XCTAssertFalse(clManager.requestedAuthorization, "Location Manager should NOT have requested whenInUse authorization")
        XCTAssertTrue(clManager.startedUpdatingLocation, "Location Manager should have started updating location")
        XCTAssertTrue(clManager.stoppedUpdatingLocation, "Location Manager should have stopped updating location")
    }

    func testFailsToGetLocaiton() {
        
        let clManager = MockCLLocationManagerAlwaysFails()
        
        XCTAssertFalse(vc.didPresentController, "Mock View Controller in wrong initial state")
        XCTAssertFalse(clManager.requestedAuthorization, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.startedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        XCTAssertFalse(clManager.stoppedUpdatingLocation, "MockCLLocationManager in wrong initial state")
        
        let locationManager = LocationManager(manager: clManager, geocoder: CLGeocoder(), alertPresentingViewController: vc)
        
        locationManager.getLocation(completion: { (location) in
            print("latitude: \(location.coordinate.latitude), longitude: \(location.coordinate.longitude)")
        })

        XCTAssertFalse(clManager.requestedAuthorization, "Location Manager should NOT have requested whenInUse authorization")
        XCTAssertTrue(clManager.startedUpdatingLocation, "Location Manager should have started updating location")
        XCTAssertFalse(clManager.stoppedUpdatingLocation, "Location Manager should have stopped updating location")
        XCTAssertTrue(vc.didPresentController, "Location Manager should have presented an alert controller")
    }
    
    func testRequestingLocation() {
        
        let locationManager = LocationManager(alertPresentingViewController: vc)
        locationManager.getLocation{ (location) in
            XCTAssert(location.coordinate.latitude==LocationManagerTests.testLatitude&&location.coordinate.longitude==LocationManagerTests.testLongitude, "Unexpected location returned from location manager")
        }
    }
    
    func testRequestingPlacement() {
        let clGeocoder = MockCLGeocoder()
        let locationManager = LocationManager(manager: CLLocationManager(), geocoder: clGeocoder, alertPresentingViewController: vc)
        
        XCTAssertFalse(clGeocoder.placementWasRequested, "MockCLGeocoder is in wrong initial state")
        
        locationManager.getPlacement(latitude: LocationManagerTests.testLatitude, longitude: LocationManagerTests.testLongitude) { (resultString) in
            print("resultString: \(resultString)")
        }
        
        XCTAssertTrue(clGeocoder.placementWasRequested, "Geocoder should have attempted to reverse geocode location")
    }
    
    
}





