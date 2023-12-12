//
//  CameraViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 11/14/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer //Only for hidding  Volume view

class CameraViewController: UIViewController, AVAudioPlayerDelegate {

//    var guideText = "This is a screen for taking photos of the item. You need 30 photos of this item. You can take a photo by tapping on the 'take photo' button at the bottom center. The phone will vibrate everytime you take a photo. You will be notified when you take every 5 photos and when you finished taking photos. Tap on any part of the screen to start."
    var guideText = "You can teach TOR to recognize an item by taking 30 photos of the item. TOR works best when you capture the object with lot of variations and angles."
    var olView: UIView!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var captureView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var photoAttrView: UIVisualEffectView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var videoCapture: VideoCapture!
    var device: MTLDevice!
    let semaphore = DispatchSemaphore(value: 2)
    var capturedImg: UIImage?
    var currImg: UIImage?
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    
    var object_name = "tmpobj"
    var count = 0
    var attributes = ["• Hand in photo", "• Cropped object", "• Blurry", "• Small object"]
    
    var httpController = HTTPController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("CameraViewController: \(ParticipantViewController.userName) \(ParticipantViewController.category) \(object_name) \(ParticipantViewController.itemNum)")
        
        setUpCamera()
        createDirectory(object_name)

        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        
        // add overlay
        if ParticipantViewController.VisitedCameraView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedCameraView = 1
            //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
            cameraButton.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
        } else {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, "Take \(ParticipantViewController.itemNum) photos of the new item.")
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.cameraButton)
            //UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,  self.cameraButton);

        }
        
        navigationItem.titleView = Functions.createHeaderView(title: "Teach TOR")
        photoAttrView.layer.cornerRadius = 12
        dismissButton.roundButton(withBackgroundColor: .clear, opacity: 0)
        
        var attrs = ""
        attributes.forEach({attrs += $0 + "\n"})
        textView.text = attrs
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.teachScreen.rawValue)")
        
        listenVolumeButton()
        count = 0
        //ParticipantViewController.writeLog("CameraView-\(object_name)")
        captureView.alpha = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
        
        Log.writeToLog("\(Actions.exitedScreen.rawValue) \(Screens.teachScreen.rawValue)")
    }
    
    @IBAction func handleDismissButton(_ sender: UIButton) {
        animateOut(view: photoAttrView)
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
            if let view = volumeView.subviews.compactMap({ $0 as? UISlider }).first {
                view.value = Float(audioLevel) //---0 t0 1.0---
                //                view.setValue(audioLevel, animated: false)
            }
            
//            let audioSession = AVAudioSession.sharedInstance()
//            print(audioLevel, audioSession.outputVolume)
            
            ParticipantViewController.writeLog("volumeButton")
            takePhoto()
        }
    }
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // Step 2
        let path = CGMutablePath()
        //path.addArc(center: CGPoint(x: frame.midX, y: frame.midY), radius: radius1, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
        path.addArc(center: CGPoint(x: frame.midX, y: frame.height), radius: 100, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = kCAFillRuleEvenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        
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
        ParticipantViewController.writeLog("CameraOverlayDismiss")
        
        cameraButton.accessibilityElementsHidden = false
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController)
        
        olView.removeFromSuperview()
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
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
    
    // MARK: - Animates a view in
    func animateIn(view: UIView) {
        
        //print("Animating in?")
        self.view.addSubview(view)
        view.center = CGPoint(x: cameraView.center.x, y: cameraView.center.y - 54)
        view.alpha = 0
        view.transform = CGAffineTransform.init(translationX: 0, y: 40)
        
        UIView.animate(withDuration: 0.4) {
            view.transform = .identity
            view.alpha = 1
        }
    }
    
    // MARK: - Animates a view out
    func animateOut(view: UIView) {
        
        UIView.animate(withDuration: 0.4, animations: {
            
            view.transform = CGAffineTransform.init(translationX: 0, y: 40)
            view.alpha = 0
            
        }) { (_) in
            
            view.removeFromSuperview()
        }
    }
    
    
    // MARK: - This functions animates a view that visually informs the user how many photos
    // MARK: - are left to be taken.
    func animateLabel(message: String, showSubtitle: Bool) {
        
        // Build the view with labels
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        bgView.backgroundColor = .clear
        
        let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 240, height: 180))
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = .rounded(ofSize: 80, weight: .bold)
        
        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 249, height: 80))
        leftLabel.textColor = .white
        leftLabel.textAlignment = .center
        leftLabel.text = showSubtitle ? "left": ""
        leftLabel.font = .rounded(ofSize: 40, weight: .bold)
        
        bgView.addSubview(countLabel)
        countLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y - 48)
        
        bgView.addSubview(leftLabel)
        leftLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y + 24)
        
        
        countLabel.text = "\(message)"
        view.addSubview(bgView)
        bgView.center = CGPoint(x: cameraView.center.x, y: cameraView.center.y - 54)
        bgView.alpha = 0
        bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
        
        UIView.animate(withDuration: 0.6, animations: {
            
            bgView.transform = .identity
            bgView.alpha = 1
            
        }) { (_) in
            
            UIView.animate(withDuration: 0.4, delay: 0.8, animations: {
                bgView.alpha = 0
                bgView.transform = CGAffineTransform.init(translationX: 0, y: 40)
                
            }) { (_) in
                bgView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func captureImage(_ sender: Any) {
        ParticipantViewController.writeLog("captureButton")
        Log.writeToLog("\(Actions.tappedOnBtn.rawValue) button=captureButton")
        takePhoto()
    }
    
    func takePhoto() {
        captureView.alpha = 1
        ParticipantViewController.writeLog("TakePhoto-\(object_name)-\(count+1)")
        Functions.startGyros(for: count+1)
        Log.writeToLog("\(Actions.photoTaken.rawValue) of \(object_name)-(\(count+1))")
        
        if count >= ParticipantViewController.itemNum {
            return
        }
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        playSound(name: "shutter")
        
        currImg = capturedImg
        captureView.image = currImg
        print("capture")
        
        count = count + 1
        saveImage(count)
        
        httpController.getImgDescriptor(image: currImg!, index: count, object_name: "tmpobj") {(response) in
            let output_components = response.components(separatedBy: ",")
            let hand = output_components[0]
            let blurry = output_components[1]
            let cropped = output_components[2]
            let small = output_components[3]
            _ = ["• Hand in photo", "• Cropped object", "• Blurry", "• Small object"]
            
            DispatchQueue.main.async {
                var attrs = ""
                if hand == "True" {
                    attrs += self.attributes[0]+"\n"
                }
                if blurry == "True" {
                    attrs += self.attributes[2]+"\n"
                }
                if cropped == "True" {
                    attrs += self.attributes[1]+"\n"
                }
                if small == "True" {
                    attrs += self.attributes[3]+"\n"
                }
                self.textView.text = attrs
                self.animateIn(view: self.photoAttrView)
            }
            
            print(response)
            print(hand)
            print(blurry)
            print(cropped)
            print(small)
        }
        
        if count%5 == 0 {
            if count == ParticipantViewController.itemNum {
                //                textToSpeech("You finished taking 30 photos of \(object_name)")
                //showToast(message: "You finished taking 30 photos of \(object_name)")
            } else {
                //UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "\(30-count) left")
                textToSpeech("\(ParticipantViewController.itemNum-count) left")
                animateLabel(message: "\(ParticipantViewController.itemNum-count)", showSubtitle: true)
            }
        }
        
    }
    
    
    
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    var player: AVAudioPlayer?
    func playSound(name: String){
        if player != nil {
            if player!.isPlaying {
                player?.stop()
            }
        }
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    func countSamples (_ label: String) -> Int {
        let imgPath = Log.userDirectory.appendingPathComponent("\(label)")
        let fileManager = FileManager.default
        
        var isDirectory = ObjCBool(true)
        if fileManager.fileExists(atPath: imgPath.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                do {
                    let fileURLs = try fileManager.contentsOfDirectory(at: imgPath, includingPropertiesForKeys: nil)
                    // process files
                    return fileURLs.count
                } catch let error as NSError {
                    print("Error creating directory: \(error.localizedDescription)")
                }
            }
        }
        return -1
    }
    
    func createDirectory(_ label: String) {
        let classPath = Log.userDirectory.appendingPathComponent("\(label)")
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: classPath.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: classPath.path, withIntermediateDirectories: true, attributes: nil)
                print("directory is created. \(classPath.path)")
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    func saveImage(_ index: Int) {
        if captureView.image == nil { return }
        let imgPath = Log.userDirectory.appendingPathComponent("\(object_name)")
        
        // Save high-res photos to be sent to the server
        if let data = UIImageJPEGRepresentation(currImg!, 1.0) {
            let filename = imgPath.appendingPathComponent("\(index).jpg")
            try? data.write(to: filename)
            Log.writeToLog("action= High-res image \(index) of \(object_name) saved locally on device")
            print("The image is saved.\n\(filename)")
        }
        
        
        if index == ParticipantViewController.itemNum {
            textToSpeech("Done")
            animateLabel(message: "Done", showSubtitle: false)
            
            cameraButton.isEnabled = false
            cameraButton.isAccessibilityElement = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                let vc = TrainingVC()
                vc.objectName = "tmpobj"
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
        }
        
        print(countSamples(object_name))
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
    
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.vga640x480) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.cameraView.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = cameraView.bounds
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension CameraViewController: VideoCaptureDelegate {
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
        
        capturedImg = capture.currImage
    }
    
    func videoCapture(_ capture: VideoCapture, didCapturePhotoTexture texture: MTLTexture?, previewImage: UIImage?) {
        // not implemented
    }
}
