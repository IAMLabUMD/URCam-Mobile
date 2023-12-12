//
//  TrainingViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/14/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class TrainingViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var imgContainer: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressTimePassed: UILabel!
    @IBOutlet weak var progressTimeLeft: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var hasName = false
    var isTraining = true
    var object_name = "tmpobj"
    var trainChecker: Timer!
    var toastLabel: UILabel!
    var guideText = "You can add a personal note to the item by recording an audio description of the item. For example, my favorite almond, cashew and walnut nutbars from Kirkland."
    var olView: UIView!
    
    var images = [UIImage]()
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var httpController = HTTPController()
    var audioController = AudioController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Training View: \(ParticipantViewController.category) \(object_name) \(ParticipantViewController.itemNum)")
        // Do any additional setup after loading the view.
        
        
        addImages()
        images = Functions.fetchImages(for: object_name)
        imagesCollectionView.dataSource = self
        
        navigationItem.titleView = Functions.createHeaderView(title: "NEW ITEM")
        
        let doneButton = UIButton()
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        doneButton.setTitle("DONE", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.accessibilityLabel = "Done. This button will dismiss this screen"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        
        
//        DispatchQueue.global(qos: .background).async{
//            //Time consuming task here
//            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.toastLabel)
//
//            self.markTraining()
//            for i in 1...ParticipantViewController.itemNum {
//                self.httpController.sendImage(object_name: self.object_name, index: i){}
//            }
//
//            self.httpController.reqeustTrain(){
//                //self.textToSpeech("Training ended.")
//                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Training ended.")
//            }
//
//        }
         
        
 
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        //self.navigationItem.setHidesBackButton(true, animated:true);
        //self.navigationController?.navigationBar.accessibilityElementsHidden = true
        
        //makeToast()
        print("TrainingViewController: \(ParticipantViewController.userName) \(ParticipantViewController.category) \(object_name) \(ParticipantViewController.itemNum)")
        
        // add overlay
        if ParticipantViewController.VisitedTrainView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedTrainView = 1
            //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
            olView.becomeFirstResponder()
            
            recordButton.accessibilityElementsHidden = true
            okButton.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
        } else {
            openEnterNameView()
        }
        
        
        ParticipantViewController.writeLog("TrainingView")
        trainChecker = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTraining), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        if self.isMovingFromParentViewController
        {
            //On click of back or swipe back
            print("back")
//            self.httpController.requestRollback {}
        }
    }
    
    @objc func done() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("TrainOKButton-\(object_name)")
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func renameButtonAction(_ sender: Any) {
        openEnterNameView()
    }
    
    
    ///MARK: - This sends the photos to the database for training
    func uploadPhotos() {
        
       DispatchQueue.global(qos: .background).async{
           //Time consuming task here
           UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.toastLabel)
           
           self.markTraining()
           for i in 1...ParticipantViewController.itemNum {
               //self.httpController.sendImage(object_name: self.object_name, index: i){}
           }
           
           self.httpController.reqeustTrain(train_id: "", object_name: "") {(response) in
               //self.textToSpeech("Training ended.")
               print("Training response: \(response)")
               UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "Training ended.")
           }

       }
    }
    
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
    
    
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // add text for guidance
        let label = UILabel(frame: CGRect(x:10, y:10, width: frame.size.width - 60, height: CGFloat(25)))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.white
        label.textAlignment = .left;
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        label.text = guideText
        label.accessibilityLabel = ""
        label.alpha = 1.0
        //label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.frame.size.width = self.view.frame.size.width - 60
        label.isAccessibilityElement = false
        
        
        let labelContainer = UIView(frame: CGRect(x:20, y:frame.midY/3 - 10, width: frame.size.width - 40, height: label.frame.size.height + 20))
        labelContainer.layer.cornerRadius = 15
        labelContainer.layer.masksToBounds = true
        labelContainer.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        labelContainer.isAccessibilityElement = false
        labelContainer.addSubview(label)
        
        overlayView.addSubview(labelContainer)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.touchOverlay(_:)))
        overlayView.addGestureRecognizer(gesture)
        overlayView.isUserInteractionEnabled = true
        overlayView.accessibilityLabel = guideText
        overlayView.isAccessibilityElement = true
        
        return overlayView
    }
    
    // or for Swift 4
    @objc func touchOverlay(_ sender:UITapGestureRecognizer){
        // do other task
        ParticipantViewController.writeLog("TrainOverlayDismiss")
        recordButton.accessibilityElementsHidden = false
        okButton.accessibilityElementsHidden = false
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController)
        olView.removeFromSuperview()
        
        //openEnterNameView()
    }
    
    func makeToast() {
        toastLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 35))
        toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        toastLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = "Training started. Record a voice description of this object by tapping on the record button at the bottom of the screen while you are waiting. Tap on the OK button at the bottom right corner to go back to the main screen."
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        toastLabel.sizeToFit()
        toastLabel.frame.size.width = self.view.frame.size.width
        toastLabel.clipsToBounds  =  true
        //toastLabel.accessibilityElementsHidden = true
    }
    
    func showToast() {
        if !toastLabel.isDescendant(of: view) {
            self.view.addSubview(toastLabel)
        }
    }
    
    func hideToast() {
        if toastLabel.isDescendant(of: view) {
            toastLabel.removeFromSuperview()
        }
    }
    
    @objc func checkTraining() -> Bool {
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                
                if text2.contains("on"){
                    //showToast()
                    //print("yes training")
                    isTraining = true
                    return true
                }
            }
            catch {
                /* error handling here */
                //hideToast()
                //print("no training, exception")
                isTraining = false
                return false
            }
        }
        //print("no training, normal")
        isTraining = false
        //hideToast()
        return false
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
    
     @objc func checkAudioTime() {
         let currTime = audioController.audioPlayer.currentTime
         if currTime >= audioDuration {
            audioController.stopAudio()
            audioTimer.invalidate()
            
            progressBar.progress = 0.0
            let rImage = UIImage(named: "play")
            recordButton.setImage(rImage, for: UIControlState.normal)
            progressTimePassed.text = "0:00"
            progressTimeLeft.text = timeFloatToStr(audioDuration)
         } else {
            progressBar.progress = Float(currTime / audioDuration)
            
            progressTimePassed.text = timeFloatToStr(currTime)
            progressTimeLeft.text = "-\(timeFloatToStr(Double(Int(audioDuration)) - currTime + 1.0))"
        }
     }
    
    func timeFloatToStr(_ time: Double) -> String {
        let min = Int(time/60.0)
        let sec = Int(time)
        //let milli = Int((time-Double(sec))*100)
        if sec < 10 {
            return "\(min):0\(sec)"
        } else {
            return "\(min):\(sec)"
        }
    }
 
    var audioDuration = 0.0
    var audioTimer: Timer!
    var isRecording = false
    var isRecorded = false
    
    @IBAction func recordButtonAction(_ sender: UIButton) {
        if isRecorded {
            if audioController.isAudioPlaying() {
                let rImage = UIImage(named: "play")
                recordButton.setImage(rImage, for: UIControlState.normal)
                
                audioTimer.invalidate()
                audioController.stopAudio()
                progressBar.progress = 0.0
            } else {
                let rImage = UIImage(named: "stop")
                recordButton.setImage(rImage, for: UIControlState.normal)
                
                audioController.playFileSound(name: "recording-tmpobj.wav", delegate: nil)
                audioDuration = audioController.audioPlayer.duration - 0.3
                audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkAudioTime), userInfo: nil, repeats: true)
            }
            return
        }
        
        if isRecording {
            ParticipantViewController.writeLog("TrainRecordStop")
            print("stop")
            
            //let rImage = UIImage(named: "record_button")
            let rImage = UIImage(named: "play")
            recordButton.setImage(rImage, for: UIControlState.normal)
            audioController.stopRecording()
            
            isRecording = false
            isRecorded = true
            
            Thread.sleep(forTimeInterval: 0.3)
//            audioController.playResourceSound(name: "speechend", delegate: nil)
//            recordButton.accessibilityLabel = "Record audio description. Tap on this button again when you are done with recording."
//            recordButton.accessibilityLabel = ""
            
            progressBar.isHidden = false
            progressTimePassed.isHidden = false
            progressTimeLeft.isHidden = false
            progressTimeLeft.text = timeFloatToStr(audioDuration)
        } else {
            ParticipantViewController.writeLog("TrainRecordStart")
            print("record")
            
            recordButton.accessibilityLabel = ""
            let rImage = UIImage(named: "recording")
            recordButton.setImage(rImage, for: UIControlState.normal)
            
            audioController.startRecording(fileName: "recording-tmpobj.wav", delegate: nil)
            isRecording = true
        }
    }
    
    func markTraining() {
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        let text = "on"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    func rename(newName: String) {
        ParticipantViewController.writeLog("TrainingView-rename-\(newName)")
        httpController.requestRename(org_name: "tmpobj", new_name: newName){}
        
        do {
            let fileManager = FileManager.init()
            var isDirectory = ObjCBool(true)
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-tmpobj.wav").path, isDirectory: &isDirectory) {
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-tmpobj.wav").path, toPath: Log.userDirectory.appendingPathComponent("tmpobj").appendingPathComponent("recording-\(newName).wav").path)
            }
            
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent("tmpobj").path, isDirectory: &isDirectory) {
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent("tmpobj").path, toPath: Log.userDirectory.appendingPathComponent(newName).path)
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        self.title = object_name
        object_name = newName
        hasName = true
    }
    
    func addImages() {
        //set image for imageview
        let img_row_num = 5
        let img_width = Int(view.bounds.width/CGFloat(img_row_num))
        let img_height = Int(Double(img_width) * 1.1)
        let img_spacing = (Int(view.frame.width) - img_width*img_row_num)/2
        let top = Int(UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0))
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.goToCameraView(_:)))
        imgContainer.addGestureRecognizer(gesture)
        imgContainer.isUserInteractionEnabled = true
        imgContainer.accessibilityLabel = "Training samples"
        imgContainer.isAccessibilityElement = true
        
        for img_index in 1...ParticipantViewController.itemNum {
            let imgPath = Log.userDirectory.appendingPathComponent("\(object_name)/\(img_index).jpg")
            let data = try? Data(contentsOf: imgPath) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            let x = img_spacing + ((img_index-1)%img_row_num)*img_width
            let y = top+img_height*((img_index-1)/img_row_num)
            
            let imgView = UIImageView()
            imgView.frame = CGRect(x: x, y: y, width: img_width, height: img_height)
            imgView.image = UIImage(data: data!) //Assign image to ImageView
            
            //            imgView.image = UIImage(named: "3")
            imgContainer.addSubview(imgView)//Add image to our view
        }
    }
    
    @objc func goToCameraView(_ sender:UITapGestureRecognizer) {
        if isRecording || audioController.isAudioPlaying() {
            return
        }
        
        ParticipantViewController.writeLog("TrainingView-gotoCameraview")
        navigationController?.popViewController(animated: true)
    }
}


//extension UIViewController: EnterNameViewDelecate {
//    func addItemTapped(object_name: String) {
//        
//    }
//    
//    func cancelButtonTapped() {
//    }
//}


extension TrainingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}
