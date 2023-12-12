//
//  ItemAttrAndInfoVC.swift
//  TOR-Mobile
//
//  Created by Jonggi Hong on 3/18/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class ItemAttrAndInfoVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var objectName = ""
    
    var attributes = ["Background variation", "Side variation", "Distance variation", "Small object", "Cropped object", "Blurry", "Hand in image"]
//    var var_attributes = ["Background variation", "Side variation", "Distance variation"]
    
    var backgroundVariation = 0.0
    var sideVariation = 0.0
    var distanceVariation = 0.0
    var cnt_hand = 0
    var cnt_blurry = 0
    var cnt_crop = 0
    var cnt_small = 0
    var verbose = true
    
    var httpController = HTTPController()
    var switchCell = SwitchTableViewCell2()
    var collectionViewCell = CollectionViewTableCell()
    var playAudioCell = PlayAudioTableCell()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViews()
        
        if objectName != "" {
            let name = Functions.separateWords(name: objectName)
            objectNameLabel.text = name
            objectNameLabel.font = .rounded(ofSize: 21, weight: .bold)
            
            httpController.getSetDescriptor(obj_name: name) { (response) in
                print(response)
                let output_components = response.components(separatedBy: ",")
                if output_components.count != 7 {
                    print("The response is not valid. Response: \"\(response)\"...\(output_components.count)")
                } else {
//                    self.backgroundVariation = output_components[0]=="True" ? "Yes": "No"
//                    self.sideVariation = output_components[1]=="True" ? "Yes": "No"
//                    self.distanceVariation = output_components[2]=="True" ? "Yes": "No"
                    self.backgroundVariation = Double(output_components[0])!
                    self.sideVariation = Double(output_components[1])!
                    self.distanceVariation = Double(output_components[2])!
                    self.cnt_hand = Int(output_components[3])!
                    self.cnt_blurry = Int(output_components[4])!
                    self.cnt_crop = Int(output_components[5])!
                    self.cnt_small = Int(output_components[6])!
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layer.cornerRadius = 12
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        view.backgroundColor = .themeBackground
        
        let proceedButton = UIButton()
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        proceedButton.setTitle("Edit", for: .normal)
        //helpButton.addTarget(self, action: #selector(guideButtonAction), for: .touchUpInside)
        proceedButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        //proceedButton.accessibilityLabel = "More. This button takes you to a screen that will give you information about the TOR app"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proceedButton)
    }
    
    @objc
    func handleNextButton() {
        let vc = ItemInfoVC()
        vc.objectName = objectName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupViews() {
        switchCell.initCell()
        switchCell.myView = self
        
        collectionViewCell.initCell(object_name: objectName)
        playAudioCell.initCell(object_name: objectName)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return attributes.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
//            let cell = SwitchTableViewCell()
            
            return switchCell
        } else if indexPath.section == 2 {
            return collectionViewCell
        } else if indexPath.section == 3 {
            return playAudioCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell", for: indexPath) as! ItemAttributeTableViewCell

        // Configure the cell...
        if indexPath.section == 1 {
            cell.attributeLabel.text = attributes[indexPath.row]
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let varVal = backgroundVariation/0.15*100
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = backgroundVariation > 0.1 ? "High": "Low"
                }

            } else if indexPath.row == 1 {

                let varVal = sideVariation/1.5*100
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = sideVariation > 1 ? "High": "Low"
                }

            } else if indexPath.row == 2 {

                let varVal = distanceVariation/0.15*100
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = distanceVariation > 0.1 ? "High": "Low"
                }
            } else if indexPath.row == 3 {
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = "\(cnt_small) out of 30"
                } else {
                    cell.level.text = cnt_small > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 4 {
                
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = "\(cnt_crop) out of 30"
                } else {
                    cell.level.text = cnt_crop > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 5 {
                
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = "\(cnt_blurry) out of 30"
                } else {
                    cell.level.text = cnt_blurry > 5 ? "High": "Low"
                }
                
            } else if indexPath.row == 6 {
                
                if ItemAttrAndInfoVC.VERBOSE {
                    cell.level.text = "\(cnt_hand) out of 30"
                } else {
                    cell.level.text = cnt_hand > 5 ? "High": "Low"
                }
            }
        }

        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return CollectionViewTableCell.CollectionViewHeight
        }
        
        if indexPath.section == 3 {
            return playAudioCell.PlayAudioViewHeight
        }
        return 77
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 32))
        headerView.roundButton(withBackgroundColor: .clear, opacity: 0.2)
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40))
        
        if section == 0 {
            headerLabel.text = "Verbosity"
        } else if section == 1 {
           headerLabel.text = "Attributes"
        } else if section == 2 {
            headerLabel.text = "Images"
        } else if section == 3 {
            headerLabel.text = "Audio description"
        }
        
        headerLabel.textColor = .lightGray
        headerLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    static var VERBOSE = true
    func updateVerbosity(v: Bool) {
        ItemAttrAndInfoVC.VERBOSE = v
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}


