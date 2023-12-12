//
//  Util.swift
//  CheckList app
//
//  Created by Jonggi Hong on 2/22/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit

class Util {
    
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(ParticipantViewController.userName)")
    
    func createDirectory(_ label: String) {
        
        let classPath = Log.userDirectory.appendingPathComponent("\(label)")
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: classPath.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: classPath.path, withIntermediateDirectories: true, attributes: nil)
                print("directory for \(label) is created. \(classPath.path)")
            } catch let error as NSError {
                print("Error creating directory for \(label): \(error.localizedDescription)")
            }
        }
    }
    
    func downloadImg(item: String) {
        createDirectory(item)
        let imgPath = Log.userDirectory.appendingPathComponent("\(item)")
        for i in 1...ParticipantViewController.itemNum {
            let url = URL(string: "http://128.8.224.124/TOR_app/TrainFiles/jonggi/Spice/\(item)/\(i).jpg")
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            let filename = imgPath.appendingPathComponent("\(i).jpg")
            try? data?.write(to: filename)
            print("The image is saved. --\(item)--\n\(filename)")
        }
    }
}
