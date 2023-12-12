//
//  ItemAudioVC.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 3/2/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit
import AVFoundation

class BaseItemAudioVC: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    var objectName = ""
    let audioController = AudioController()
    var audioTimer: Timer!
    var audioDuration = 0.0
    var images = [UIImage]()
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioFilename = "recording.m4a"
    
    // MARK: - Create outlets for the view controller
    
    let imageCollectionView: UICollectionView = {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: 104, height: 104)
        
        let frame = CGRect(x: 0, y: 0, width: 480, height: 254)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }

        return collectionView
    }()
    
    
    let bgView: UIView = {
       
        let blurView = UIView()
        blurView.frame = CGRect(x: 0, y: 0, width: 480, height: 152)
        if #available(iOS 13.0, *) {
            blurView.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            blurView.backgroundColor = .white
        }
        blurView.alpha = 1
        
        return blurView
    }()
    
    
    let progressBar: UIProgressView = {
       
        let progressBar = UIProgressView()
        progressBar.frame = CGRect(x: 0, y: 0, width: 320, height: 24)
        
        return progressBar
    }()
    
    
    let mainActionButton: UIButton = {
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        button.backgroundColor = .clear
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        
        if #available(iOS 13.0, *) {
            button.tintColor = .label
            
        }
        return button
    }()
    
    
    let secondaryButton: UIButton = {
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        button.backgroundColor = .clear
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        
        if #available(iOS 13.0, *) {
            button.tintColor = .label
        }
        
        return button
    }()
    
    let tertiaryButton: UIButton = {
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        button.backgroundColor = .clear
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        
        if #available(iOS 13.0, *) {
            button.tintColor = .label
        }
        
        return button
    }()
    
    let elapsedLabel: UILabel = {
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        label.text = "0:00"
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textColor = .lightGray
        
        return label
    }()
    
    let remainingLabel: UILabel = {
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 24)
        label.text = "0:00"
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textColor = .lightGray
        
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        imageCollectionView.dataSource = self
        images = Functions.fetchImages(for: objectName)
        
        
        let headerName = Functions.separateWords(name: objectName)
        navigationItem.titleView = Functions.createHeaderView(title: headerName)
        
//        setupRecorder()
//        setupPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRecorder()
        setupPlayer()
    }
    
    
    func setupRecorder() {
        
        let audioFilename = Log.userDirectory.appendingPathComponent(self.audioFilename)
        let settings = [AVFormatIDKey: kAudioFormatAppleLossless,
                        AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey: 320000,
                        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 44100.2] as [String: Any]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.prepareToRecord()
        } catch {
            print("Failed setting up recorder")
        }
    }
    
    var fileExist = false
    func setupPlayer() {
        
        let audioFilename = Log.userDirectory.appendingPathComponent(objectName).appendingPathComponent("\(objectName).wav")
        print(audioFilename)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            fileExist = true
        } catch {
            fileExist = false
            print("Failed setting up player for \(objectName).")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // Change button to play
    }
    
    // Converts the time to a usable string
    func timeFloatToStr(_ time: Double) -> String {
        let min = Int(time/60.0)
        let sec = Int(time)
        if sec < 10 {
            return "\(min):0\(sec)"
        } else {
            return "\(min):\(sec)"
        }
    }
    
    @objc
    func checkAudioTime() {
        let currTime = audioPlayer.currentTime
        if currTime >= audioDuration {
           audioController.stopAudio()
           audioTimer.invalidate()
           
           progressBar.progress = 0.0
           elapsedLabel.text = "0:00"
           remainingLabel.text = timeFloatToStr(audioDuration)
        } else {
           progressBar.progress = Float(currTime / audioDuration)
           elapsedLabel.text = timeFloatToStr(currTime)
       }
    }
    
    
    
    
    func setupViews() {
        
        view.setupView(viewToAdd: imageCollectionView, leadingView: view, shouldSwitchLeading: false, leadingConstant: 0, trailingView: view, shouldSwitchTrailing: false, trailingConstant: 0, topView: view, shouldSwitchTop: false, topConstant: 0, bottomView: view, shouldSwitchBottom: false, bottomConstant: -152)
        
        view.setupView(viewToAdd: bgView, leadingView: view, shouldSwitchLeading: false, leadingConstant: 0, trailingView: view, shouldSwitchTrailing: false, trailingConstant: 0, topView: nil, shouldSwitchTop: false, topConstant: 0, bottomView: view, shouldSwitchBottom: false, bottomConstant: 0)
        
        bgView.setupView(viewToAdd: progressBar, leadingView: bgView, shouldSwitchLeading: false, leadingConstant: 16, trailingView: bgView, shouldSwitchTrailing: false, trailingConstant: -16, topView: bgView, shouldSwitchTop: false, topConstant: 16, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
        
        bgView.setupView(viewToAdd: elapsedLabel, leadingView: bgView, shouldSwitchLeading: false, leadingConstant: 24, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: progressBar, shouldSwitchTop: true, topConstant: 8, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
        
        bgView.setupView(viewToAdd: remainingLabel, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: bgView, shouldSwitchTrailing: false, trailingConstant: -24, topView: progressBar, shouldSwitchTop: true, topConstant: 8, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
        
        
        bgView.addSubview(mainActionButton)
        mainActionButton.translatesAutoresizingMaskIntoConstraints = false
        mainActionButton.centerXAnchor.constraint(equalTo: bgView.centerXAnchor).isActive = true
        mainActionButton.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
        mainActionButton.widthAnchor.constraint(equalToConstant: mainActionButton.frame.width).isActive = true
        mainActionButton.heightAnchor.constraint(equalToConstant: mainActionButton.frame.height).isActive = true
        
        bgView.setupView(viewToAdd: secondaryButton, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: mainActionButton, shouldSwitchTrailing: true, trailingConstant: -16, topView: bgView, shouldSwitchTop: false, topConstant: 56, bottomView: bgView, shouldSwitchBottom: false, bottomConstant: -56)
        
        bgView.setupView(viewToAdd: tertiaryButton, leadingView: mainActionButton, shouldSwitchLeading: true, leadingConstant: 16, trailingView: nil, shouldSwitchTrailing: true, trailingConstant: 0, topView: bgView, shouldSwitchTop: false, topConstant: 56, bottomView: bgView, shouldSwitchBottom: false, bottomConstant: -56)
        
        mainActionButton.addTarget(self, action: #selector(handleMainActionButton), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(handleSecondaryActionButton), for: .touchUpInside)
        tertiaryButton.addTarget(self, action: #selector(handleTertiaryActionButton), for: .touchUpInside)
        
    }
    
    @objc
    func handleMainActionButton() {}
    
    @objc
    func handleSecondaryActionButton() {}
    
    @objc
    func handleTertiaryActionButton() {}
    
}


extension BaseItemAudioVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
}
