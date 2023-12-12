//
//  HelpViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/12/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let avenirBold = UIFont(name: "AvenirNext-Bold", size: UIFont.labelFontSize)!
    let avenirMedium = UIFont(name: "AvenirNext-Medium", size: UIFont.labelFontSize)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.helpScreen.rawValue)")

        // Do any additional setup after loading the view.
        self.title = "Tutorials"
//        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
//        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white]
        addGuide()
        navigationItem.titleView = Functions.createHeaderView(title: "TUTORIALS")
//        ParticipantViewController.writeLog("HelpView")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.helpScreen.rawValue)")
    }
    
    func addGuide() {
//        var y = addHead("Overview", y: 20)
//        y = addBody("Teachable object recognizer (TOR) is an object recognizer that you can train by taking photos of your own objects. The TOR extracts visual information from your object and convert it to a name that you assigned to the object. You can learn how to teach, recognize, and manage items with this TOR below.", y: y)
        
        var y = addHead("Teach Objects", y: 20)
        y = addBody("To start teaching an object, tap on the teach TOR button in the home screen. You will be prompted to enter the name of the object that you want to teach to TOR. After you enter the name, it will take you to a new screen where you can take photos. \n\nYou need to take 30 photos by selecting take photo button in the screen. For every 5 photos, the screen will tell you how many photos are left until 30. When you are done with taking photos, you will be prompted with a message saying 'you finished taking 30 photos' and an OK button. Tap on the OK button to go to the next screen. \n\n At the next screen, this app will start teaching itself, which takes 1 minute. While waiting, you can record a description of the object by tapping on the record button in the screen. The app will tell you when the training is done.", y: y)
        
        y = addHead("Scanning Objects", y: y)
        y = addBody("You can scan items in the home screen. Move the camera frame to include the item and tap on the scan item button. You will hear the recognition result in response.", y: y)
        
        y = addHead("Managing items", y: y)
        y = addBody("Tap on the view item list. This will take you to the screen with a list of items that you have taught to this TOR. Tap on the item that you want to change the name, audio description, or photos. This will take you to the next screen where you can do these tasks.", y: y)
        
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: y)
    }
    
    
    func addHead(_ text: String, y: CGFloat) -> CGFloat {
        let height = CGFloat(25)
        let marginTop = CGFloat(30)
        let label = UILabel(frame: CGRect(x:30, y:y + marginTop, width: self.view.frame.size.width - 60, height: CGFloat(height)))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.black
        label.textAlignment = .left;
//        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
//        label.font = UIFont(name: "AvenirNext-Bold", size: 21)
        label.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: avenirBold)
        label.adjustsFontForContentSizeCategory = true
        label.text = text
        label.alpha = 1.0
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.frame.size.width = self.view.frame.size.width - 60
        self.scrollView.addSubview(label)
        return y+height+marginTop
    }
    
    func addBody(_ text: String, y: CGFloat) -> CGFloat {
        let height = CGFloat(25)
        let label = UILabel(frame: CGRect(x:30, y:y, width: self.view.frame.size.width - 60, height: CGFloat(height)))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.black
        label.textAlignment = .left;
        //label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: avenirMedium)
        label.adjustsFontForContentSizeCategory = true
        label.text = text
        label.alpha = 1.0
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.frame.size.width = self.view.frame.size.width - 60
        self.scrollView.addSubview(label)
        return y+label.frame.height
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
