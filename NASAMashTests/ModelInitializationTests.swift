//
//  ModelInitializationTests.swift
//  NASAMash
//
//  Created by redBred LLC on 3/10/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import XCTest

@testable import NASAMash

class ModelInitializationTests: XCTestCase {
    
    var model: Model = TestModelAccess().model
    var mockNotificationCenter = MockNotificationCenterInitialization.default
    
    class MockNotificationCenterInitialization: NotificationCenter {
        
        var didRecieveModelReadyNotification: Bool = false
        
        override func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
            
            if aName.rawValue == Model.Notifications.modelReady.rawValue {
                didRecieveModelReadyNotification = true
            }
        }
    }

    class MockNASAAPIClientNoRovers: APIClient {
        
        let configuration: URLSessionConfiguration
        lazy var session: URLSession = {
            return URLSession(configuration: self.configuration)
        }()
        
        required init(config: URLSessionConfiguration) {
            self.configuration = config
        }
        
        convenience init() {
            self.init(config: URLSessionConfiguration.default)
        }

        func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> [T]?, completion: @escaping (APIResult<[T]>) -> Void) {
            
            let json: JSON = [ "rovers" : "[]" as AnyObject]
            
            
            if let value = parse(json) {
                completion(.success(value))
            } else {
                completion(.failure(APIClientError.unableToParseJSON(json)))
            }
        }

        func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void) {
            
            let json: JSON = [ "rovers" : "[]" as AnyObject]
            
            
            if let value = parse(json) {
                completion(.success(value))
            } else {
                completion(.failure(APIClientError.unableToParseJSON(json)))
            }
        }
    }
    
    override func setUp() {
        super.setUp()
     
        model = TestModelAccess().model
        mockNotificationCenter = MockNotificationCenterInitialization.default
        
        model.notificationCenter = mockNotificationCenter
        model.client = MockNASAAPIClientNoRovers()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        XCTAssertTrue(model.rovers.count == 0, "Expected no Rovers")
        XCTAssertTrue(model.roverPhotos.count == 0, "Expected no Rovers")
        XCTAssertTrue((mockNotificationCenter as! MockNotificationCenterInitialization).didRecieveModelReadyNotification, "Expected model to bre ready")
    }
    
}
