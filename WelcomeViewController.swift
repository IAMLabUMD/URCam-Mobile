//
//  WelcomeViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/29/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "isFristOpenApp")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
