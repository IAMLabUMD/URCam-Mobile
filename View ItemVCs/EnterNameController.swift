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
    
    
    var delegate: EnterNameViewDelecate?
    var parentView: TrainingViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        enterNameLabel.becomeFirstResponder()
//        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, "Enter name")
//        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.enterNameLabel)
        objName.delegate = self
        print("EnterName: \(ParticipantViewController.category) \(ParticipantViewController.itemNum)")
        objName.attributedPlaceholder = NSAttributedString(string: "Enter the name of the new item", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        saveButton.roundButton(withBackgroundColor: .clear, opacity: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParticipantViewController.writeLog("EnterNameView")
        setupView()
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
//        cancelButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
//        cancelButton.addBorder(side: .Right, color: alertViewGrayColor, width: 1)
//        saveButton.addBorder(side: .Top, color: alertViewGrayColor, width: 1)
    }

    func setupView() {
        alertView.layer.cornerRadius = 15
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
        
        let oName = objName.text!
        if oName == "" {
            
        } else {
            parentView.rename(newName: oName)
            
            self.dismiss(animated: true, completion: nil)
            delegate?.addItemTapped(object_name: oName)
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("NameCancelButton")
        parentView.httpController.requestRollback {}
        
        delegate?.cancelButtonTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    // passing variable to the next view
    // https://learnappmaking.com/pass-data-between-view-controllers-swift-how-to/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        /*
        if segue.destination is CameraViewController
        {
            let vc = segue.destination as? CameraViewController
            vc?.object_name = objName.text!
            vc?.itemNum = itemNum
//            self.dismiss(animated: true, completion: nil)
        }
         */
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, cancelButton)
        return true
    }
    
}
