//
//  CHecklistTableViewCell2.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/10/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

class ChecklistTableViewCell2: UITableViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemDate: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
