//
//  GuideViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 10/15/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit

class GuideViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
   
    var category = ""
    var userName = ""
    
    let detailsArr = ["Quick Guide \n\n 1. While taking training photos, lay the object down on the table or any other flat surface to take the photos and identify it. \n\n 2. Set the title and an optional audio description for the object you are about to capture. \n\n 3. TOR will guide you with the camera placement. Make the necessary adjustments until you hear 'Hold Steady'. \n\n 4. A good teaching technique is to place the camera on the center of the object, and slowly move away relative to the size of the object. It is helpful to keep the camera parallel to the surface. \n\n 5. TOR works best when you capture lot of angles and variationsof the object you want it to recognize. Ypu should capture 30 images per object. "]
    @IBOutlet weak var table_multilineLabel:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //addSlideMenuButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! GuideTableViewCell ///table cell
        
        cell.detailsLabel.text = detailsArr[indexPath.row] ///fill in label with text
        return cell
    }
    
}
