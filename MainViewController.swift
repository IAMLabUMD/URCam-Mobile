//
//  ViewController.swift
//  Teachable Object Recognizer
//
//  Created by Jaina Gandhi on 3/31/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer //Only for hidding  Volume view

class MainViewController: BaseViewController {
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var teachButton: UIButton!
    
    var toastLabel: UILabel!
    var trainChecker: Timer!
//    var guideText = "This is the main screen. You can read the instructions by tapping on the help button at the top right corner. You can scan items, view item list, and teach new item to TOR by tapping on one of the buttons at the bottom of the screen. Tap on any part of the screen to start."
    var guideText = "Teach an object to TOR by capturing photos of your personal item. Read more on how to teach TOR on the instruction page."
    var olView: UIView!
    
    var videoCapture: VideoCapture!
    var device: MTLDevice!
    let semaphore = DispatchSemaphore(value: 2)
    var capturedImg: UIImage?
    var synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var isTraining = false
    var itemList = ItemList()
    var httpController = HTTPController()
    var audioController = AudioController()
    
    var value = 0.0
    var displayLink: CADisplayLink!
    var bgView: UIView!
    var currentAnimationView: UIView!
    
    var messageViewShowing = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        displayLink = CADisplayLink(target: self, selector: #selector(handleAnimation))
//        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        
        print("MainViewController: \(ParticipantViewController.userName) \(ParticipantViewController.category) \(ParticipantViewController.mode)")
        setUpCamera()
        makeToast()
        addViewsToSuperView()
        //addSlideMenuButton()
        //unmarkTraining()
//        itemList.renewList()
        
        // set navigation bar
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let guideButton = UIButton.init(type: .custom)
        guideButton.setImage(UIImage(named: "guide_icon"), for: .normal)
        //guideButton.layer.borderWidth = 1
        
        let menuBarItem = UIBarButtonItem(customView: guideButton)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 35).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        navigationItem.titleView = Functions.createHeaderView(title: "URCam")
        
        scanButton.accessibilityLabel = "Scan items. This button allows you to take a photo of an item and gives a description of the item."
        
        listButton.accessibilityLabel = "View items. This button takes you to a screen that has a list of all items you have taught the object recognizer."
        
        teachButton.accessibilityLabel = "Teach TOR. This button takes you to a screen that allows you to take photos to teach the object recognizer."
        
        
        // add overlay
        if ParticipantViewController.VisitedMainView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedMainView = 1
            //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
            olView.becomeFirstResponder()
            
            scanButton.accessibilityElementsHidden = true
            listButton.accessibilityElementsHidden = true
            teachButton.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
 
        }
        
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, scanButton)
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "#0097BD")
        navigationController?.navigationBar.isTranslucent = false
        
        
        listButton.isHidden = true
        teachButton.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.mainScreen.rawValue)")
        listenVolumeButton()
        itemList.renewList()
        print("We have \(itemList.itemArray.count) item(s) now.")
        trainChecker = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTraining), userInfo: nil, repeats: true)
    }
 
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.mainScreen.rawValue)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private var audioLevel : Float = 0.0
    var volumeView = MPVolumeView(frame: CGRect(x: -100, y: 0, width: 0, height: 0))
    
    
    func listenVolumeButton(){
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true, with: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            audioLevel = audioSession.outputVolume
            
            view.addSubview(volumeView)
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
//            if let view = volumeView.subviews.first as? UISlider{
            if let view = volumeView.subviews.compactMap({ $0 as? UISlider }).first {
                view.value = Float(audioLevel) //---0 t0 1.0---
//                view.setValue(audioLevel, animated: false)
            }
            
//            let audioSession = AVAudioSession.sharedInstance()
            //print(audioLevel, audioSession.outputVolume, volumeView.subviews.compactMap({ $0 as? UISlider }).first?.value)
            Log.writeToLog("action= volumeUpdated")
            recognize()
        }
    }
    
    
    
    
    
    
    
    //%%%%%%%%%%%%%%%%%%%%%%% use this function for test
    // check training, rename, rollback (cancel button at the entername popup)
    // remove back gutton at the training page
    
    @objc func guideButtonAction() {
//        ParticipantViewController.writeLog("MainHelpButton")
//        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) helpButton")
        

//        httpController.reqeustTrain() {(response) in
//            print("Training response: \(response)")
//        }
//        self.httpController.sendARInfo(object_name: "Temp") {(response) in
//            print("Send AR Info: " + response)
//        }
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "settingsTableVC") as! SettingsTableVC
//        self.navigationController?.pushViewController(vc, animated: true)
        
        let moreVC = self.storyboard?.instantiateViewController(withIdentifier: "MoreVC") as! MoreViewController
        self.navigationController?.pushViewController(moreVC, animated: true)
    }
    
    
    
    //%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    @IBAction func handleShowItemsButton(_ sender: UIButton) {
        
