//
//  ModelApodModeTests.swift
//  NASAMash
//
//  Created by redBred LLC on 3/10/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest

@testable import NASAMash

class ModelApodModeTests: XCTestCase {
    
    var model: Model = TestModelAccess().model
    
    var mockNotificationCenter = MockNotificationCenterForApodMode.default
    
    class MockNotificationCenterForApodMode: NotificationCenter {
        
        var didRecieveApodImagesChangedNotification: Bool = false
        
        override func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
            
            if aName.rawValue == Model.Notifications.apodImagesChanged.rawValue {
                didRecieveApodImagesChangedNotification = true
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        
        model = TestModelAccess().model
        mockNotificationCenter = MockNotificationCenterForApodMode.default
        model.notificationCenter = mockNotificationCenter
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApodModeChangeToLatest() {
        
        XCTAssertTrue(model.apodMode==APODMode.latest, "Model APOD Mode in incorrect initial state")
        
        model.apodMode = .favorites
        
        XCTAssertTrue(model.apodMode==APODMode.favorites, "Model did not change APOD Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForApodMode).didRecieveApodImagesChangedNotification, "Model should have posted Rover Mode Changed")
    }
    
    func testApodModeChangeToFavorites() {
        
        XCTAssertTrue(model.apodMode==APODMode.latest, "Model APOD Mode in incorrect initial state")
        
        model.apodMode = .favorites
        
        XCTAssertTrue(model.apodMode==APODMode.favorites, "Model did not change APOD Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForApodMode).didRecieveApodImagesChangedNotification, "Model should have posted Rover Mode Changed")
        
        // reset notifications flag
        (mockNotificationCenter as! MockNotificationCenterForApodMode).didRecieveApodImagesChangedNotification = false
        
        model.apodMode = .latest
        
        XCTAssertTrue(model.apodMode==APODMode.latest, "Model did not change APOD Mode correctly")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterForApodMode).didRecieveApodImagesChangedNotification, "Model should have posted Rover Mode Changed")
    }
    
}
