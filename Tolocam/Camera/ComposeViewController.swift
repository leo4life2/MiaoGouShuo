//
//  ComposeViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/3/13.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import AVOSCloud
import AVFoundation
import NVActivityIndicatorView

class ComposeViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate{
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var previewImage: UIImageView!
    var newImage = UIImage()
    var originalFrame = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 253/255, green: 104/255, blue: 134/255, alpha: 0.9),
            NSAttributedString.Key.font : UIFont(name: "PingFangSC-Medium", size: 20)! // Note the !
        ]
        
        self.title = "发布"
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 35, green: 35, blue: 35, alpha: 1)
        
//        self.hideKeyboardWhenTappedAround()
        
        captionTextView.textContainerInset = UIEdgeInsets(top: 18, left: 16, bottom: 0, right: 0)
        captionTextView.delegate = self
        captionTextView.text = "写点什么..."
        
        previewImage.image = newImage
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundImage = (UIImage(named:"#232323"))
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "写点什么..." {
            textView.text = ""
        }
        textView.becomeFirstResponder()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        captionTextView.resignFirstResponder()
        return true;
    }
        
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        captionTextView.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.originalFrame = self.captionTextView.frame
            self.captionTextView.frame = CGRect(x: self.captionTextView.frame.minX, y: self.view.frame.height - self.captionTextView.frame.height - keyboardSize.size.height + (self.tabBarController?.tabBar.frame.size.height)!, width: self.captionTextView.frame.width, height: self.captionTextView.frame.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.captionTextView.frame = originalFrame
    }
    
    
    @IBAction func composeTapped(_ sender: AnyObject) {
        if self.captionTextView.text == "写点什么..." {
            self.captionTextView.text = ""
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDate = dateFormatter.string(from: date)
        if let imageToBeUploaded = self.previewImage.image {
            let imagedata2 = imageToBeUploaded.lowQualityJPEGNSData
            
            
            let file = AVFile(data:imagedata2 as Data) as AVFile
            let fileCaption = self.captionTextView.text
            
            let photoToUpload = AVObject(className: "Posts")
            photoToUpload["Image"] = file
            photoToUpload["Caption"] = fileCaption
            photoToUpload["postedBy"] = AVUser.current()!
            photoToUpload["date"] = localDate
            photoToUpload["Likes"] = 0
            photoToUpload["likedBy"] = [:]
            
            photoToUpload.saveInBackground({ (done:Bool, error:Error?) in
                if done{
                    self.navigationController?.popViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                    self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PostVCRefresh"), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "ProfileVCRefresh"), object: nil)
                }else{
                    print(error!)
                }
            })
        } else {
            TLAlertView.showAlert(title: "Error", message: "please upload picture first", cancel: "OK")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
