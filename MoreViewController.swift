//
//  MoreViewController.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 2/21/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

protocol MoreTVCellDelegate {
    func didTapOnCell(cell: MoreTableViewCell)
}

class MoreViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    
    var options = ["Tutorials", "About", "Settings"]
    var images = ["book", "info.circle", "gearshape"]
    
    let kVersion = "CFBundleShortVersionString"
    let kBuildNumber = "CFBundleVersion"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        
        tableView.tableFooterView = UIView()
        
        navigationItem.titleView = Functions.createHeaderView(title: "More")
        

        versionLabel.text = "version \(getVersionNumber())"
        versionLabel.font = .rounded(ofSize: 16, weight: .bold)
    }
    
    // MARK: - Gets the version number for the app
    func getVersionNumber() -> String {
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[kVersion] as! String
        
        return version
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreTableViewCell") as! MoreTableViewCell
        cell.cellLabel.text = options[indexPath.row]
        
        if #available(iOS 13.0, *) {
            cell.cellImageView.image = UIImage(systemName: images[indexPath.row])
        } else {
            // Fallback on earlier versions
            //cell.cellImageView.image = UIImage(named: images[indexPath.row])
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.cellIndex = indexPath.row
        cell.cellDelegate = self
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }

}

extension MoreViewController: MoreTVCellDelegate {
    
    
    func didTapOnCell(cell: MoreTableViewCell) {
        
        switch cell.cellIndex {
        case 0:
            let tutorialsVC = self.storyboard?.instantiateViewController(withIdentifier: "instructionsVC") as! InstructionsVC
            tutorialsVC.hideOkButton = true
            navigationController?.pushViewController(tutorialsVC, animated: true)
            
        case 1:
            let aboutVC = self.storyboard?.instantiateViewController(withIdentifier: "aboutVC") as! AboutVC
            navigationController?.pushViewController(aboutVC, animated: true)
            
        case 2:
            let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "settingsVC") as! SettingsVC
            navigationController?.pushViewController(settingsVC, animated: true)
            
        default:
            return
        }
    }
    
}


class MoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    var cellDelegate: MoreTVCellDelegate!
    var cellIndex: Int!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellLabel.font = .rounded(ofSize: 16, weight: .semibold)
        self.contentView.isUserInteractionEnabled = true
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnCell)))
    }
    
    @objc
    func handleTapOnCell() {
        cellDelegate.didTapOnCell(cell: self)
    }
}

