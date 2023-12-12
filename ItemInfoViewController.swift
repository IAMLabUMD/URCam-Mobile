//
//  ItemInfoViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/31/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class ItemInfoViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var object_name = "key"
    
//    var guideText = "This screen shows the detail of the object. You can listen to the audio description by tapping on the button at the bottom center. There are buttons for removing the object at the top right, changing the name of the object at the bottom left, and changing the audio description at the bottom right. Tap on any part of the screen to start."
    var guideText = "You can add a personal note to the item by recording an audio description of the item. For example, my favorite almond, cashew and walnut nutbars from Kirkland."
    var olView: UIView!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var renameButton: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder!
    let audioController = AudioController()
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("ItemInfoViewController: \(ParticipantViewController.userName) \(ParticipantViewController.category) \(object_name)")
        //addImages()
        images = Functions.fetchImages(for: object_name)
        imagesCollectionView.dataSource = self
//        self.title = object_name
//        let backButton = UIBarButtonItem()
//        backButton.title = "Back"
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
//        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
//        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white]
        
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white], for: .normal)
        
        navigationItem.titleView = Functions.createHeaderView(title: object_name)
        
        // add overlay
        if ParticipantViewController.VisitedItemInfoView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedItemInfoView = 1
            
            audioButton.accessibilityElementsHidden = true
            recordButton.accessibilityElementsHidden = true
            renameButton.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
//            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
        }
    }
    
    
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        // Step 2
        let path = CGMutablePath()
//        path.addArc(center: CGPoint(x: frame.midX, y: frame.height), radius: 200, startAngle: 0.0, endAngle: 2.0 * .pi, clockwise: false)
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
        ParticipantViewController.writeLog("ItemOverlayDismiss")
        audioButton.accessibilityElementsHidden = false
        recordButton.accessibilityElementsHidden = false
        renameButton.accessibilityElementsHidden = false
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController)
        olView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        ParticipantViewController.writeLog("ItemEditView-\(object_name)")
        //makeToast()
        //trainChecker = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTraining), userInfo: nil, repeats: true)
    }
    
    @IBAction func renameButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("ItemRenameButton-\(object_name)")

        // custom view
        // https://medium.com/if-let-swift-programming/design-and-code-your-own-uialertview-ec3d8c000f0a
        let customAlert = storyboard?.instantiateViewController(withIdentifier: "RenameViewController") as! RenameViewController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.orgName = object_name
        customAlert.orgView = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    
    var isRecording = false
    @IBAction func recordButtonAction(_ sender: Any) {
        if isRecording {
            ParticipantViewController.writeLog("ItemRecordStop-\(object_name)")
            
            let rImage = UIImage(named: "record_button")
            recordButton.setImage(rImage, for: UIControlState.normal)
            
            audioController.stopRecording()
//            audioController.playResourceSound(name: "speechend", delegate: nil)
            isRecording = false
            
            Thread.sleep(forTimeInterval: 0.3)
        } else {
            ParticipantViewController.writeLog("ItemRecordStart-\(object_name)")
            
            let rImage = UIImage(named: "record_button2")
            recordButton.setImage(rImage, for: UIControlState.normal)
            
//            audioController.playResourceSound(name: "speechstart", delegate: self) // record start from the finish play event
            isRecording = true
        }
    }
    
    var toastLabel: UILabel!
    var trainChecker: Timer!
    func makeToast() {
        toastLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 35))
        toastLabel.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = "Training..."
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
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
    
    /*
    @objc func checkTraining() -> Bool {
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                
                if text2.contains("on"){
                    showToast()
                    //print("yes training")
                    return true
                }
            }
            catch {
                /* error handling here */
                hideToast()
                //print("no training, exception")
                return false
            }
        }
        //print("no training, normal")
        hideToast()
        return false
    }
    */
    
    @IBAction func audioButtonAction(_ sender: Any) {
        if isRecording {
            audioController.stopRecording()
        }
        navigationController?.popViewController(animated: true)
        /*
        if audioController.isAudioPlaying() {
            ParticipantViewController.writeLog("ItemAudioStop-\(object_name)")
            audioController.stopAudio()
            
            let rImage = UIImage(named: "play_icon")
            audioButton.setImage(rImage, for: UIControlState.normal)
        } else {
            ParticipantViewController.writeLog("ItemAudioStart-\(object_name)")
            audioController.playFileSound(name: "recording-\(object_name).wav", delegate: self)
            
            let rImage = UIImage(named: "pause_icon")
            audioButton.setImage(rImage, for: UIControlState.normal)
        }
        */
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if (player.url?.path.contains("recording"))! {
//            let rImage = UIImage(named: "play_icon")
//            audioButton.setImage(rImage, for: UIControlState.normal)
//        } else if (player.url?.path.contains("speechstart"))! {
//            audioController.startRecording(fileName: "recording-\(object_name).wav", delegate: nil)
//        }
    }
    
    func addImages() {
        //set image for imageview
        let img_row_num = 5
        let img_width = Int(view.bounds.width/CGFloat(img_row_num))
        let img_height = Int(Double(img_width) * 1.1)
        let img_spacing = (Int(view.frame.width) - img_width*img_row_num)/2
        //let top = Int(UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0))
        let top = 0
        
        
        for img_index in 1...30 {
            let imgPath = Log.userDirectory.appendingPathComponent("\(object_name)/\(img_index).jpg")
            let data = try? Data(contentsOf: imgPath) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            let x = img_spacing + ((img_index-1)%img_row_num)*img_width
            let y = top+img_height*((img_index-1)/img_row_num)
            
            let imgView = UIImageView()
            imgView.frame = CGRect(x: x, y: y, width: img_width, height: img_height)
            imgView.image = UIImage(data: data!) //Assign image to ImageView
//            imgView.image = UIImage(named: "3")
            view.addSubview(imgView)//Add image to our view
        }
    }
    

}

//Add image view properties like this(This is one of the way to add properties).
extension UIImageView {
    //If you want only round corners
    func imgViewCorners() {
        layer.cornerRadius = 10
        layer.borderWidth = 1.0
        layer.masksToBounds = true
    }
}

extension ItemInfoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}
