//
//  MenuViewController.swift
//  TORSlideMenu
//
//  Created by Jaina Gandhi on 10/14/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit
protocol SlideMenuDelegate {
    func slidemenuItemSelectedAtIndex(_ index : Int32)
    
}
class MenuViewController: UIViewController {
    
    @IBOutlet weak var btnCloseMenuOverlay: UIButton!
    var btnMenu : UIButton!
    var delegate : SlideMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.btnCloseMenuOverlay.layer.cornerRadius = 20
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        /*
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if ( self.delegate != nil){
            var index = Int32(sender.tag)
            if(sender == self.btnCloseMenuOverlay){
                index = -1
            }
            
            delegate?.slidemenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width:
                UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                 self.view.layoutIfNeeded()
                 self.view.backgroundColor = UIColor.clear},
                       completion: { (finished) -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
            
        })
         */
        //self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func btnSettingsTapped(_ sender: Any) {
        
//        let mainStoreboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let DVC = mainStoreboard.instantiateViewController(withIdentifier: "SettingsTableViewController") as! SettingsTableViewController
//        self.navigationController?.pushViewController(DVC, animated: true)
        
    }
    
    
    @IBAction func btnGuideTapped(_ sender: Any) {
        
        let mainStoreboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let DVC = mainStoreboard.instantiateViewController(withIdentifier: "GuideViewController") as! GuideViewController
        self.navigationController?.pushViewController(DVC, animated: true)
    }
    
    
    @IBAction func btnSupportTapped(_ sender: Any) {
        let mainStoreboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let DVC = mainStoreboard.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
        self.navigationController?.pushViewController(DVC, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
