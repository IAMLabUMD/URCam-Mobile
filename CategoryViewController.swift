//
//  CategoryViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/28/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit

class CategoryViewController: BaseViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor.init(red: 64.0/255.0, green: 148.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        addSlideMenuButton()
        print("....")
    }
    
    @IBAction func foodButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Food"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    @IBAction func drinksButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Drinks"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    @IBAction func clothesButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Clothes"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    @IBAction func petButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Pet"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    @IBAction func cosmeticsButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Cosmetics"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    @IBAction func otherButtonAction(_ sender: Any) {
        ParticipantViewController.category = "Other"
        performSegue(withIdentifier: "ShowCamera", sender: sender)
    }
    
    
    // passing variable to the next view
    // https://learnappmaking.com/pass-data-between-view-controllers-swift-how-to/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
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
