//
//  SettingsTableVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 5/20/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {

    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet weak var versionLabel: UILabel!
    
    let kVersion = "CFBundleShortVersionString"
    let kBuildNumber = "CFBundleVersion"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = Functions.createHeaderView(title: "MORE")
        view.backgroundColor = .white
        
        versionLabel.text = "version \(getVersionNumber())"
        
        addActions()
    }

    // MARK: - Gets the version number for the app
    func getVersionNumber() -> String {
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        
        return version
    }
    
    // MARK: - This function adds actions to the tableview cells
    func addActions() {
        
        cells.forEach({$0.contentView.isUserInteractionEnabled = true})
        cells[0].contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showHelpVC)))
        cells[1].contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAboutsVC)))
        cells[2].contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSettingsVC)))
        
    }
    
    
    // MARK: - Action handlers
    @objc
    func showHelpVC() {
        
        let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    
    @objc
    func showSettingsVC() {
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc
    func showAboutsVC() {
        let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "aboutVC") as! AboutVC
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }


}

