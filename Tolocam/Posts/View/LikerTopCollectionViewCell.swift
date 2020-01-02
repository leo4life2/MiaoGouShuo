//
//  LikerTopCollectionViewCell.swift
//  Tolocam
//
//  Created by wyx on 2019/2/21.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class LikerTopCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var crownImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    @IBOutlet weak var profileWidth: NSLayoutConstraint!
    
    var isTop: Bool = false {
        willSet {
            if newValue {
                profileImageView.layer.cornerRadius = 18
            } else {
                profileImageView.layer.cornerRadius = 12
                crownImageView.isHidden = true
                profileHeight.constant = 24
                profileWidth.constant = 24
            }
            profileImageView.layer.masksToBounds = true
        }
    }
}
