//
//  ModelAccess.swift
//  NASAMash
//
//  Created by redBred LLC on 3/9/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

class ModelAccess: NSObject {
        
    ///////////////////////////////////////////////////////////////////
    // singleton stuff
    static let shared = ModelAccess()
    
    internal var privateModel = Model(iKnowIShouldUseModelAccess: true)
    
    private override init() {
        // nothing to do here, but want to make initialization private
        // to force use of the shared instance singleton
        super.init()
    }
    ///////////////////////////////////////////////////////////////////

    var model: Model  {
        return privateModel
    }
}
