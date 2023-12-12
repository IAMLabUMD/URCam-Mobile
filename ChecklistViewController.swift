//
//  ViewController.swift
//  CheckList app
//
//  Created by Jaina Gandhi on 5/5/18.
//  Copyright © 2018 Jaina Gandhi. All rights reserved.
//

import UIKit
//import MySQLDriveriOS
// tutorial for MySQLDriveriOS: https://github.com/mcorega/MySqlSwiftNative

// post code from
// https://medium.com/@sdrzn/networking-and-persistence-with-json-in-swift-4-part-2-e4f35a606141




class ChecklistViewController: UIViewController { //UITableViewController {
  

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet var UITableView: UITableView!
    
//    var con: MySQL.Connection!
    var objs_from_server = "na"
    var objs_from_server_data: Data?
    var itemArray = [Item]() //to set-up table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUpFoodItems()
        
        /*
        let myPost = Post(cmd: "objList", param: "")
        submitPost(post: myPost) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
         */
        renewList2()
    }
        
//    func setUpFoodItems(){
//        itemArray.append(FoodItem(itemName: "Normal Coke", itemDate: "18thOct2018", image:"1"))
//        itemArray.append(FoodItem(itemName: "Ramen", itemDate: "10ndOct2018", image:"2"))
//        itemArray.append(FoodItem(itemName: "Chocos", itemDate: "9ndOct2018", image:"3"))
//        itemArray.append(FoodItem(itemName: "Diet Coke", itemDate: "5thOct2018", image:"1"))
//        itemArray.append(FoodItem(itemName: "Ramen", itemDate: "1ndOct2018", image:"2"))
//        itemArray.append(FoodItem(itemName: "Beans", itemDate: "29ndSep2018", image:"3"))
//        itemArray.append(FoodItem(itemName: "Lentils", itemDate: "25thSep2018", image:"1"))
//        itemArray.append(FoodItem(itemName: "Fritos", itemDate: "22ndSep2018", image:"2"))
//        itemArray.append(FoodItem(itemName: "Salsa", itemDate: "22ndSep2018", image:"3"))
//    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //on click event
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     guard let Cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem")as? ChecklistTableViewCell else {
     return UITableViewCell()
     }
     
     Cell.itemName.text = itemArray[indexPath.row].itemName
     Cell.itemDate.text = itemArray[indexPath.row].itemDate
     //Cell.imgView.image = UIImage(named:itemArray[indexPath.row].image)
     return Cell
     }
    */
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // list from file system
    func renewList2(){
        itemArray = [Item]()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for url in fileURLs {
                
                let components = url.pathComponents
                let cname = components[components.count-1]
                let cnt = countSamples(cname)
                
                if cnt < 5 {
                    if cnt >= 0 { // -1 is a special value for non-directory elements
                        deleteDirectory(cname)
                    }
                    continue
                }
                
                var date = "N/A"
                if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) as [FileAttributeKey: Any],
                    let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
                    print(creationDate)
                }
                
                itemArray.append(Item(itemName: cname, itemDate: "tmp", relativeDate: "tmp", image:"1"))
            }
        } catch {
            print("Error while enumerating classes \(documentsDirectory): \(error.localizedDescription)")
        }
        //DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func deleteDirectory(_ label: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let classPath = documentsDirectory.appendingPathComponent("\(label)")
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: classPath)
        } catch {
            print("Error while deleting a class \(classPath): \(error.localizedDescription)")
        }
    }
    
    func countSamples (_ label: String) -> Int {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imgPath = documentsDirectory.appendingPathComponent("\(label)")
        
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: imgPath.absoluteString, isDirectory: &isDirectory) {
            do {
                //return -1
                //try FileManager.default.createDirectory(atPath: imgPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
        
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: imgPath, includingPropertiesForKeys: nil)
            // process files
            return fileURLs.count
        } catch {
            print("Error while enumerating files \(imgPath): \(error.localizedDescription)")
            return -1
        }
    }
    
}

/*
class FoodItem {
    let itemName: String
    let itemDate: String
    //let image: String
    init( itemName: String, itemDate: String, image: String){
        self.itemName = itemName
        self.itemDate = itemDate
        //self.image = image
        
    }
    
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath ) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            itemArray.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

}
*/
    
    
    
    
       /* ["Trail Mix","Reese","Chocos","Skittles","Noodles"]
 
        // Do any additional setup after loading the view, typically from a nib.
    }

   

    // no. of rows in the tableView
    override func tableView(_ tableView: UITableView,
                numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    //list of rows
    override func tableView(_ tableView: UITableView,
                               cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChecklistItem",
                for: indexPath) as! ChecklistTableViewCell
            
            // Add the following code
            cell.itemName.text = items[indexPath.row%5]
            // End of new code block
            
            return cell
    }
    
 
    
    // add a new item
    @IBAction func addItem() {
        let newRowIndex = items.count
        
//        let item = ChecklistItem()
 //      item.text = "I am a new row"
 //       item.checked = false
 //      items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
    }*/
  
    



