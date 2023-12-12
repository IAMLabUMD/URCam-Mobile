//
//  BaseNavigationController.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 2/23/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.1
    }

}
