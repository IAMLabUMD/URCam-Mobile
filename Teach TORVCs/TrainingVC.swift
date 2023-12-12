//
//  TrainingVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 3/9/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingVC: BaseItemAudioVC {
    
    var isRecording = false
    var recordedAudio = false
    
    var hasName = false
    var isTraining = true
    var object_name = "tmpobj"
    var trainChecker: Timer!
    var toastLabel: UILabel!
    var guideText = "You can add a personal note to the item by recording an audio description of the item. For example, my favorite almond, cashew and walnut nutbars from Kirkland."
    var olView: UIView!
    
    var recordingSession: AVAudioSession!
    var httpController = HTTPController()
    var fileName = "recording-tmpobj.wav"
    var train_id: String?
    
    var saveButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        view.accessibilityLabel = "Enter description"
        navigationItem.titleView = Functions.createHeaderView(title: "New Object")
        presentEnterNameVC(hideCancelBtn: true)
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.editNewObjScreen.rawValue)")
        print("start TrainingVC")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.editNewObjScreen.rawValue)")
    }
    
    
    override func handleMainActionButton() {
        print("Overiding and action should be recording..")
        handleRecording()
    }
    
    override func handleSecondaryActionButton() {
        presentEnterNameVC(hideCancelBtn: false)
    }
    
    func setupButtons() {
        
        // Set up the action buttons
        let playImage = #imageLiteral(resourceName: "record")
        
        mainActionButton.setImage(playImage, for: .normal)
        secondaryButton.setTitle("RENAME", for: .normal)
        tertiaryButton.setTitle("RESET", for: .normal)
        
        progressBar.isHidden = true
        elapsedLabel.isHidden = true
        remainingLabel.isHidden = true
        
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .highlighted)
        saveButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        saveButton.accessibilityLabel = "Save \(objectName) to you items and begin training."
        saveButton.isHidden = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
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
    
    
    @objc
    func saveButtonAction() {
        //TODO: Handle saving object to database and begin training..
        print("Saving.....")
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) saveButton")
        
