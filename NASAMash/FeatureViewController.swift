//
//  FeatureViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 2/28/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class FeatureViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

