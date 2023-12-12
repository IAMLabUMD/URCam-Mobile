//
//  ImageCollectionViewCell.swift
//  CheckList app
//
//  Created by Ernest Essuah Mensah on 2/24/20.
//  Copyright © 2020 Jaina Gandhi. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    func setup() {
        
        contentView.addSubview(imageView)
        imageView.center = contentView.center
    }
    
}
