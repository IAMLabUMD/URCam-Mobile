//
//  TableViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 5/6/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

    @IBAction func Back() {
        self.dismiss(animated: true, completion: nil)
    }

}
