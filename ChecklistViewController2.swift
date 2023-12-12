//
//  ChecklistViewController2.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/9/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import AVFoundation
import UIKit

class ChecklistViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    
    @IBOutlet var clearView: UIView!
    @IBOutlet weak var clearLabel: UILabel!
    // table view tutorial
    // http://www.theappguruz.com/blog/ios-table-view-tutorial-using-swift
//    var itemArray = [FoodItem]() //to set-up table
    var itemList = ItemList()
    var httpController = HTTPController()
    var searchResults: [Item] = []
    var resultSearchController = UISearchController()
    var vSpinner : UIView?
    @IBOutlet var superView: UIView!
    var util = Util()
    
    // to be used when deleting an object
    var shouldEdit = true
    var selectedIndexPath = IndexPath()
    var header: UILabel!
    
//    var guideText = "This screen shows the list of items that this TOR learned from you. Tapping on an item takes you to a new screen with details of the item. There is the number of items in the list at the bottom of the screen. There is a back button at the top left for going back to the main screen. Tap on any part of the screen to start to explore the list."
    var guideText = "You can view a list of items that you have taught the app to recognize. You can edit the name of an item or delete a previously taught item."
    var olView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var numLabel: UILabel!
    var player: AVAudioPlayer?
    
    var toastLabel: UILabel!
    var trainChecker: Timer!
    var cellHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navHeight = navigationController!.navigationBar.frame.height
        let contentSpace = view.frame.height - navHeight
        cellHeight = contentSpace > 700 ? contentSpace / 4.5 : contentSpace / 4.2
        deleteView.addShadow()
        clearView.addShadow()

        print("ChecklistViewController2: \(ParticipantViewController.userName) \(ParticipantViewController.category)")
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let clearButton = UIButton()
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        clearButton.accessibilityLabel = "Clear. This button removes all items in the list."
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearButton)
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search items"
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        tableView.contentOffset = CGPoint(x: 0.0, y: resultSearchController.searchBar.frame.size.height)
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.searchBar.barTintColor = .clear
        resultSearchController.searchBar.backgroundImage = UIImage()
        tableView.backgroundColor = .white
        
        addEmptyLabel()
        setAccessibilityLabels()
        
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
    
    @objc func clearButtonAction() {
        Log.writeToLog("\(Actions.tappedOnBtn) clearItemsButton")
        
        self.view.showView2(viewToShow: clearView)
    }
    
    
    func setAccessibilityLabels() {
        deleteLabel.accessibilityLabel = "Are you sure you want to delete this item?"
        clearLabel.accessibilityLabel = "Are you sure you want to remove all objects in the list?"
    }
    
    
    func addEmptyLabel() {
        
        view.addSubview(emptyLabel)
        emptyLabel.center = view.center
        emptyLabel.font = .rounded(ofSize: 16, weight: .bold)
        emptyLabel.alpha = 0
    }
    
    
    func sendForSync(difference: String) {
        let diffs = difference.components(separatedBy: "--")
        let app_string = diffs[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let server_string = diffs[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let items_app_only = app_string.components(separatedBy: ":")
        let items_server_only = server_string.components(separatedBy: ":")
        var isLoading = false
        
        
        if app_string != "" || server_string != ""{
            print("loading images")
            isLoading = true
            addAtivityIndicator("Loading images")
        }

        
        DispatchQueue.main.async {
            if app_string != "" {
                for item in items_app_only {
                    if item.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        self.itemList.deleteDirectory(item)
                    }
                }
            }

            if server_string != "" {
                for item in items_server_only {
                    if item.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        self.util.downloadImg(item: item)
                    }
                }
            }
            isLoading = false
            
            self.itemList.renewList()
            self.tableView.reloadData()
            self.effectView.removeFromSuperview()
            
            let count = self.itemList.itemArray.count
            let header = count > 1 ? "\(count) items" : count == 0 ? "No items" : "\(count) item"
            self.navigationItem.titleView = Functions.createHeaderView(title: header)
        }
        
        
//        print("loading....")
//        itemList.renewList()
//        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        ParticipantViewController.writeLog("ListView")
        
        Log.writeToLog("\(Actions.enteredScreen.rawValue) \(Screens.savedObjsScreen.rawValue)")
        
        // add overlay
        if ParticipantViewController.VisitedListView == 0 && ParticipantViewController.mode == "step12" {
            let currentWindow: UIWindow? = UIApplication.shared.keyWindow
            olView = createOverlay(frame: view.frame)
            currentWindow?.addSubview(olView)
            ParticipantViewController.VisitedListView = 1
            //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, guideText)
            
            tableView.accessibilityElementsHidden = true
            self.navigationController?.navigationBar.accessibilityElementsHidden = true
        } else {
            itemList.renewList()
        }
        
        makeToast()
        trainChecker = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTraining), userInfo: nil, repeats: true)
        tableView.tableFooterView = UIView()
        
        let count = itemList.itemArray.count
        let headerText = count > 1 ? "\(count) items" : count == 0 ? "No items" : "\(count) item"
        
        header = Functions.createHeaderView(title: headerText)
        navigationItem.titleView = header
        
        if count == 0 {
            emptyLabel.alpha = 1
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if resultSearchController.isActive {
            resultSearchController.isActive = false
        }
    }
    
    // https://stackoverflow.com/questions/28448698/how-do-i-create-a-uiview-with-a-transparent-circle-inside-in-swift
    func createOverlay(frame: CGRect) -> UIView {
        // Step 1
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
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
        ParticipantViewController.writeLog("ListOverlayDismiss")
        
        self.navigationController?.navigationBar.accessibilityElementsHidden = false
        tableView.accessibilityElementsHidden = false
        //UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.navigationController)
        
        olView.removeFromSuperview()
        
        itemList.renewList()
        tableView.reloadData()
        numLabel.text = "\(itemList.itemArray.count) items"
    }
    
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
    
    @objc func checkTraining() -> Bool {
        let file = "trainMark.txt" //this is the file. we will write to and read from it
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                
                if text2.contains("on"){
                    //showToast()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive {
            return searchResults.count
        }
        return itemList.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem2", for: indexPath) as! ChecklistTableViewCell
        
        var currItemList = itemList.itemArray
        
        if (resultSearchController.isActive) {
            currItemList = searchResults
        }
        
        let item = currItemList[indexPath.row]
        let itemName = Functions.separateWords(name: item.itemName)
        cell.item = item
        cell.accessibilityLabel = "\(itemName) saved on \(item.relativeDate)"
        cell.delegate = self
        
        return cell
    }
    
    
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if shouldEdit {
            let remove = UIContextualAction(style: .normal, title: nil) { (action, view, finished) in
                
                let cell = tableView.cellForRow(at: indexPath) as? ChecklistTableViewCell
                Log.writeToLog("\(Actions.tappedOnBtn) deleteButton")
                cell?.bgView.showView(viewToShow: self.deleteView)
                self.selectedIndexPath = indexPath
                
                finished(true)
            }
            remove.backgroundColor = #colorLiteral(red: 1, green: 0.3233600794, blue: 0.04758066023, alpha: 1)
            let deleteImage = UIImage(named: "ic_delete")?.withRenderingMode(.alwaysTemplate)
            remove.image = deleteImage
            
            
            
            let config = UISwipeActionsConfiguration(actions: [remove])
            config.performsFirstActionWithFullSwipe = true
            
            return config
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if resultSearchController.isActive {
                let itemName = searchResults[indexPath.row].itemName
                ParticipantViewController.writeLog("ListSelectItem-\(itemName)")
                httpController.requestRemove(itemName){}
                itemList.deleteDirectory(itemName)
                searchResults.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                print("------> Active searchC")
                
                var remIndex = -1
                for i in 0...itemList.itemArray.count-1 {
                    if itemList.itemArray[i].itemName == itemName {
                        remIndex = i
                    }
                }
                itemList.itemArray.remove(at: remIndex)
            } else {
                
                
                print("------> Not active searchC")
                
                let itemName = itemList.itemArray[indexPath.row].itemName
                ParticipantViewController.writeLog("ListSelectItem-\(itemName)")
                httpController.requestRemove(itemName){}
                itemList.deleteDirectory(itemName)
                itemList.itemArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
        
        navigationItem.titleView = Functions.createHeaderView(title: "\(itemList.itemArray.count) items")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currItemList = itemList.itemArray
        if (resultSearchController.isActive) {
            currItemList = searchResults
        }
        
        let itemName = currItemList[indexPath.row].itemName
        
        ParticipantViewController.writeLog("ListSelectItem-\(itemName)")
        
        trainChecker.invalidate()
        resultSearchController.searchBar.resignFirstResponder()
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemAudioViewController") as! ItemAudioViewController
//        vc.object_name = itemName
        
        
        let vc = ItemAudioVC()
        vc.objectName = itemName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        tableView.reloadData()
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        
        searchResults.removeAll()
        for item in itemList.itemArray {
            if item.itemName.lowercased().contains(searchText.lowercased()) {
                searchResults.append(item)
            }
        }
    }
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    func addAtivityIndicator(_ title: String) {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()

        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)

        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()

        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        tableView.addSubview(effectView)
    }
}


