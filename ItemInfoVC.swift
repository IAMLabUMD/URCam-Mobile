//
//  ItemInfoVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 3/3/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit
import AVFoundation

class ItemInfoVC: BaseItemAudioVC {
    
    var isRecording = false
    
    var hasName = false
    var isTraining = true
    var recordedAudio = false
    var madeChanges = false
    var object_name = "tmpobj"
    var previousName = ""
    var trainChecker: Timer!
    var toastLabel: UILabel!
    var guideText = "You can add a personal note to the item by recording an audio description of the item. For example, my favorite almond, cashew and walnut nutbars from Kirkland."
    var olView: UIView!
    var saveButton: UIButton!
    
    var recordingSession: AVAudioSession!
    //var audioRecorder: AVAudioRecorder!
    var httpController = HTTPController()
    let playImage = #imageLiteral(resourceName: "record")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        let headerName = Functions.separateWords(name: objectName)
        object_name = headerName
        previousName = headerName
        navigationItem.titleView = Functions.createHeaderView(title: "Edit \(headerName)")
        mainActionButton.accessibilityLabel = "Record button"
        elapsedLabel.accessibilityLabel = "Elapsed time"
        remainingLabel.accessibilityLabel = "Time remaining"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.editSavedObjScreen.rawValue)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.editSavedObjScreen.rawValue)")
    }
    
    
    override func handleMainActionButton() {
        print("Overiding and action should be recording..")
        handleRecording()
    }
    
    override func handleSecondaryActionButton() {
        presentEnterNameVC()
    }
    
    override func handleTertiaryActionButton() {
        
        recordedAudio = false
        isRecording = false
        progressBar.isHidden = true
        elapsedLabel.isHidden = true
        remainingLabel.isHidden = true
        
        mainActionButton.setImage(playImage, for: .normal)
        mainActionButton.accessibilityLabel = "Record"
    }
    
    func setupButtons() {
        
        // Set up the action buttons
        mainActionButton.setImage(playImage, for: .normal)
        secondaryButton.setTitle("RENAME", for: .normal)
        tertiaryButton.setTitle("RESET", for: .normal)
        
        progressBar.isHidden = true
        elapsedLabel.isHidden = true
        remainingLabel.isHidden = true
        
        
        saveButton = UIButton()
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.lightGray, for: .highlighted)
        saveButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        saveButton.accessibilityLabel = "Saves changes made to \(Functions.separateWords(name: objectName))."
        saveButton.isHidden = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
    }
    
    @objc
    func saveButtonAction() {
        
        // Handle saving object to database and begin training..
        print("Saving.....")
        if madeChanges {
            saveAudio(newName: objectName)
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    func presentEnterNameVC() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let enterNameVC = mainStoryboard.instantiateViewController(withIdentifier: "EnterNameUI") as! EnterNameController
        enterNameVC.modalPresentationStyle = .overCurrentContext
        enterNameVC.providesPresentationContextTransitionStyle = true
        enterNameVC.definesPresentationContext = true
        enterNameVC.modalTransitionStyle = .crossDissolve
        let headerName = Functions.separateWords(name: objectName)
        enterNameVC.header = "Rename \(headerName)"
        enterNameVC.itemInfoVC = self
        present(enterNameVC, animated: true)
    }
    
    func saveAudio(newName: String) {
        
        print("Previous name: \(previousName), New name: \(objectName)")
        do {
            
            let fileManager = FileManager.default
            let path = Log.userDirectory.appendingPathComponent(objectName).appendingPathComponent("\(previousName).wav").path
            print("Audio file: \(path)")
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent("recording-tmpobj.wav").path) {

                print("We recorded a new audio")
                Functions.saveRecording(for: newName, oldName: previousName)
                 
            } else if fileManager.fileExists(atPath: path) {
                print("We are renaming the saved recording because file exists at path")
                try fileManager.moveItem(atPath: path, toPath: Log.userDirectory.appendingPathComponent(objectName).appendingPathComponent("\(objectName).wav").path)
                
                
            } else {
                
                // File does not exist at the path created
                print("Failed switching audio")
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func rename(newName: String) {

        print("Renaming object to ---> \(newName)")
        Log.writeToLog("TrainingView-rename-\(newName)")
        httpController.requestRename(org_name: objectName, new_name: newName){}

        do {
            let fileManager = FileManager.init()
            var isDirectory = ObjCBool(true)

            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent(object_name).path, isDirectory: &isDirectory) {
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent(object_name).path, toPath: Log.userDirectory.appendingPathComponent(newName).path)
                print("Good with new path: \(Log.userDirectory.appendingPathComponent(newName).path)")
            }
            
            
            //change directory name
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent(objectName).path, isDirectory: &isDirectory) {
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent(objectName).path, toPath: Log.userDirectory.appendingPathComponent(newName).path)
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }

        self.title = objectName
        navigationItem.titleView = Functions.createHeaderView(title: "Edit \(newName)")
        madeChanges = true
        
        objectName = newName
        hasName = true
        saveButton.isHidden = false

        
        guard let count = self.navigationController?.viewControllers.count else {
            print("no view controllers in the navigation controller")
            return
        }
        if count > 1 {
            if let attrVC = self.navigationController?.viewControllers[count-2] as? ItemAttrAndInfoVC {
                //Set the value
                attrVC.objectName = newName
            }
        }
    }
    
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
            saveButton.isHidden = false
            madeChanges = true
            tertiaryButton.isHidden = false
            mainActionButton.accessibilityLabel = "Play"
            
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

extension ItemInfoVC: EnterNameViewDelegate {
    
    func addItemTapped(object_name: String) {
        
        
    }
    
    
    func cancelButtonTapped() {
        print("Cancel tapped...")
    }
    
}
