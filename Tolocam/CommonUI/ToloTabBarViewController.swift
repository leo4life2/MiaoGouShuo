//
//  ToloTabBarViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/2/15.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class ToloTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let items = self.tabBar.items {
            for item in items {
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.toloPink], for: .selected)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
