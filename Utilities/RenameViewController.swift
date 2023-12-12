//
//  RenameViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/15/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit

class RenameViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    var orgName = ""
    var orgView: UIViewController!
    var httpController = HTTPController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameField.placeholder = "\(orgName). enter new name."
        nameField.becomeFirstResponder()
        nameField.delegate = self
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func okButtonAction(_ sender: Any) {
        let newName = nameField.text!
        
        if newName == "" {
        } else {
            httpController.requestRename(org_name: orgName, new_name: newName){}
            
            do {
                let fileManager = FileManager.init()
                var isDirectory = ObjCBool(true)
                if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent(orgName).appendingPathComponent("recording-\(orgName).wav").path, isDirectory: &isDirectory) {
                    try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent(orgName).appendingPathComponent("recording-\(orgName).wav").path, toPath: Log.userDirectory.appendingPathComponent(orgName).appendingPathComponent("recording-\(newName).wav").path)
                }
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent(orgName).path, toPath: Log.userDirectory.appendingPathComponent(newName).path)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
            orgView.title = newName
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
}    
