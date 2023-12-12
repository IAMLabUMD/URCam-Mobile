//
//  EnterNameController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/4/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

import UIKit

class EnterNameController: UIViewController, UITextFieldDelegate {
    // custom alert view
    // https://medium.com/if-let-swift-programming/design-and-code-your-own-uialertview-ec3d8c000f0a
    
    @IBOutlet weak var objName: UITextField!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var enterNameLabel: UILabel!
    
    var header = "Name your object"
    var objectName: String?
    //var delegate: EnterNameViewDelegate?
    //var parentView: TrainingVC!
    var parentView: UIViewController!
    var trainingVC: TrainingVC?
    var itemInfoVC: ItemInfoVC?
    var confirmTitle = ""
    var denyTitle = ""
    var hideTextfield = false
    var hideCancelButton = false
    var placeholder = "Enter the name of this object"
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view, typically from a nib.
        enterNameLabel.becomeFirstResponder()
//        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, "Enter name")
//        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.enterNameLabel)
        objName.delegate = self
        //print("EnterName: \(ParticipantViewController.category) \(ParticipantViewController.itemNum)")
        objName.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.rounded(ofSize: 16, weight: .medium)])
        enterNameLabel.text = header
        enterNameLabel.font = .rounded(ofSize: 16, weight: .bold)
        saveButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        cancelButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        alertView.addShadow()
        
        saveButton.isEnabled = false
        saveButton.backgroundColor = .lightGray
        
        objName.isHidden = hideTextfield
        cancelButton.isHidden = hideCancelButton
        
        if confirmTitle != "" {
            saveButton.setTitle(confirmTitle, for: .normal)
        }
        
        if denyTitle != "" {
            cancelButton.setTitle(denyTitle, for: .normal)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParticipantViewController.writeLog("EnterNameView")
        Log.writeToLog("action= presented_enter_name_dialog")
        setupView()
        animateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let objectName = objectName {
            itemInfoVC?.rename(newName: objectName)
            trainingVC?.rename(newName: objectName)
        }
        
        if parentView != nil {
            if let settingsVC = parentView as? SettingsVC {
                settingsVC.tableView.reloadData()
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    func setupView() {
        //alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func enterName(_ sender: Any) {
        ParticipantViewController.writeLog("NameOKButton-\(objName.text!)")
        Log.writeToLog("\(Actions.tappedOnBtn) okEnterNameButton")
        
        let oName = objName.text!
        
        
        if oName == "" {
            
        } else {
            
            objectName = oName
            Log.writeToLog("action= entered name: \(oName)")
            self.dismiss(animated: true, completion: nil)
            
        }
        
        if parentView != nil {
            
            if let newParticipantID = objName.text {
                
                UserDefaults.standard.set(newParticipantID, forKey: "participantID")
                Log.participantID = newParticipantID
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("NameCancelButton")
        
        Log.writeToLog("\(Actions.tappedOnBtn) cancelEnterNameButton")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, cancelButton)
        return true
    }
    
    
    @IBAction func didEnterText(_ sender: UITextField) {
        
        if Functions.validText(text: sender.text) {
            saveButton.isEnabled = true
            saveButton.backgroundColor = #colorLiteral(red: 0, green: 0.5663797259, blue: 0.3164396882, alpha: 1)
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .lightGray
        }
    }
    
}