//        textToSpeech("Uploading images")
//        activityIndicator("Uploading images")
        
            
        DispatchQueue.global(qos: .background).async {
            //self.uploadPhotos()
            
            Functions.deleteImages(for: self.object_name)
            Functions.saveRecording(for: self.object_name, oldName: "")
            
            self.textToSpeech("Training started.")
            self.httpController.reqeustTrain(train_id: self.train_id!, object_name: self.object_name){(response) in
            }
            
            // upload arkit info
//            self.httpController.sendARInfo(object_name: self.object_name) {(response) in
//                print("Send AR Info: " + response)
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                Functions.stopGyros()
            }
            
            DispatchQueue.main.async {
//                self.effectView.removeFromSuperview()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    ///MARK: - This sends the photos to the database for training
    func uploadPhotos() {
        let images = Functions.fetchImages(for: "tmpobj")
        
        for (index, image) in images.enumerated() {
            self.httpController.sendImage(object_name: self.object_name, index: index, image: image) {}
        }
        
        textToSpeech("Training started.")
        self.httpController.reqeustTrain(train_id: "", object_name: "") {(response) in
//            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Training ended.")
//            print("Training ended.")
        }
        
        Functions.deleteImages(for: self.object_name)
        Functions.saveRecording(for: self.object_name, oldName: "")
    }
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var strLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    func activityIndicator(_ title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 - 200, width: 200, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
//    func markTraining() {
//        let file = "trainMark.txt" //this is the file. we will write to and read from it
//        let text = "on"
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let fileURL = dir.appendingPathComponent(file)
//
//            //writing
//            do {
//                try text.write(to: fileURL, atomically: false, encoding: .utf8)
//            }
//            catch {/* error handling here */}
//        }
//    }
    
    func openEnterNameView() {
        // custom view
        // https://medium.com/if-let-swift-programming/design-and-code-your-own-uialertview-ec3d8c000f0a
        let customAlert = storyboard?.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        //customAlert.delegate = self
        //customAlert.parentView = self
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func presentEnterNameVC(hideCancelBtn: Bool) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let enterNameVC = mainStoryboard.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        enterNameVC.modalPresentationStyle = .overCurrentContext
        enterNameVC.providesPresentationContextTransitionStyle = true
        enterNameVC.definesPresentationContext = true
        enterNameVC.modalTransitionStyle = .crossDissolve
        enterNameVC.trainingVC = self
        enterNameVC.hideCancelButton = hideCancelBtn
        present(enterNameVC, animated: true, completion: nil)
        
    }
    
    func rename(newName: String) {
        Log.writeToLog("\(Actions.renamedSavedObj.rawValue) new_name= \(newName)")
        print("---> Invoking rename function...")
        
        self.title = object_name
        navigationItem.titleView = Functions.createHeaderView(title: newName)
        object_name = newName
        hasName = true
        saveButton.isHidden = false
    }
    
    
    /// -----------------------------------------------------------------------
    //  RECORDING FUNCTIONS
    /// -----------------------------------------------------------------------
    
    //var isRecorded = false
    func handleRecording() {
        
        if recordedAudio {
            
            progressBar.isHidden = false
            elapsedLabel.isHidden = false
            remainingLabel.isHidden = false
            
            if audioController.isAudioPlaying() {
                
                audioTimer.invalidate()
                audioController.stopAudio()
                progressBar.progress = 0.0
            } else {
                
                // This introduces a delay when voiceover is on so there's no interferance in playback
                if UIAccessibilityIsVoiceOverRunning() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        
                        self.audioController.playFileSound(name: "recording-tmpobj.wav", delegate: nil)
                        self.audioDuration = self.audioController.audioPlayer.duration - 0.3
                        self.audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.checkAudioTime), userInfo: nil, repeats: true)
                        self.remainingLabel.text = self.timeFloatToStr(self.audioDuration)
                    }
                } else {
                    
                    audioController.playFileSound(name: "recording-tmpobj.wav", delegate: nil)
                    audioDuration = audioController.audioPlayer.duration - 0.3
                    audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkAudioTime), userInfo: nil, repeats: true)
                    remainingLabel.text = timeFloatToStr(audioDuration)
                }
            }
            return
        }
        
        if isRecording {
            ParticipantViewController.writeLog("TrainRecordStop")
            print("Stop recording -----> ")
            
            audioController.stopRecording()
            
            isRecording = false
            recordedAudio = true
            mainActionButton.setImage(#imageLiteral(resourceName: "play_button"), for: .normal)
            
        } else {
            mainActionButton.setImage(#imageLiteral(resourceName: "recording"), for: .normal)
            ParticipantViewController.writeLog("TrainRecordStart")
            print("Recording -----> ")
            
            // This introduces a delay when voiceover is on so there is no interference during recording
            if UIAccessibilityIsVoiceOverRunning() {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    print("Now recording")
                    self.audioController.startRecording(fileName: "recording-tmpobj.wav", delegate: nil)
                    self.isRecording = true
                }
                
            } else {
                
                self.audioController.startRecording(fileName: "recording-tmpobj.wav", delegate: nil)
                self.isRecording = true
                
            }
        }
    }
    
    @objc
    override func checkAudioTime() {
        let currTime = audioController.audioPlayer.currentTime
        if currTime >= audioDuration {
           audioController.stopAudio()
           audioTimer.invalidate()
           
           progressBar.progress = 0.0
           elapsedLabel.text = "0:00"
           remainingLabel.text = timeFloatToStr(audioDuration)
        } else {
           progressBar.progress = Float(currTime / audioDuration)
           elapsedLabel.text = timeFloatToStr(currTime)
           //remainingLabel.text = "-\(timeFloatToStr(Double(Int(audioDuration)) - currTime + 1.0))"
       }
    }
    

    

}

