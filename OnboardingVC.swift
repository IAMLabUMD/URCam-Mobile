//
//  OnboardingVC.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 3/7/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

class OnboardingVC: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton?
    @IBOutlet weak var nextButton: UIButton?
    @IBOutlet weak var pageLabel: UILabel!
    
    var screen: OnboardingScreen?
    var nextScreen: OnboardingScreen?
    var previousScreen: OnboardingScreen?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let screen = screen {
            imageView.image = screen.image
            imageView.tintColor = .white
            titleLabel.text = screen.title
            descriptionLabel.text = screen.description
            
            if let next = screen.next {
                nextButton?.isHidden = false
                nextScreen = next
                
            } else {
                nextButton?.setTitle("Done", for: .normal)
            }
            
            if let previous = screen.previous {
                previousButton?.isHidden = false
                previousScreen = previous
                
            } else {
                previousButton?.isHidden = true
            }
            
            pageLabel.text = "\(screen.index) of 3"
        }
        
        view.backgroundColor = .themeForeground
        titleLabel.font = .rounded(ofSize: 21, weight: .bold)
        titleLabel.textColor = .themeForeground
        
        descriptionLabel.font = .rounded(ofSize: 18, weight: .bold)
        descriptionLabel.textColor = .white
        
        pageLabel.font = .rounded(ofSize: 14, weight: .bold)
        pageLabel.textColor = .white
        
        nextButton?.titleLabel?.font = .rounded(ofSize: 18, weight: .bold)
        nextButton?.setTitleColor(.white, for: .normal)
        
        previousButton?.titleLabel?.font = .rounded(ofSize: 18, weight: .bold)
        previousButton?.setTitleColor(.white, for: .normal)
    }
    

    @IBAction func handleNext(_ sender: Any) {
        
        if let nextScreen = nextScreen {
            
            let newScreen = storyboard?.instantiateViewController(withIdentifier: "onboardingVC") as! OnboardingVC
            newScreen.screen = nextScreen
            navigationController?.pushViewController(newScreen, animated: true)
            
        } else {
            
            // Dismiss the onboarding screens and show the main home screen
            let homescreen = storyboard?.instantiateViewController(withIdentifier: "baseNavVC") as! BaseNavigationController
            homescreen.modalPresentationStyle = .overFullScreen
            present(homescreen, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func handlePrevious(_ sender: Any) {
        
        if previousScreen != nil {
            navigationController?.popViewController(animated: true)
        }
    }
}
