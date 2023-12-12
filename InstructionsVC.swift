//
//  InstructionsVC.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 2/21/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

class InstructionsVC: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    @IBOutlet weak var trainTextView: UILabel!
    @IBOutlet weak var testTextView: UILabel!
    @IBOutlet weak var viewTextView: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    var hideOkButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBackground
        bgView.layer.cornerRadius = 12
        
        trainTextView.backgroundColor = .white
        testTextView.backgroundColor = .white
        viewTextView.backgroundColor = .white
        
        instructionsLabel.font = .rounded(ofSize: 16, weight: .heavy)
        trainLabel.font = .rounded(ofSize: 16, weight: .heavy)
        testLabel.font = .rounded(ofSize: 16, weight: .heavy)
        viewLabel.font = .rounded(ofSize: 16, weight: .heavy)
        
        trainTextView.font = .rounded(ofSize: 16, weight: .medium)
        testTextView.font = .rounded(ofSize: 16, weight: .medium)
        viewTextView.font = .rounded(ofSize: 16, weight: .medium)
        
        okButton.roundButton(withBackgroundColor: .clear, opacity: 0)
        okButton.titleLabel?.font = .rounded(ofSize: 14, weight: .bold)
        okButton.backgroundColor = .themeForeground
        okButton.setTitleColor(.white, for: .normal)
        
        okButton.isHidden = hideOkButton
        
        navigationItem.titleView = Functions.createHeaderView(title: "Tutorials")
        
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
