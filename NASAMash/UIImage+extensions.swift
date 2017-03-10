//
//  UIImage+extensions.swift
//  MovieNight
//
//  Created by redBred LLC on 12/15/16.
//  Copyright © 2016 redBred. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    static func getImageAsynchronously(urlString: String, completion: @escaping (UIImage?, Error?) -> ()) {
        
        guard let url = URL(string: urlString) else {
            
            completion(nil, nil)
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
            
        let task = session.dataTask(with: url) { (data, response, error) in
                
            DispatchQueue.main.async {
                
                guard let response = response as? HTTPURLResponse, let data = data,
                      response.statusCode == 200, let image = UIImage(data: data) else {
                    
                    completion(nil, error)
                    return
                }
            
                completion(image, nil)
            }
        }
        
        task.resume()
    }
}

import ImageIO
import MobileCoreServices

extension UIImage {
    
    static func createGIF(with images: [UIImage], loopCount: Int = 0, frameDelay: Double) -> Data? {
        
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("Animation.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, images.count, nil) else { return nil }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary?)
        
        for image in images {
            
            guard let cgImage = image.cgImage else { return nil }
            
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary?)
        }
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        do {
            
            let data = try Data(contentsOf: url)
            return data
            
        } catch {
            return nil
        }
    }
}
