//
//  ModelTests.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest

@testable import NASAMash

class ModelRoverModeTests: XCTestCase {
    
    var model: Model = TestModelAccess().model
    
    var mockNotificationCenter = MockNotificationCenterForRoverMode.default

    class MockNotificationCenterForRoverMode: NotificationCenter {
        
        var didRecieveRoverModeChangedNotification: Bool = false
        var didRecieveRoverPhotosChangedNotification: Bool = false
        
        override func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
            
            if aName.rawValue == Model.Notifications.roverModeChanged.rawValue {
                didRecieveRoverModeChangedNotification = true
            }

            if aName.rawValue == Model.Notifications.roverPhotosChanged.rawValue {
                didRecieveRoverPhotosChangedNotification = true
            }
        }
    }
    
    override func setUp() {
        super.setUp()
                
        model = TestModelAccess().model
        mockNotificationCenter = MockNotificationCenterForRoverMode.default
        model.notificationCenter = mockNotificationCenter
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRoverModeChangeToLatest() {
        
        XCTAssertTrue(model.roverMode==RoverMode.notSet, "Model Rover Mode in incorrect initial state")
        
        model.roverMode = .latest
        
        XCTAssertTrue(model.roverMode==RoverMode.latest, "Model did not change Rover Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverModeChangedNotification, "Model should have posted Rover Mode Changed")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverPhotosChangedNotification, "Model should have posted Rover Photos Changed")
    }

    func testRoverModeChangeToRandom() {
        
        XCTAssertTrue(model.roverMode==RoverMode.notSet, "Model Rover Mode in incorrect initial state")
        
        model.roverMode = .random
        
        XCTAssertTrue(model.roverMode==RoverMode.random, "Model did not change Rover Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverModeChangedNotification, "Model should have posted Rover Mode Changed")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverPhotosChangedNotification, "Model should have posted Rover Photos Changed")
    }

    func testRoverModeChangeToSearch() {
        
        XCTAssertTrue(model.roverMode==RoverMode.notSet, "Model Rover Mode in incorrect initial state")
        
        model.roverMode = .search
        
        XCTAssertTrue(model.roverMode==RoverMode.search, "Model did not change Rover Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverModeChangedNotification, "Model should have posted Rover Mode Changed")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForRoverMode).didRecieveRoverPhotosChangedNotification, "Model should have posted Rover Photos Changed")
    }    
}
