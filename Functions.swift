//
//  Functions.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 2/23/20.
//  Copyright © 2020 Ernest Essuah Mensah. All rights reserved.
//

import UIKit
import CoreMotion

class Functions {
    
    static var timer: Timer!
    static var motion = CMMotionManager()
    
    //MARK: - Returns a label as the header view for a navigation controller
    static func createHeaderView(title: String) -> UILabel {
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 280, height: 40)
        label.backgroundColor = .clear
        label.font = .rounded(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.text = title
        label.textColor = .white
        
        return label
    }
    
    
    // MARK: - Builds the views that hold the labels and returns an array of views.
    static func buildBGView() -> [UIView] {
        
        // Build the view with labels
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 320))
        bgView.backgroundColor = .clear
        
        // Build labels
        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 128))
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        headerLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        headerLabel.layer.cornerRadius = 12
        headerLabel.clipsToBounds = true
        headerLabel.font = .rounded(ofSize: 40, weight: .bold)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 80))
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = ""
        subtitleLabel.font = .rounded(ofSize: 40, weight: .bold)
        
        bgView.addSubview(headerLabel)
        headerLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y - 48)
        
        bgView.addSubview(subtitleLabel)
        subtitleLabel.center = CGPoint(x: bgView.center.x, y: bgView.center.y + 24)
        
        return [bgView, headerLabel, subtitleLabel]
    }
    
    
    // MARK: - Returns photos taken by the user stored locally on the device
    static func fetchImages(for object: String) -> [UIImage] {
        
        var images = [UIImage]()
        
        for img_index in 1...ParticipantViewController.itemNum {
            let imgPath = Log.userDirectory.appendingPathComponent("\(object)/\(img_index).jpg")
            
            //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            if let data = try? Data(contentsOf: imgPath) {
                if let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            
        }
        
        return images
    }
    
    // MARK: - Deletes the higher res photos after creating a scaled down resolution for the object
    static func deleteImages(for object: String) {
        
        print("Deleting high-res photos at")
        let images = Functions.fetchImages(for: "tmpobj")
        
        //let imgPath = userDirectory.appendingPathComponent("tmpobj")
        //print(imgPath)
        
        do {
            let fileManager = FileManager.default
                   
            // Check if file exists
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent("tmpobj").path) {
                // Delete file
                try fileManager.removeItem(atPath: Log.userDirectory.appendingPathComponent("tmpobj").path)
                print("Deleted image path")
                
            } else {
                print("File does not exist")
            }
            
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        // Create lower-res versions of photos
        scaleDownImageRes(for: object, images: images)
    }
    
    
    // MARK: - Scales down the resolution of images taken to reduce load on device storage
    static func scaleDownImageRes(for object: String, images: [UIImage]) {
        
        Util().createDirectory(object)
        
        let imgPath = Log.userDirectory.appendingPathComponent("\(object)")
        print("Images path-> \(imgPath)")
        
        for (index, image) in images.enumerated() {
            if let imgData = UIImageJPEGRepresentation(image, 0.5) {
                let fileName = imgPath.appendingPathComponent("\(index+1).jpg")
                do {
                    try imgData.write(to: fileName)
                    print("Low-res save successful in Functions -> \(fileName)")
                    Log.writeToLog("action= Low-res image \(index) of \(object) saved locally on device")
                } catch let error as NSError {
                    print("An error occured: \(error.localizedDescription)")
                    Log.writeToLog("An error occured saving low-res image \(index) of \(object) locaaly on device/")
                }
                
            }
        }
    }
    
    // MARK: - Saves the audio recording of the object locally on user's device
    static func saveRecording(for object: String, oldName: String) {
        do {
            let fileManager = FileManager.default
                   
            // Check if file exists
            if fileManager.fileExists(atPath: Log.userDirectory.appendingPathComponent("recording-tmpobj.wav").path) {
                // Delete file
                let destURL = Log.userDirectory.appendingPathComponent(object).appendingPathComponent("\(object).wav")
                if fileManager.fileExists(atPath: destURL.path) {
                    try! fileManager.removeItem(at: destURL)
                }
                
                // Delete other file if we are overwriting
                let oldFile = Log.userDirectory.appendingPathComponent(object).appendingPathComponent("\(oldName).wav")
                if fileManager.fileExists(atPath: oldFile.path) {
                    try! fileManager.removeItem(at: oldFile)
                }
                
                try fileManager.moveItem(atPath: Log.userDirectory.appendingPathComponent("recording-tmpobj.wav").path, toPath: destURL.path)
                print("Saved audio file. \(Log.userDirectory.appendingPathComponent(object).appendingPathComponent("\(object).wav").path))")
                
            } else {
                print("The audio file does not exist")
            }
            
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    
    // MARK: - Returns strings that have underscores as separated words
    static func separateWords(name: String) -> String {
        
        let words = name.split(separator: "_")
        var newWord = ""
        
        for i in 0..<words.count {
            if i < words.count - 1 {
                newWord += String(words[i]) + " "
            } else {
                newWord += String(words[i])
            }
        }
        
        return newWord
    }
    
    static func validText(text: String?) -> Bool {
        return text?.rangeOfCharacter(from: .letters) != nil
    }
    
    
    // MARK: - Gets gyroscope data when the user is using the camera
    static func startGyros(for image: Int) {
        
        if motion.isGyroAvailable {
            motion.gyroUpdateInterval = 1.0 / 60.0
            motion.startGyroUpdates()
            
            timer = Timer(fire: Date(), interval: 1, repeats: false, block: { (_) in
                
                if let data = self.motion.gyroData {
                    Log.writeToLog("Gyroscope data for image-\(image): [x: \(data.rotationRate.x), y: \(data.rotationRate.y), z: \(data.rotationRate.z)]")
                }
            })
            
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        }
        
    }

    static func stopGyros() {
        
        if timer != nil {
            timer.invalidate()
            timer = nil
            motion.stopGyroUpdates()
        }
    }
}
