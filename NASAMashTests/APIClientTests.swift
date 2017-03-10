//
//  ModelInitializationTests.swift
//  NASAMash
//
//  Created by redBred LLC on 3/10/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest

@testable import NASAMash

class APIClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }


    func testApodApi() {
        let apiClient = NASAAPIClient()
        
        let todaysDate = Date().earthDate
        var apodImage: APODImage? = nil
        var apodError: Error? = nil
        
        let exp1 = expectation(description: "Fetching APOD for today's date: \(todaysDate) - should succeed")
        
        let endpoint1 = NASAAPODEndpoint.getAPODImage(todaysDate)
        apiClient.fetch(request: endpoint1.request, parse: APODImage.init) { (result) in
            switch result {
            case .success(let image):
                apodImage = image
            case .failure(let error):
                apodError = error
                apodImage = nil
            }
            
            exp1.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(apodError, "Error fetching APODImage: \(apodError)")
            XCTAssertNotNil(apodImage, "Did not obtain APODImage from API")
        }
        
        let tomorrowsDate = (Calendar.current.date(byAdding: .day, value: 1, to: Date()))!.earthDate
        
        let exp2 = expectation(description: "Fetching APOD for tomorrow's date: \(tomorrowsDate) - should fail")
        
        let endpoint2 = NASAAPODEndpoint.getAPODImage(tomorrowsDate)
        apiClient.fetch(request: endpoint2.request, parse: APODImage.init) { (result) in
            switch result {
            case .success(let image):
                apodImage = image
            case .failure(let error):
                apodError = error
                apodImage = nil
            }
            
            exp2.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(apodImage, "Should not have obtained APODImage from API")
            XCTAssertNotNil(apodError, "Should have caused error fetching tomorrow's APODImage")
        }
    }
    
    func testRoversApi() {
        let apiClient = NASAAPIClient()
        
        var rovers: [Rover]? = nil
        var roverError: Error? = nil
        
        let exp1 = expectation(description: "Fetching all Rover objects")
        
        let endpoint1 = NASARoverEndpoint.rovers
        apiClient.fetch(request: endpoint1.request, parse: NASARoverEndpoint.roversParser) { (result) in
            switch result {
            case .success(let roverResults):
                rovers = roverResults
            case .failure(let error):
                roverError = error
                rovers = nil
            }
            
            exp1.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(roverError, "Error fetching Rovers: \(roverError)")
            XCTAssertNotNil(rovers, "Did not obtain Rovers from API")
            XCTAssertTrue((rovers!.count > 0), "Did not obtain more than zero Rover objects")
        }
        
        var manifests: [Manifest]? = nil
        var manifestError: Error? = nil
        
        let exp2 = expectation(description: "Fetching manifests for first obtained Rover")
        
        let roverName = rovers![0].name
        let endpoint2 = NASARoverEndpoint.manifest(roverName)
        apiClient.fetch(request: endpoint2.request, parse: NASARoverEndpoint.manifestParser) { (result) in
            switch result {
            case .success(let manifestsResults):
                manifests = manifestsResults
            case .failure(let error):
                manifestError = error
                manifests = nil
            }
            
            exp2.fulfill()
        }

        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(manifestError, "Error fetching Manifests: \(manifestError)")
            XCTAssertNotNil(manifests, "Did not obtain Manifests from API")
            XCTAssertTrue((manifests!.count > 0), "Did not obtain more than zero Manifests objects")
        }        
    }
    
    func testEarthImageryApi() {
        let apiClient = NASAAPIClient()
        
        var earthImage: EarthImagery? = nil
        var earthImageError: Error? = nil
        
        let goodLat: Double = 42.3601
        let goodLon: Double = -71.0589
        
        let exp1 = expectation(description: "Fetching EarthImage for valid location: \(goodLat) - should succeed, \(goodLon)")
        
        let params1 = EarthImageryParams(lat: goodLat, lon: goodLon, dim: nil, date: Date().earthDate)
        let endpoint1 = NASAEarthImageryEndpoint.getImageForLocation(params1)
        apiClient.fetch(request: endpoint1.request, parse: EarthImagery.init) { (result) in
            switch result {
            case .success(let earthImageResult):
                earthImage = earthImageResult
            case .failure(let error):
                earthImageError = error
                earthImage = nil
            }
            
            exp1.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(earthImageError, "Error fetching EarthImagery: \(earthImageError)")
            XCTAssertNotNil(earthImage, "Did not obtain EarthImagery from API")
        }
        
        earthImage = nil
        earthImageError = nil
        
        let badLat: Double = 180.3601
        let badLon: Double = -71.0589
        
        let exp2 = expectation(description: "Fetching EarthImage for invalid location: \(badLat), \(badLon) - should fail")
        
        let params2 = EarthImageryParams(lat: badLat, lon: badLon, dim: nil, date: Date().earthDate)
        let endpoint2 = NASAEarthImageryEndpoint.getImageForLocation(params2)
        apiClient.fetch(request: endpoint2.request, parse: EarthImagery.init) { (result) in
            switch result {
            case .success(let earthImageResult):
                earthImage = earthImageResult
            case .failure(let error):
                earthImageError = error
                earthImage = nil
            }
            
            exp2.fulfill()
        }
        
        waitForExpectations(timeout: 15.0) { (error) in
            XCTAssertNil(earthImage, "Should have failed to obtain EarthImagery from API for bad lat/lon")
            XCTAssertNotNil(earthImageError, "Should have returned error fetching invalid EarthImagery with bad lat/lon")
        }

    }
}


























