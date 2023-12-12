//
//  Item.swift
//  CheckList app
//
//  Created by Jonggi Hong on 4/22/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

class Item {
    let itemName: String
    let itemDate: String
    let relativeDate: String
    //let image: String
    init( itemName: String, itemDate: String, relativeDate: String, image: String){
        self.itemName = itemName
        self.itemDate = itemDate
        self.relativeDate = relativeDate
        //self.image = image
    }
}
