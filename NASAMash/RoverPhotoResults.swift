//
//  RoverPhotoResults.swift
//  NASAMash
//
//  Created by redBred LLC on 3/20/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import Foundation

struct RoverPhotoResults {
    let sections: [String]
    let sectionPhotos: [ String: [RoverPhoto] ]
}

extension RoverPhotoResults {
    
    func getSectionTitle(_ section: Int) -> String? {
        
        guard sections.indices.contains(section) else { return nil }
        
        return sections[section]
    }
    
    func getSectionPhotos(_ sectionName: String) -> [RoverPhoto]? {
        
        return sectionPhotos[sectionName]
    }
    
    func getSectionPhotos(_ section: Int) -> [RoverPhoto]? {
        
        guard let sectionName = getSectionTitle(section) else { return nil }
        
        return sectionPhotos[sectionName]
    }
    
    func numberOfSections() -> Int {
        
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
    
        guard let sectionName = getSectionTitle(section) else { return 0 }
        guard let sectionPhotos = sectionPhotos[sectionName] else { return 0 }

        return sectionPhotos.count
    }
    
    func getRoverPhoto(indexPath: IndexPath) -> RoverPhoto? {
        
        guard let sectionPhotos = getSectionPhotos(indexPath.section) else { return nil }
        
        guard sectionPhotos.indices.contains(indexPath.item) else { return nil }
        
        return sectionPhotos[indexPath.item]
    }
}
