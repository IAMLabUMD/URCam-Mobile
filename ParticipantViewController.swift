//
//  ParticipantViewController.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/10/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import UIKit

class ParticipantViewController: UIViewController {
    
    @IBOutlet weak var pidField: UITextField!
    static var userName = UserDefaults.standard.value(forKey: "userUUID") as? String ?? ""
    static var category = "Spice"
    static var mode = "step12"
    static var itemNum = 30
    static var VisitedMainView = 1
    static var VisitedListView = 1
    static var VisitedItemInfoView = 1
    static var VisitedCameraView = 1
    static var VisitedTrainView = 1
    static var capturedPhotos = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func go12ButtonAction(_ sender: Any) {
        let uName = pidField.text!
        
        if uName == "" {
            showRecognitionToast(message: "Enter participant id.")
        } else {
            ParticipantViewController.userName = uName
            ParticipantViewController.category = "Spice"
            ParticipantViewController.mode = "step12"
            
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReadyViewController") as! UIViewController
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func go34ButtonAction(_ sender: Any) {
        let uName = pidField.text!
        
        if uName == "" {
            showRecognitionToast(message: "Enter participant id.")
        } else {
            ParticipantViewController.userName = uName
            ParticipantViewController.category = "Spice"
            ParticipantViewController.mode = "step34"
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReadyViewController") as! UIViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func showRecognitionToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: 100, width: 150, height: 35))
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
    
    static func writeLog(_ text: String) {
        let file = "log_\(ParticipantViewController.userName).txt" //this is the file. we will write to and read from it
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let fileURL = dir.appendingPathComponent(file)
//            
//            do {
//                let date = Date()
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
//                let millis = Int(date.timeIntervalSince1970*1000)
//                let dateString = formatter.string(from: date)
//                
//                let header = "\(ParticipantViewController.userName),\(ParticipantViewController.category),\(ParticipantViewController.mode),\(dateString),\(millis)"
//                
//                let textData = "\(header),\(text)\n".data(using: String.Encoding.utf8)!
//                
//                
//                
//                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
//                    defer {
//                        fileHandle.closeFile()
//                    }
//                    
//                    fileHandle.seekToEndOfFile()
//                    fileHandle.write(textData)
//                } else {
//                    try textData.write(to: fileURL)
//                }
//            } catch {
//                print("write log error")
//            }
//        }
    }
    
    func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss-SSSS"
        //        formatter.dateFormat = "yyyy-MM-dd"
        
        let myString = formatter.string(from: date) // string purpose I add here
        return myString
    }
}
