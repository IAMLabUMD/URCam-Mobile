//
//  ItemAttrVC.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 2/21/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import UIKit

class ItemAttrVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var item: Item?

    var attributes = ["Small object", "Cropped object", "Blurry", "Hand in image"]
    var var_attributes = ["Background variation", "Side variation", "Distance variation"]
    
    var backgroundVariation = 0.0
    var sideVariation = 0.0
    var distanceVariation = 0.0
    var cnt_hand = 0
    var cnt_blurry = 0
    var cnt_crop = 0
    var cnt_small = 0
    var verbose = true
    
    var httpController = HTTPController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let item = item {
            
            let name = Functions.separateWords(name: item.itemName)
            objectNameLabel.text = name
            
            
            let imgPath = Util().userDirectory.appendingPathComponent("\(item.itemName)/1.jpg")
            if let data = try? Data(contentsOf: imgPath) {
                objectImageView.image = UIImage(data: data)
            }
            
            objectImageView.layer.cornerRadius = 12
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
        objectImageView.layer.cornerRadius = 12
        objectImageView.layer.masksToBounds = true
        
        
        
        
        let proceedButton = UIButton()
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.titleLabel?.font = .rounded(ofSize: 16, weight: .bold)
        proceedButton.setTitle("Next", for: .normal)
        //helpButton.addTarget(self, action: #selector(guideButtonAction), for: .touchUpInside)
        proceedButton.addTarget(self, action: #selector(handleNextButton), for: .touchUpInside)
        //proceedButton.accessibilityLabel = "More. This button takes you to a screen that will give you information about the TOR app"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: proceedButton)
    }
    
    @objc
    func handleNextButton() {
        let vc = ItemAudioVC()
        vc.objectName = item?.itemName ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return var_attributes.count
        }
        return attributes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell", for: indexPath) as! ItemAttributeTableViewCell

        // Configure the cell...
        cell.attributeLabel.text = attributes[indexPath.row]
        
        if indexPath.section == 0 {
            cell.attributeLabel.text = var_attributes[indexPath.row]
        } else if indexPath.section == 1 {
            cell.attributeLabel.text = attributes[indexPath.row]
        }
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let varVal = backgroundVariation/0.15*100
                if verbose {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = backgroundVariation > 0.1 ? "Yes": "No"
                }
                
            } else if indexPath.row == 1 {
                
                let varVal = sideVariation/1.5*100
                if verbose {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = sideVariation > 1 ? "Yes": "No"
                }
                
            } else if indexPath.row == 2 {
                
                let varVal = distanceVariation/0.15*100
                if verbose {
                    cell.level.text = String(format: "%.1f%%", varVal)
                } else {
                    cell.level.text = distanceVariation > 0.1 ? "Yes": "No"
                }
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                
                if verbose {
                    cell.level.text = "\(cnt_small) out of 30"
                } else {
                    cell.level.text = cnt_small > 5 ? "Yes": "No"
                }
                
                
            } else if indexPath.row == 1 {
                
                if verbose {
                    cell.level.text = "\(cnt_crop) out of 30"
                } else {
                    cell.level.text = cnt_crop > 5 ? "Yes": "No"
                }
                
                
            } else if indexPath.row == 2 {
                
                if verbose {
                    cell.level.text = "\(cnt_blurry) out of 30"
                } else {
                    cell.level.text = cnt_blurry > 5 ? "Yes": "No"
                }
                
                
            } else if indexPath.row == 3 {
                
                if verbose {
                    cell.level.text = "\(cnt_hand) out of 30"
                } else {
                    cell.level.text = cnt_hand > 5 ? "Yes": "No"
                }
            }
        }

        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 77
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 72))
        headerView.backgroundColor = .themeBackground
        
        let headerLabel = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.width, height: 40))
        
        if section == 0 {
            headerLabel.text = "Group characteristics"
        } else if section == 1 {
            headerLabel.text = "Photo characteristics"
        }
        
        headerLabel.textColor = .darkGray
        headerLabel.font = .rounded(ofSize: 16, weight: .heavy)
        headerLabel.textAlignment = .left
        
        headerView.addSubview(headerLabel)
        return headerView
    }

}