// Adopting the protocol technique to present the view for the selected object

extension ChecklistViewController2: ChecklistTableViewCellDelegate {
    
    func didTapOnCell(cell: ChecklistTableViewCell) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemAttrAndInfoVC") as! ItemAttrAndInfoVC
        vc.objectName = cell.itemName.text!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// Handle user actions
extension ChecklistViewController2 {
    
    // clear the items in the list
    func clearItems() {
        httpController.reqeustReset() {(response) in
            print("Reset response: \(response)")
        }
        
        for item in itemList.itemArray {
            let itemName = item.itemName
            httpController.requestRemove(itemName){}
            itemList.deleteDirectory(itemName)
        }
        itemList.itemArray.removeAll()
        self.header.text = "No items"
        self.navigationItem.titleView = self.header
        self.tableView.reloadData()
        self.emptyLabel.alpha = 1
    }
    
    func handleDeleteItem(indexPath: IndexPath) {
        let itemName = self.itemList.itemArray[indexPath.row].itemName
        Log.writeToLog("\(Actions.tappedOnBtn) yesDeleteButton")
        self.httpController.requestRemove(itemName){}
        self.itemList.deleteDirectory(itemName)
        self.itemList.itemArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)

        let count = self.itemList.itemArray.count

        if count > 0 {
            self.header.text = "\(count) items"
        } else {
            self.header.text = "No items"
            self.tableView.reloadData()
        }

        self.navigationItem.titleView = self.header

        if count == 0 {
            self.emptyLabel.alpha = 1
        }
        
    }
    
    
    
    @IBAction func handleYesClearButton(_ sender: Any) {
        clearItems()
        textToSpeech("All items are removed.")
        dismissClearView()
    }
    
    @IBAction func handleNoClearButton(_ sender: Any) {
        dismissClearView()
    }
    
    
    @IBAction func handleYesButton(_ sender: Any) {
        handleDeleteItem(indexPath: selectedIndexPath)
    }
    
    @IBAction func handleNoButton(_ sender: Any) {
        Log.writeToLog("\(Actions.tappedOnBtn) noDeleteButton")
        dismissDeleteView()
    }
    
    func dismissClearView() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            
            self.clearView.transform = CGAffineTransform(translationX: 0, y: 32)
            self.clearView.alpha = 0
        }) {(_) in
            self.clearView.removeFromSuperview()
        }
    }
    
    func dismissDeleteView() {
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
            
            self.deleteView.transform = CGAffineTransform(translationX: 0, y: 32)
            self.deleteView.alpha = 0
        }) {(_) in
            self.deleteView.removeFromSuperview()
        }
    }
}
