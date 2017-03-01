//
//  APODViewController.swift
//  NASAMash
//
//  Created by redBred LLC on 3/1/17.
//  Copyright © 2017 redBred. All rights reserved.
//

import UIKit

class APODViewController: UIViewController {

    let model = Model.shared
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(APODViewController.onChanges), name: Notification.Name(Model.Notifications.apodImagesChanged.rawValue), object: model)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func onChanges() {
        collectionView.reloadData()
    }
}





//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.apodImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "APODCell", for: indexPath) as! APODCell
        
        let apodImage = model.apodImages[indexPath.item]
        
        cell.title.text = apodImage.title
        cell.imageURL = apodImage.url
        
        if let copyright = apodImage.copyright {
            cell.subtitle.text = copyright
        } else {
            cell.subtitle.text = ""
        }
        
        return cell
    }
    
    
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat
        
        if indexPath.item == 0 {
            width = collectionView.frame.size.width
        } else {
            width = collectionView.frame.size.width/2
        }
        
        return CGSize(width: width, height: width/2)
    }
}




//////////////////////////////////////////////////////////////
// MARK: - UICollectionViewDataSource
extension APODViewController: UICollectionViewDelegate {
    
    
}