class SwitchTableViewCell2: UITableViewCell {
    var verbositySwitch = UISwitch()
    var myView: ItemAttrAndInfoVC?
    var verbosityLabel: UILabel!
    
    func initCell() {
        self.contentView.backgroundColor = .white
        verbosityLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 24))
        verbosityLabel.text = "Verbose"
        verbosityLabel.textColor = .darkGray
        verbosityLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        verbosityLabel.textAlignment = .left
        verbositySwitch.isOn = ItemAttrAndInfoVC.VERBOSE
        verbositySwitch.addTarget(self, action: #selector(switchIsChanged), for: UIControlEvents.valueChanged)
        
        self.contentView.setupView(viewToAdd: verbosityLabel, leadingView: self.contentView, shouldSwitchLeading: false, leadingConstant: 24, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: self.contentView, shouldSwitchTop: false, topConstant: 0, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: 0)
        
        self.contentView.setupView(viewToAdd: verbositySwitch, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: self.contentView, shouldSwitchTrailing: false, trailingConstant: -20, topView: self.contentView, shouldSwitchTop: false, topConstant: 25, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
    }
    
    func setup() {
    }
    
    override func layoutSubviews() {
        if ItemAttrAndInfoVC.VERBOSE {
            verbosityLabel.text = "More verbose"
        } else {
            verbosityLabel.text = "Less verbose"
        }
    }
    
    @objc func switchIsChanged(mySwitch: UISwitch) {
        myView?.updateVerbosity(v: mySwitch.isOn)
    }
}

class ImageCollectionViewSmallCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    func setup() {
        
        contentView.addSubview(imageView)
        imageView.center = contentView.center
    }
}

class AccessibleCollectionView: UICollectionView {
    override func accessibilityElementCount() -> Int {
        guard let dataSource = dataSource else {
            return 0
        }

        return dataSource.collectionView(self, numberOfItemsInSection: 0)
    }
}


class CollectionViewTableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    let imageCollectionView: AccessibleCollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: 50, height: 50)
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width-30, height: CollectionViewTableCell.CollectionViewHeight)
        let collectionView = AccessibleCollectionView(frame: frame, collectionViewLayout: layout)
        
        collectionView.register(ImageCollectionViewSmallCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.backgroundColor = .white
        
//        if #available(iOS 13.0, *) {
//            collectionView.backgroundColor = .systemBackground
//        } else {
//            collectionView.backgroundColor = .white
//        }

        return collectionView
    }()
    var images = [UIImage]()
    static var CollectionViewHeight = CGFloat(400)
    
    func initCell(object_name: String) {
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.isAccessibilityElement = true
        images = Functions.fetchImages(for: object_name)
        
        self.contentView.addSubview(imageCollectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewSmallCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected \(indexPath.row) in collection view")
    }
}


class PlayAudioTableCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    let playImage = UIImage(named:"play_button")
    let rewindImage = UIImage(named:"rewind")
    let forwardImage = UIImage(named:"forward")
    let stopImage = UIImage(named:"stop_dark")
    
    
    let audioController = AudioController()
    var audioTimer: Timer!
    var audioDuration = 0.0
    var audioPlayer: AVAudioPlayer!
    var audioFilename = "recording.m4a"
    var PlayAudioViewHeight = CGFloat(150)
    var object_name = ""
    
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
    
    func initCell(object_name: String) {
        self.object_name = object_name
        setupPlayer()
        
        if fileExist {
            setupButtons()
            self.contentView.addSubview(mainActionButton)
            mainActionButton.translatesAutoresizingMaskIntoConstraints = false
            mainActionButton.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            mainActionButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            mainActionButton.widthAnchor.constraint(equalToConstant: mainActionButton.frame.width).isActive = true
            mainActionButton.heightAnchor.constraint(equalToConstant: mainActionButton.frame.height).isActive = true

            self.contentView.setupView(viewToAdd: secondaryButton, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: mainActionButton, shouldSwitchTrailing: true, trailingConstant: -16, topView: self.contentView, shouldSwitchTop: false, topConstant: 56, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: -56)

            self.contentView.setupView(viewToAdd: tertiaryButton, leadingView: mainActionButton, shouldSwitchLeading: true, leadingConstant: 16, trailingView: nil, shouldSwitchTrailing: true, trailingConstant: 0, topView: self.contentView, shouldSwitchTop: false, topConstant: 56, bottomView: self.contentView, shouldSwitchBottom: false, bottomConstant: -56)

            mainActionButton.addTarget(self, action: #selector(handleMainActionButton), for: .touchUpInside)
            secondaryButton.addTarget(self, action: #selector(handleSecondaryActionButton), for: .touchUpInside)
            tertiaryButton.addTarget(self, action: #selector(handleTertiaryActionButton), for: .touchUpInside)
            audioPlayer.delegate = self
        }
        
        self.contentView.backgroundColor = .white
        progressBar.isAccessibilityElement = false
        elapsedLabel.isAccessibilityElement = false
        remainingLabel.isAccessibilityElement = false
        self.contentView.setupView(viewToAdd: progressBar, leadingView: self.contentView, shouldSwitchLeading: false, leadingConstant: 10, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: self.contentView, shouldSwitchTop: false, topConstant: 0, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)

        self.contentView.setupView(viewToAdd: elapsedLabel, leadingView: self.contentView, shouldSwitchLeading: false, leadingConstant: 8, trailingView: nil, shouldSwitchTrailing: false, trailingConstant: 0, topView: progressBar, shouldSwitchTop: true, topConstant: 8, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)

        self.contentView.setupView(viewToAdd: remainingLabel, leadingView: nil, shouldSwitchLeading: false, leadingConstant: 0, trailingView: self.contentView, shouldSwitchTrailing: false, trailingConstant: 0, topView: progressBar, shouldSwitchTop: true, topConstant: 8, bottomView: nil, shouldSwitchBottom: false, bottomConstant: 0)
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
    
    var fileExist = false
    func setupPlayer() {
        let audioFilename = Log.userDirectory.appendingPathComponent(object_name).appendingPathComponent("\(object_name).wav")
        print(audioFilename)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            fileExist = true
            print("Audio file is found \(object_name)")
        } catch {
            fileExist = false
            print("Failed setting up player for \(object_name).")
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
    
    
    @objc
    func handleMainActionButton() {
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
    
    @objc
    func handleSecondaryActionButton() {}
    
    @objc
    func handleTertiaryActionButton() {}
    
    // MARK:- Button action functions
    @objc
    func playButtonAction() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            mainActionButton.setImage(playImage, for: .normal)
        } else {
            
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


