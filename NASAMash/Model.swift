//
//  Model.swift
//  NASAMash
//
//  Created by redBred LLC on 2/24/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation
import GameKit

class ModelAccess: NSObject {
    
    ///////////////////////////////////////////////////////////////////
    // singleton stuff
    static let shared = ModelAccess()
    
    private var privateModel = Model()
    
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

// special access for testing
class TestModelAccess: NSObject {
    var model = Model()
}

enum APODMode: Int {
    case latest
    case favorites
}

enum RoverMode: Int {
    case latest
    case search
    case notSet
}

class Model: NSObject {

    fileprivate override init() {
        super.init()
        
        startUp()
    }
    
    enum Notifications: String {
        case modelReady
        case selectedRoverChanged
        case selectedManifestChanged
        case roverPhotosChanged
        case roverPhotosProcessing
        case roverPhotosDoneProcessing
        case roverModeChanged
        case apodImagesChanged
        case earthImagesChanged
        case earthImageAssetsProcessing
        case earthImageAssetsDoneProcessing
    }
    
    var client: APIClient = NASAAPIClient()
    var defaults = UserDefaults.standard
    var notificationCenter = NotificationCenter.default

    internal var prefetchedAPODImages: [APODImage] = []
    internal var favoriteAPODImages: [APODImage] = []
    internal var prefetchedLatestRoverPhotos: RoverPhotoResults? = nil
    
    internal let startUpStatus: EndpointStatus = EndpointStatus()
    internal let apodStatus: EndpointStatus = EndpointStatus()
    internal let roverPhotoStatus: EndpointStatus = EndpointStatus()
    
    var rovers: [Rover] = []
    var apodImages: [APODImage] = []
    var roverPhotos: RoverPhotoResults? = nil
    var earthImages: [EarthImagery] = []
    var failedEarthImageCount: Int = 0
    
    var apodMode: APODMode = .latest {
        
        didSet {
            
            // if the value has changed, update the available images and send a notification
            if oldValue != apodMode {
                
                switch apodMode {
                case .latest:
                    apodImages = prefetchedAPODImages
                case .favorites:
                    apodImages = favoriteAPODImages
                }
                
                notificationCenter.post(name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: self)
            }
        }
    }

    var roverMode: RoverMode = .notSet {
        
        didSet {
            
            // if the value has changed, update the available images and send a notification
            if oldValue != roverMode {
                
                switch roverMode {
                case .notSet:
                    // do nothing
                    break
                    
                case .latest:
                    roverPhotos = prefetchedLatestRoverPhotos
                    
                case .search:
                    roverPhotos = nil
                }
                
                notificationCenter.post(name: Notification.Name(Model.Notifications.roverModeChanged.rawValue), object: self)
                notificationCenter.post(name: Notification.Name(Model.Notifications.roverPhotosChanged.rawValue), object: self)
            }
        }
    }
    
    var selectedRoverIndex: Int? = nil {
        
        didSet {
            
            // try to unwrap the value
            if let unwrappedRoverIndex = selectedRoverIndex {
                
                // check that this is a valid rover index, otherwise clear everything out and return
                guard rovers.indices.contains(unwrappedRoverIndex) else {
                    selectedRoverIndex = nil
                    selectedManifestIndex = nil
                    return
                }
                
                selectedManifestIndex = maxManifestIndex
                
            } else {
                // it was nil, so make sure the manifest index is nil too
                selectedManifestIndex = nil
            }
            
            notificationCenter.post(name: Notification.Name(Model.Notifications.selectedRoverChanged.rawValue), object: self)
        }
    }
    
    var currentRover: Rover? {
        
        guard let roverIndex = selectedRoverIndex,
              rovers.indices.contains(roverIndex) else { return nil }
        
        return rovers[roverIndex]
    }
    
    var maxManifestIndex: Int? {
        
        // try to unwrap the rover index
        if let unwrappedRoverIndex = selectedRoverIndex {
            
            // check that this is a valid rover index, otherwise we have to return nil
            guard rovers.indices.contains(unwrappedRoverIndex) else {
                return nil
            }
            
            // get the rover and the manifest count
            let rover = rovers[unwrappedRoverIndex]
            let manifestCount = rover.manifests.count
            
            // if there are manifests, set the max to count - 1
            if manifestCount > 0 {
                return manifestCount - 1 // the max possible index
            } else {
                return nil // no manifests, so return nil
            }
            
            
        } else {
            // it was nil, so make sure the max index is nil too
            return nil
        }
    }
    
    var selectedManifestIndex: Int? = nil {
        didSet {
            
            // unwrap new value since it may be nil
            if let unwrappedManifestIndex = selectedManifestIndex {
            
                // unwrap max possible index for current rover, because
                // again it may be nil
                if let maxManifestIndex = maxManifestIndex {
                    
                    // manifest index cannot be less than zero
                    if unwrappedManifestIndex < 0 {
                        selectedManifestIndex = 0
                    }
                    
                    // and it cannot be greater than the max
                    if unwrappedManifestIndex > maxManifestIndex {
                        selectedManifestIndex = maxManifestIndex
                    }
                    
                } else {
                    selectedManifestIndex = nil
                }
            }

            notificationCenter.post(name: Notification.Name(Model.Notifications.selectedManifestChanged.rawValue), object: self)
        }
    }
    
    var currentManifest: Manifest? {
        
        guard let rover = currentRover,
              let manifestIndex = selectedManifestIndex,
              rover.manifests.indices.contains(manifestIndex) else { return nil }
        
        return rover.manifests[manifestIndex]
    }
    
    

    
    internal func startUp() {
                
        fetchRovers()
        fetchLatestAPODImages()
        fetchFavoriteAPODImages()
    }
}