//        self.httpController.reqeustTrain(){
//        }
        
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) viewObjectsButton")
        let itemsVC = self.storyboard?.instantiateViewController(withIdentifier: "ObjectsViewController") as! ChecklistViewController2
        navigationController?.pushViewController(itemsVC, animated: true)
    }
    
    
    func sideMenus(){
        if revealViewController() != nil {
            
        }
    }
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let label = UILabel(frame: CGRect(x:10, y:10, width: frame.size.width - 60, height: CGFloat(25)))
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textColor = UIColor.black
        label.textAlignment = .left;
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        label.text = guideText
        label.accessibilityLabel = ""
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
        ParticipantViewController.writeLog("MainOverlayDismiss")
        scanButton.accessibilityElementsHidden = false
        listButton.accessibilityElementsHidden = false
        teachButton.accessibilityElementsHidden = false
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationItem.rightBarButtonItem)
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, scanButton)
        olView.removeFromSuperview()
    }
    
    var cnt = 0
    @IBAction func recognizeButtonAction(_ sender: Any) {
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) scanButton")
        recognize()
    }
    
    func recognize() {
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        audioController.playResourceSound(name: "shutter", delegate: nil)
        //requestRecognition()
        
        httpController.requestRecognition(capturedImg: capturedImg!, postProcessing: handleRecognitionResult)
        
    }
    
    // MARK: - This functions animates a view that visually informs the user how many photos
    // MARK: - are left to be taken.
    func animateLabel(message: String, delay: Double) {
        
        if let animationView = currentAnimationView {
            animationView.alpha = 0
            animationView.removeFromSuperview()
        }
        
        let views = Functions.buildBGView()
        let bgView = views[0]
        currentAnimationView = bgView
        let countLabel = views[1] as! UILabel
        
        countLabel.text = "\(message)"
        view.addSubview(bgView)
        bgView.center = CGPoint(x: cameraView.center.x, y: cameraView.center.y - 54)
        bgView.alpha = 0
        bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
        
        UIView.animate(withDuration: 0.6, animations: {
            
            bgView.transform = .identity
            bgView.alpha = 1
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.4, delay: delay, animations: {
                bgView.alpha = 0
                bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
                
            }) { (_) in
                bgView.removeFromSuperview()
                self.messageViewShowing = false
            }
        }
    }
    
    func handleRecognitionResult(output: String) {
        let output_components = output.components(separatedBy: "-:-")
        Log.writeToLog("RecResult-\(output)")
        print("Handling recognition result: \(output)")
        
        if output == "Error" {
            DispatchQueue.main.async {
                self.animateLabel(message: "Error2", delay: 2)
                self.scanButton.isEnabled = true
            }
            
        }
        
        var label = "Don't know"
        var message = "Don't know"
        var max_prob = 0.0
        let epsilon = 0.00001
        var entropy = Double(output_components[0])!
        print(output_components)
        print(output_components.count)
        print(itemList.getListString())
        if output_components.count >= 2 {
            for index in 1...output_components.count - 1 {
                let label_pair = output_components[index].components(separatedBy: "/")
                let prob = Double(label_pair[1])!

                print("checking : \(label_pair[0]), \(prob)")
                // check if the returned label exists or not

                
                if prob >= 0.4 && max_prob < prob {
                    label = label_pair[0]
                    message = label_pair[0]
                    max_prob = prob
                }
                
            }
        
            if entropy > 2 {
                label = "Don't know"
                message = "Don't know"
                Log.writeToLog("\(Actions.recognitionSuccessful.rawValue) false")
            } else {
                Log.writeToLog("\(Actions.recognitionSuccessful.rawValue) true")
            }
        }
        print(label, entropy)
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, label)
        //showRecognitionToast(message: label)
        animateLabel(message: message, delay: 2)
        
        Log.writeToLog("returned_recognized_object= \(message)")
        Log.writeToLog("\(Actions.recognitionEnded.rawValue)")
    }
    
    
    //var customAlert: EnterNameController!
    @IBAction func trainButtonAction(_ sender: Any) {
        if isTraining {
            textToSpeech("Training is in progress. Please wait until it is done.")
            Log.writeToLog("MainTeachButton-TrainingInProgress")
            return
        }
        
        ParticipantViewController.writeLog("MainTeachButton")
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) teachTORButton")
        
