//
//  SettingsVC.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 2/21/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

protocol SettingsVCDelegate {
    func didTapOnButton(cell: SettingsCell)
}

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SettingsVCDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 12
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        tableView.delaysContentTouches = false
        
        view.backgroundColor = .themeBackground
        
        navigationItem.titleView = Functions.createHeaderView(title: "Settings")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
        
        if indexPath.section == 0 {
            cell.label.text = Log.participantID
            cell.cellDelegate = self
            
        } else {
            
            cell.label.text = "Settings option \(indexPath.row)"
            cell.button.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 72))
        headerView.backgroundColor = .themeBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40))
        
        if section == 0 {
            headerLabel.text = "Participant ID"
        }
        
        if section == 1 {
            headerLabel.text = "Other"
        }
        
        headerLabel.textColor = .darkGray
        headerLabel.font = .rounded(ofSize: 16, weight: .heavy)
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func presentRenameVC() {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let enterNameVC = mainStoryboard.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        enterNameVC.modalPresentationStyle = .overCurrentContext
        enterNameVC.providesPresentationContextTransitionStyle = true
        enterNameVC.definesPresentationContext = true
        enterNameVC.modalTransitionStyle = .crossDissolve
        enterNameVC.header = "Reset the participantID?"
        enterNameVC.parentView = self
        enterNameVC.hideTextfield = false
        enterNameVC.confirmTitle = "DONE"
        enterNameVC.denyTitle = "CANCEL"
        enterNameVC.placeholder = "Enter the new ParticipantID"
        present(enterNameVC, animated: true)
        
    }
    
    func didTapOnButton(cell: SettingsCell) {
        showOptions()
    }
    
    func resetParticipantID() {
        
        // ParticipantID does not exist. Create one and store it
        let uuid = UUID().uuidString
        let participantID = uuid.components(separatedBy: "-").first ?? "0ADE198"
        UserDefaults.standard.set(participantID, forKey: "participantID")
        Log.participantID = participantID
    }
    
    func showOptions() {
        
        let resetManuallyAction = UIAlertAction(title: "Reset manually", style: .default) { (action) in
            self.presentRenameVC()
        }
        
        let generateIDAction = UIAlertAction(title: "Generate ParticipantID", style: .default) { (action) in
            self.resetParticipantID()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
            
        let alert = UIAlertController(title: "Reset ParticipantID?", message: "", preferredStyle: .actionSheet)
        alert.addAction(resetManuallyAction)
        alert.addAction(generateIDAction)
        alert.addAction(cancelAction)
            
        self.present(alert, animated: true) {
          // The alert was presented
        }
    }
}


class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var cellDelegate: SettingsVCDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = .rounded(ofSize: 16, weight: .bold)
        button.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        button.setTitleColor(.themeForeground, for: .normal)
    }
    
    @IBAction func handleTapOnButton(_ sender: UIButton) {
        cellDelegate.didTapOnButton(cell: self)
    }
}
