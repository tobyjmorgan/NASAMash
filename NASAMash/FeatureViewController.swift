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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.invalidateIntrinsicContentSize()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let controller = (segue.destination as! UINavigationController).topViewController {
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
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
}




//////////////////////////////////////////////////////////////
// MARK: - IBActions
extension FeatureViewController {
    
    @IBAction func onSettings() {
        
        let alert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        
        let clearCacheAction = UIAlertAction(title: "Clear Cache", style: .default) { (action) in
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

