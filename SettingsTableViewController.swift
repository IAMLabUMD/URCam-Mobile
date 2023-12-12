//
//  SettingsTableViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 10/30/18.
//  Modified by Ernest Essuah Mensah on 10/19/20
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = Functions.createHeaderView(title: "SETTINGS")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func Back() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
