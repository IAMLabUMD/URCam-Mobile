//
//  AboutVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 10/19/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var bgView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = Functions.createHeaderView(title: "About")
        
        titleLabel.font = .rounded(ofSize: 16, weight: .bold)
        textView.font = .rounded(ofSize: 16, weight: .medium)
        
        view.backgroundColor =  .themeBackground
        textView.backgroundColor = .white
        bgView.layer.cornerRadius = 12
    }

}
