//
//  OnboardingViewsController.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 3/7/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

class OnboardingViewsController: UIViewController {

    var screens = [OnboardingScreen]()
    @IBOutlet weak var containerView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .themeForeground
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let scan = OnboardingScreen(title: "Scan", description: "Hold up your phone and recognize objects just by pointing your camera at them.", image: UIImage(named: "scan")!.withRenderingMode(.alwaysTemplate), index: 1)
        let teach = OnboardingScreen(title: "Teach", description: "Take 30 photos of the object you would like to recognize and the object recognizer will train itself to identify that object.", image: UIImage(named: "teach")!.withRenderingMode(.alwaysTemplate), index: 2)
        let view = OnboardingScreen(title: "Review", description: "Check the list of items. Listen to the audio description and edit the name of an object in the list.", image: UIImage(named: "items")!.withRenderingMode(.alwaysTemplate), index: 3)
        
        scan.next = teach
        teach.previous = scan
        teach.next = view
        view.previous = teach
        
        screens = [scan, teach, view]
        
        if segue.identifier == "embededSegue" {
            
            if let destination = segue.destination as? OnboardingVC {
                destination.screen = screens[0]
            }
        }
    }
}
