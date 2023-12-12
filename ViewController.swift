//
//  CollectionViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 11/14/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ViewController: UIViewController {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    let CokeLabel = ["1","2","3","4","5","6","7","8","9","10"]
    let CokeImages: [UIImage] =  [
         UIImage(named:"1")!,
         UIImage(named:"2")!,
         UIImage(named:"3")!,
         UIImage(named:"4")!,
         UIImage(named:"5")!,
         UIImage(named:"6")!,
         UIImage(named:"7")!,
         UIImage(named:"8")!,
         UIImage(named:"9")!,
         UIImage(named:"10")!,
        
         ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    override func didReceiveMemoryWarning() {
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CokeLabel.count
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.CokeLabel.text = CokeLabel[indexPath.item]
        cell.CokeImageView.image = CokeImages[indexPath.item]
        
        return cell
        
    }

    

}
