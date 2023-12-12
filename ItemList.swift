//
//  ItemList.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/22/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

class ItemList {
    var itemArray = [Item]() //to set-up table
    
    func getListString() -> String {
        var res = ""
        if itemArray.count > 0 {
            res = itemArray[0].itemName
            for i in 1 ..< itemArray.count {
                res += ":"+itemArray[i].itemName
            }
        }
        return res
    }
    
    func renewList() {
        itemArray = [Item]()
        var itemCnt = 0
        
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: Log.userDirectory, includingPropertiesForKeys: nil)
            //print(fileURLs)
            for url in fileURLs {
                let components = url.pathComponents
                let cname = components[components.count-1]
                let cnt = countSamples(cname)
                
                //print(cnt)
                
                if cname == "testPhotos" || cname == "tmpobj" {
                    continue
                }
                
                if cnt < ParticipantViewController.itemNum {
                    //                if cnt < itemNum + 1 { // tmp code for debugging
                    if cnt >= 0 { // -1 is a special value for non-directory elements
                        deleteDirectory(cname)
                    }
                    continue
                } else if cnt != -1 {
                    itemCnt += 1
                    
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                        itemArray.append(Item(itemName: cname, itemDate: formatDateAbsolute(date: creationDate), relativeDate: formatDateRelative(date: creationDate), image:"1"))
                        //print(cname)
                    }
                }
            }
        } catch {
            print("Error while enumerating classes \(Log.userDirectory): \(error.localizedDescription)")
        }
        
        itemArray = itemArray.sorted(by: { $0.itemDate > $1.itemDate })
    }
    
    func countSamples (_ label: String) -> Int {
        let imgPath = Log.userDirectory.appendingPathComponent("\(label)")
        let fileManager = FileManager.default
        
        var isDirectory = ObjCBool(true)
        if fileManager.fileExists(atPath: imgPath.path, isDirectory: &isDirectory) {
            //print("\(isDirectory.boolValue)")
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
    
    func deleteDirectory(_ label: String) {
        let classPath = Log.userDirectory.appendingPathComponent("\(label)")
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: classPath)
        } catch {
            print("Error while deleting a class \(classPath): \(error.localizedDescription)")
        }
    }
    
    func formatDateRelative(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        formatter.locale = Locale(identifier: "en_US")
        
        let myString = formatter.string(from: date) // string purpose I add here
        return myString
    }
    
    func formatDateAbsolute(date: Date) -> String {
        let formatter = DateFormatter()
        
        // initially set the format based on your datepicker date / server String
        //        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.dateFormat = "yyyy-MM-dd"
        
        let myString = formatter.string(from: date) // string purpose I add here
        return myString
    }
    
    func contains(obj_name: String) -> Bool {
        for item in itemArray {
            if item.itemName.lowercased() == obj_name.lowercased() {
                return true
            }
        }
        return false
    }
}
