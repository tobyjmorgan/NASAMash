//
//  EndpointStatus.swift
//  NASAMash
//
//  Created by redBred LLC on 3/17/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

class EndpointStatus {
    
    private var _working: Bool = false {
        didSet {
            
            if !_working {
                
                // we just turned off working, so reset the counters
                requestsSent = 0
                successfulRequestsReturned = 0
                failedRequestsReturned = 0
            }
        }
    }
    
    private var requestsSent: Int = 0
    private var successfulRequestsReturned: Int = 0
    private var failedRequestsReturned: Int = 0
    
    func checkComplete() -> Bool {
        if (successfulRequestsReturned + failedRequestsReturned) == requestsSent {
            _working = false
        }
        
        return !_working
    }
    
    func noteSentRequest() {
        noteSentRequests(1)
    }
    
    func noteSentRequests(_ count: Int) {
        
        requestsSent += count
        _working = true
    }

    func noteSuccessfulResult() {

        successfulRequestsReturned += 1
    }
    
    func noteFailedResult() {

        failedRequestsReturned += 1
    }
    
    var isWorking: Bool {
        return _working
    }
}

