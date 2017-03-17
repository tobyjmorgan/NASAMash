//
//  ActivityViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/8/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    private let activityView = ActivityView()
    
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        activityView.messageLabel.text = message
        view = activityView
        
         NotificationCenter.default.addObserver(self, selector: #selector(ActivityViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ActivityView: UIView {
    
    let boxSide: CGFloat = 160
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let boundingBoxView = UIView(frame: CGRect.zero)
    let messageLabel = UILabel(frame: CGRect.zero)
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        boundingBoxView.backgroundColor = UIColor.darkGray
        boundingBoxView.layer.cornerRadius = 12.0
        
        activityIndicatorView.startAnimating()
        
        messageLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        addSubview(boundingBoxView)
        addSubview(activityIndicatorView)
        addSubview(messageLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        boundingBoxView.frame.size.width = boxSide
        boundingBoxView.frame.size.height = boxSide
        boundingBoxView.frame.origin.x = ceil((bounds.width - boundingBoxView.frame.width) / 2)
        boundingBoxView.frame.origin.y = ceil((bounds.height - boundingBoxView.frame.height) / 2)
        
        activityIndicatorView.frame.origin.x = ceil((bounds.width - activityIndicatorView.frame.width) / 2)
        activityIndicatorView.frame.origin.y = ceil((bounds.height - activityIndicatorView.frame.height) / 2)

        messageLabel.sizeToFit()
        messageLabel.frame.origin.x = ceil((bounds.width - messageLabel.frame.width) / 2)
        messageLabel.frame.origin.y = ceil(activityIndicatorView.frame.bottomEdge() + ((boundingBoxView.frame.height - activityIndicatorView.frame.height) / 4) - (messageLabel.frame.height / 2))
    }
}
