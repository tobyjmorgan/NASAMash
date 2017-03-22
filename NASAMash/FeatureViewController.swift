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

    let model = ModelAccess.shared.model
    var lastSelectedFeature: Feature? = nil
    
    enum LoadingState {
        case notStarted
        case inProgress
        case done
    }
    
    var showingLoading: LoadingState = .notStarted {
        
        didSet {
            
            switch (oldValue, showingLoading) {
            
            case (.notStarted, .inProgress):
                // present loading dialogue
                let loading = ActivityViewController(message: "Loading...")
                present(loading, animated: true, completion: nil)
            
            case (.inProgress, .done):
                dismiss(animated: true, completion: { self.displayWelcome() })
                
            default:
                showingLoading = .done
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(FeatureViewController.onApplicationNotification(notification:)), name: TJMApplicationNotification.ApplicationNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeatureViewController.hideLoading), name: Notification.Name(Model.Notifications.modelReady.rawValue), object: model)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.invalidateIntrinsicContentSize()
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showLoading()
        
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
        
        if !model.hasBeenRunBefore() {
            
            let welcome = TJMApplicationNotification(title: "Welcome", message: "We hope you enjoy exploring some great images from NASA!", fatal: false)
            welcome.postMyself()
        }
    }
    
    func showLoading() {
        
        // warm up the model
        let _ = ModelAccess.shared.model
        
        showingLoading = .inProgress
    }
    
    func hideLoading() {
        showingLoading = .done
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
        
        cell.setNeedsLayout()
        
        return cell
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UITableViewDelegate
extension FeatureViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // 6 plus portrait - width: 375.0, height: 543.0 = 0.69
        // 6 plus landscape - width: 295.0, height: 310.0 = 0.952
        // 6 portrait - width: 375.0, height: 543.0 = 0.69
        // 6 landscape - width: 667.0, height: 283.0 = 2.35
        // air portrait - width: 320.5, height: 964.0 = 0.3325 - we want 1x3 cells
        // air landscape - width: 320.0, height: 644.0 = 0.5 - we want 1x3 cells
        
        let height: CGFloat
        
        
        if tableView.frame.size.width / tableView.frame.size.height < 0.6 {
            
            height = tableView.frame.size.width / 3

        } else {
            
            height = tableView.frame.size.height / CGFloat(Feature.count)
        }
        
        return height
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

