//
//  ItemAudioViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/23/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit
import AVFoundation

class ItemAudioViewController: UIViewController, AVAudioPlayerDelegate {
    var object_name = "keyboard"
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var ffButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    let audioController = AudioController()
    var audioTimer: Timer!
    var audioDuration = 0.0
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        images = Functions.fetchImages(for: object_name)
        //addImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParticipantViewController.writeLog("ItemAudioView-\(object_name)")
        
        let editButton = UIButton()
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        editButton.setTitle("EDIT", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        editButton.accessibilityLabel = "Edit. This button takes you to a screen that will allow you to edit information about \(object_name)."
        
//        let editButton = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        self.title = object_name
        setupAudioButton()
        imagesCollectionView.dataSource = self
        imagesCollectionView.accessibilityLabel = "This is a collection of \(ParticipantViewController.itemNum) photos you took of \(object_name)."
        
        navigationItem.titleView = Functions.createHeaderView(title: object_name)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white]
        
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white], for: .normal)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular), NSAttributedStringKey.foregroundColor:UIColor.white], for: .normal)
    }
    
    
    @IBAction func playButtonAction(_ sender: Any) {
        ParticipantViewController.writeLog("ItemAudioPlay")
        
        if audioController.isAudioPlaying() {
            audioController.stopAudio()
            
            let rImage = UIImage(named: "play")
            playButton.setImage(rImage, for: UIControlState.normal)
            
            ffButton.isEnabled = false
            ffButton.isAccessibilityElement = false
            rewindButton.isEnabled = false
            rewindButton.isAccessibilityElement = false
        } else {
            audioController.playFileSound(name: "recording-\(object_name).wav", delegate: nil)
            audioDuration = audioController.audioPlayer.duration - 0.3
            audioTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(checkAudioTime), userInfo: nil, repeats: true)
            
            let rImage = UIImage(named: "stop")
            playButton.setImage(rImage, for: UIControlState.normal)
            
            ffButton.isEnabled = true
            ffButton.isAccessibilityElement = true
            rewindButton.isEnabled = true
            rewindButton.isAccessibilityElement = true
        }
    }
    
    @IBAction func ffButtonAction(_ sender: Any) {
        if audioController.isAudioPlaying() {
            audioController.audioPlayer.currentTime += 1.0
        }
    }
    
    @IBAction func rewindButtonAction(_ sender: Any) {
        if audioController.isAudioPlaying() {
            audioController.audioPlayer.currentTime -= 1.0
        }
    }
    
    @objc func editButtonAction() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemInfoViewController") as! ItemInfoViewController
        vc.object_name = object_name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finish")
    }
    
    @objc func checkAudioTime() {
        let currTime = audioController.audioPlayer.currentTime
        if currTime >= audioDuration {
            audioController.stopAudio()
            audioTimer.invalidate()
            
//            progressBar.progress = 0.0
//            let rImage = UIImage(named: "play")
//            playButton.setImage(rImage, for: UIControlState.normal)
            
            let playImage = #imageLiteral(resourceName: "play_button").withRenderingMode(.alwaysTemplate)
            if #available(iOS 13.0, *) {
                playButton.tintColor = .label
            } else {
                // Fallback on earlier versions
            }
            playButton.setImage(playImage, for: .normal)
            
        } else {
            progressBar.progress = Float(currTime / audioDuration)
        }
    }
    
    func setupAudioButton() {
        let audioPath = Log.userDirectory.appendingPathComponent("recording-\(object_name).wav")
        ffButton.isEnabled = false
        ffButton.isAccessibilityElement = false
        rewindButton.isEnabled = false
        rewindButton.isAccessibilityElement = false
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: audioPath.path) {
            print("Audio File Exists")
            playButton.isEnabled = true
            playButton.isAccessibilityElement = true
            let rImage = UIImage(named: "play_button")
            playButton.setImage(rImage, for: UIControlState.normal)
        } else {
            playButton.isEnabled = false
            playButton.isAccessibilityElement = false
            let rImage = UIImage(named: "play_button")
            playButton.setImage(rImage, for: UIControlState.normal)
            print("FILE NOT AVAILABLE")
        }
        
        let playImage = #imageLiteral(resourceName: "play_button").withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            playButton.tintColor = .label
        } else {
            // Fallback on earlier versions
            //playButton.tintColor = .white
        }
        playButton.setImage(playImage, for: .normal)
        
        let rewindImage = #imageLiteral(resourceName: "rewind").withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            rewindButton.tintColor = .label
        } else {
            // Fallback on earlier versions
        }
        rewindButton.setImage(rewindImage, for: .normal)
        
        let forwardImage = #imageLiteral(resourceName: "forward").withRenderingMode(.alwaysTemplate)
        if #available(iOS 13.0, *) {
            ffButton.tintColor = .label
        } else {
            // Fallback on earlier versions
        }
        ffButton.setImage(forwardImage, for: .normal)
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


extension ItemAudioViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
}
