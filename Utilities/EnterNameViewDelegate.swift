//
//  EnterNameViewDelecate.swift
//  CheckList app
//
//  Created by Jonggi Hong on 3/9/19.
//  Copyright © 2019 Jaina Gandhi. All rights reserved.
//

import Foundation

protocol EnterNameViewDelegate {
    func addItemTapped(object_name: String)
    func rename(newName: String)
    func cancelButtonTapped()
}
