//
//  CamFinishViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/17/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class CamFinishViewController: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var object_name = ""
    var parentView: UIViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //textToSpeech("You finished taking 30 photos of \(object_name)")
        titleLabel.becomeFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.titleLabel)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParticipantViewController.writeLog("CamDoneView")
        animateView()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("CameraDoneOKButton-\(self.object_name)")
        
        let tvc = self.storyboard?.instantiateViewController(withIdentifier: "TrainingViewController") as! TrainingViewController
        tvc.object_name = self.object_name
        parentView.navigationController?.pushViewController(tvc, animated: true)
 
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    func textToSpeech(_ text: String) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        print("tts: \(text)")
        myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        myUtterance.volume = 1.0
        synth.speak(myUtterance)
    }
 */
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
}