//        let tvc = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        if #available(iOS 12.0, *) {
            let tvc = self.storyboard?.instantiateViewController(withIdentifier: "ARViewController") as! ARViewController
            self.navigationController?.pushViewController(tvc, animated: true)
        } else {
            // Fallback on earlier versions
        }

        // MARK: - Remember to uncomment this trainchecker function call
        trainChecker.invalidate()
    }
    
    
    
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    func makeToast() {
        toastLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 35))
        toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = "Training..."
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds = true
        toastLabel.accessibilityElementsHidden = true
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
    
    
    
    // MARK: - Adds the views holding the labels to the superview
    func addViewsToSuperView() {
        let views = Functions.buildBGView()
        bgView = views[0]
        let label = views[1] as! UILabel
        label.text = "Training in progress"
        label.accessibilityLabel = "Label stating that training is in progress. Please wait."
        
        view.addSubview(bgView)
        bgView.center = CGPoint(x: cameraView.center.x, y: cameraView.center.y - 88)
        bgView.alpha = 0
    }
    
    
    
    func showRecognitionToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func processCheckTraining(output: String) {
        if output.contains("training in progress") {
            //showToast()
            isTraining = true
            bgView.alpha = 1.0
            print("yes training")
            
        } else {
            if isTraining {
                textToSpeech("Training ended.")
            }
            print("no training, normal")
            isTraining = false
            bgView.alpha = 0
            //hideToast()
            trainChecker.invalidate()
            Log.writeToLog("\(Actions.trainingEnded.rawValue)")
        }
        
        
    }
    
    // MARK: - This function animates a view that alerts the user that a background task is being executed
    @objc func handleAnimation() {
        if isTraining {
            value += 0.015
            bgView.alpha = CGFloat(value)
            if value > 1 {
                value = 0
            }
        }
    }
    
    @objc func checkTraining() {
        httpController.checkIsTraining(postProcessing: processCheckTraining)
        
        /*
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                print(text2)
                
                if text2.contains("on"){
                    showToast()
                    isTraining = true
                    print("yes training")
                    return true
                }
            }
            catch {
                /* error handling here */
                hideToast()
                isTraining = false
                //print("no training, exception")
                trainChecker.invalidate()
                httpController.simpleRequest(type: "checkTmpObj") {}
                return false
            }
        }
        print("no training, normal")
        isTraining = false
        hideToast()
        trainChecker.invalidate()
        httpController.simpleRequest(type: "checkTmpObj") {}
        return false
         */
    }
    
    func textToSpeech(_ text: String) {
        if synth.isSpeaking {
            synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        print("tts: \(text)")
        myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        myUtterance.volume = 1.0
        synth.speak(myUtterance)
        
        Log.writeToLog("\(Actions.voiceOver.rawValue) \(text)")
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
//        formatter.dateFormat = "yyyy-MM-dd"
        
        let myString = formatter.string(from: date) // string purpose I add here
        return myString
    }
    
    @IBAction func showFoodList(_ sender: Any) {

    }
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.vga640x480) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.cameraView.layer.addSublayer(previewLayer)
                    self.cameraView.layer.backgroundColor = UIColor.clear.cgColor
                    self.resizePreviewLayer()
                }
                self.videoCapture.start()
            }
        }
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = cameraView.bounds
        
    }
    
    // passing variable to the next view
    // https://learnappmaking.com/pass-data-between-view-controllers-swift-how-to/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//         if segue.destination is ChecklistViewController2
//         {
//            ParticipantViewController.writeLog("MainListButton")
//            trainChecker.invalidate()
//         }
    }
}


extension MainViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoTexture texture: MTLTexture?, timestamp: CMTime) {
        // For debugging.
        //predict(texture: loadTexture(named: "dog416.png")!); return
        // The semaphore is necessary because the call to predict() does not block.
        // If we _would_ be blocking, then AVCapture will automatically drop frames
        // that come in while we're still busy. But since we don't block, all these
        // new frames get scheduled to run in the future and we end up with a backlog
        // of unprocessed frames. So we're using the semaphore to block if predict()
        // is already processing 2 frames, and we wait until the first of those is
        // done. Any new frames that come in during that time will simply be dropped.
        //        semaphore.wait()
        
        if let texture = texture {
            //predict(texture: texture)
            //capturedImg = UIImage(ciImage: CIImage(mtlTexture: texture)!)
            //            capturedImg = capture.currImage
        }
        capturedImg = capture.currImage
    }
    
    func videoCapture(_ capture: VideoCapture, didCapturePhotoTexture texture: MTLTexture?, previewImage: UIImage?) {
        // not implemented
    }
}
