//
//  WalkthroughPage5ViewController.swift
//  Tolocam
//
//  Created by Leo on 2018/10/30.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class WalkthroughPage5ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    var imageToUpload: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uploadButton.layer.cornerRadius = self.uploadButton.frame.height/2
        self.uploadButton.layer.borderWidth = 4
        self.uploadButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.uploadButton.addTarget(self, action: #selector(buttonHighlight(_:)), for: .touchDown)
        self.uploadButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpInside)
        self.uploadButton.addTarget(self, action: #selector(buttonNormal(_:)), for: .touchUpOutside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.selectImageButton.clipsToBounds = true
        self.selectImageButton.layer.borderColor = UIColor.white.cgColor
        self.selectImageButton.layer.borderWidth = 1
        self.selectImageButton.layer.cornerRadius = self.selectImageButton.frame.width/2
    }
    
    @IBAction private func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction private func upload(_ sender: Any) {
        
        guard let imageData = self.imageToUpload?.lowQualityJPEGNSData else {
            self.displayErrorAlert(message: "你还没有选择照片", completion: nil)
            return
        }
        let imageFile = AVFile(data: imageData as Data)
        
        // Set image as profile image for user  // 将图片设置为头像
        let userObj = AVUser.current()
        userObj?.setObject(imageFile, forKey: "profileIm")
        
        userObj?.saveInBackground { (done:Bool, error:Error?) in
            if let error = error {
                self.displayErrorAlert(error: error, completion: nil)
            } else {
                self.__uploadPost(imageFile){
                    self.show(Tolo.getTabBarController(), sender: self)
                }
            }
        }
        
    }
    
    private func __uploadPost(_ imageFile: AVFile, completion: (() -> Void)?){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateStyle = DateFormatter.Style.short
        let localDate = dateFormatter.string(from: date)
        
        let fileCaption = "大家好～ 我是 " + AVUser.current()!.username!
        
        let photoToUpload = AVObject(className: "Posts")
        photoToUpload["Image"] = imageFile
        photoToUpload["Caption"] = fileCaption
        photoToUpload["postedBy"] = AVUser.current()!
        photoToUpload["date"] = localDate
        photoToUpload["Likes"] = 0
        photoToUpload["likedBy"] = [:]
        
        photoToUpload.saveInBackground { (done, error) in
            if let error = error{
                self.displayErrorAlert(error: error, completion: nil)
            }else if let completion = completion{
                completion()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage!
        
        if let editedImg = info[.editedImage] as? UIImage{
            image = editedImg
        } else if let originalImg = info[.originalImage] as? UIImage{
            image = originalImg
        }
        
        self.selectImageButton.setBackgroundImage(image, for: .normal)
        self.selectImageButton.setTitle("", for: .normal)
        self.imageToUpload = image
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
