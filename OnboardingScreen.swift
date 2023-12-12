//
//  OnboardingScreen.swift
//  TOR-Mobile
//
//  Created by Ernest Essuah Mensah on 3/7/21.
//  Copyright © 2021 IAM Lab. All rights reserved.
//

import Foundation


//struct OnboardingScreen {
//
//    var title: String
//    var description: String
//    var image: UIImage
//
//}


class OnboardingScreen {
    
    var title: String
    var description: String
    var image: UIImage
    var index: Int
    var next: OnboardingScreen?
    var previous: OnboardingScreen?
    
    init(title: String, description: String, image: UIImage, index: Int) {
        self.title = title
        self.description = description
        self.image = image
        self.index = index
    }
}
