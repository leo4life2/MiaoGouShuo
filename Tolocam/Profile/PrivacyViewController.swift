//
//  PrivacyViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/3/15.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.layer.borderColor = UIColor.white.cgColor
        textView.layer.borderWidth = 1
        
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 4
    }
    

    @IBAction func buttonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
