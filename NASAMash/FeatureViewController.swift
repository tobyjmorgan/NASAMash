//
//  FeatureViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit
import SAMCache

class FeatureViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var settingsButton: UIButton!

    var detailViewController: DetailViewController? = nil
    var lastSelectedFeature: Feature? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(FeatureViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.invalidateIntrinsicContentSize()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayWelcome()
        
        // unselect anything that was previously selected when returning to this screen
        // but only if not in split view mode (both sides showing)
        if self.splitViewController!.isCollapsed {
            
            if let selections = tableView.indexPathsForSelectedRows {
                
                for selection in selections {
                    tableView.deselectRow(at: selection, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            
            guard let controller = (segue.destination as! UINavigationController).topViewController as? RepointerViewController,
                  let feature = lastSelectedFeature else { return }
            
            controller.feature = feature

            if let controller = (segue.destination as! UINavigationController).topViewController {
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    func displayWelcome() {
        
        if !Model.shared.hasBeenRunBefore() {
            
            let welcome = TJMApplicationNotification(title: "Welcome", message: "We hope you enjoy exploring some great images from NASA!", fatal: false)
            welcome.postMyself()
        }
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UITableViewDataSource
extension FeatureViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Feature.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath) as! FeatureCell
        
        let feature = Feature.allValues[indexPath.row]
        cell.name.text = feature.description
        cell.icon.image = feature.largeIcon
        
        return cell
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UITableViewDelegate
extension FeatureViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / CGFloat(Feature.count)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let feature = Feature(rawValue: indexPath.row) else { return }
        
        lastSelectedFeature = feature
        performSegue(withIdentifier: "ShowDetail", sender: self)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension FeatureViewController {
    
    @IBAction func onSettings() {
        
        let alert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let clearCacheAction = UIAlertAction(title: "Clear Cached Images", style: .default) { (action) in
            SAMCache.shared().removeAllObjects()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(clearCacheAction)
        alert.addAction(cancelAction)
        
        let popover = alert.popoverPresentationController
        popover?.sourceView = settingsButton
        popover?.sourceRect = settingsButton.bounds
        
        present(alert, animated: true)
    }
}

