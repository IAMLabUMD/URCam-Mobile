//
//  ItemAudioVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 3/3/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit
import AVFoundation

class ItemAudioVC: BaseItemAudioVC {

    let playImage = #imageLiteral(resourceName: "play_button").withRenderingMode(.alwaysTemplate)
    let rewindImage = #imageLiteral(resourceName: "rewind").withRenderingMode(.alwaysTemplate)
    let forwardImage = #imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate)
    let stopImage = #imageLiteral(resourceName: "stop").withRenderingMode(.alwaysTemplate)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.objScreen.rawValue), object= \(objectName)")
        
        let headerName = Functions.separateWords(name: objectName)
        
        let editButton = UIButton()
        editButton.setTitleColor(.white, for: .normal)
        editButton.setTitleColor(.lightGray, for: .highlighted)
        editButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        editButton.setTitle("EDIT", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        editButton.accessibilityLabel = "Edit. This button takes you to a screen that will allow you to edit information about \(headerName)."
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        mainActionButton.accessibilityLabel = "Play"
        elapsedLabel.accessibilityLabel = "Elapsed time"
        remainingLabel.accessibilityLabel = "Time remaining"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fileExist {
            setupButtons()
            audioPlayer.delegate = self
        }
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.objScreen.rawValue)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.objScreen.rawValue), object= \(objectName)")
    }
    
    override func handleMainActionButton() {
        Log.writeToLog("ItemAudioPlay")
                
        if audioController.isAudioPlaying() {
            print("Not playing")
            audioController.stopAudio()
            
            mainActionButton.setImage(playImage, for: UIControlState.normal)
            
            tertiaryButton.isEnabled = false
            tertiaryButton.isAccessibilityElement = false
            secondaryButton.isEnabled = false
            secondaryButton.isAccessibilityElement = false
            
        } else {
//            audioController.playFileSound(name: "recording-\(objectName).wav", delegate: nil)
            audioDuration = audioPlayer.duration - 0.3
            audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkAudioTime), userInfo: nil, repeats: true)
            print("Playing")
            mainActionButton.setImage(stopImage, for: UIControlState.normal)
            
            secondaryButton.isEnabled = true
            secondaryButton.isAccessibilityElement = true
            tertiaryButton.isEnabled = true
            tertiaryButton.isAccessibilityElement = true
        }
    }
    
    
    func setupButtons() {
        // Set up the action buttons
        mainActionButton.setImage(playImage, for: .normal)
        mainActionButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
        secondaryButton.setImage(rewindImage, for: .normal)
        tertiaryButton.setImage(forwardImage, for: .normal)
        secondaryButton.isHidden = true
        tertiaryButton.isHidden = true
        remainingLabel.text = timeFloatToStr(audioPlayer.duration - 0.3)
    }
    

    @objc
    func editButtonAction() {
        
        let vc = ItemInfoVC()
        vc.objectName = objectName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK:- Button action functions
    @objc
    func playButtonAction() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            mainActionButton.setImage(playImage, for: .normal)
        } else {
            
            // This introduces a delay when voiceover is on so there's no interferance in playback
            if UIAccessibilityIsVoiceOverRunning() {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.audioPlayer.play()
                }
            } else {
                audioPlayer.play()
            }
            
            mainActionButton.setImage(stopImage, for: .normal)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        mainActionButton.setImage(playImage, for: .normal)
    }
}
