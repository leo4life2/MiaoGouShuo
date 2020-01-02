//
//  CameraViewController.swift
//  Tolocam
//
//  Created by wyx on 2019/3/13.
//  Copyright © 2019年 leo. All rights reserved.
//

import UIKit
import AVFoundation
import AVOSCloud

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    var videoConnection: AVCaptureConnection?//捕获链接
    var capturePhotoSettings: AVCapturePhotoSettings?
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCapturePhotoOutput?
    var imageCaptured : UIImage!
    var previewLayer : AVCaptureVideoPreviewLayer?
    var soundPath = URL(fileURLWithPath: Bundle.main.path(forResource: "meow", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()                
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"#232323"), for: .default)
        
        self.view.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        self.view.isOpaque = false
        
        let shutterSound = URL(fileURLWithPath: Bundle.main.path(forResource: "meow", ofType: "wav")!)
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch  {
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch  {
        }
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: shutterSound)
        } catch  {
        }
        
        audioPlayer.prepareToPlay()
        captureSession = AVCaptureSession()
        
        #if TARGET_OS_IPHONE
        self.captureSession?.sessionPreset = AVCaptureSessionPresetHigh
        #endif
        
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video) {
            var error : NSError?
            var input: AVCaptureDeviceInput!
            do {
                input = try AVCaptureDeviceInput(device: backCamera)
            } catch let error1 as NSError {
                error = error1
                input = nil
            }
            
            if (error == nil && captureSession?.canAddInput(input) != nil){
                
                captureSession?.addInput(input)
                
                stillImageOutput = AVCapturePhotoOutput()
                capturePhotoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
                stillImageOutput?.photoSettingsForSceneMonitoring = capturePhotoSettings
                
                if (captureSession?.canAddOutput(stillImageOutput!) != nil){
                    captureSession?.addOutput(stillImageOutput!)
                    
//                    previewLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                    
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession?.startRunning()
                    
                }
                
                
            }
        }
    }
    
    func imageScaledToSize(size: CGSize, image: UIImage) -> UIImage {
       UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
        
        //        var instanceOfImageCropView: ImageCropView = ImageCropView()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //每次需要重新加载
        capturePhotoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])
        self.tabBarController?.tabBar.backgroundImage = (UIImage(named:"#232323"))
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.backgroundImage = UIImage(named: "#FFFFFF")
    }
    
    @IBAction func didPressPhotoBtn(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: AnyObject) {
        
        audioPlayer.play()
        videoConnection = stillImageOutput?.connection(with: AVMediaType.video)
        if videoConnection == nil {
            print("take photo failed!")
            return
        }
        
        stillImageOutput?.capturePhoto(with: capturePhotoSettings!, delegate: self)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            performSegue(withIdentifier: "showComposeSegue", sender: image)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showComposeSegue" {
            let vc = segue.destination as! ComposeViewController
            if let image = sender as? UIImage {
                vc.newImage = image
            }
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photo = photoSampleBuffer {
            if let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photo, previewPhotoSampleBuffer: previewPhotoSampleBuffer),
                let image = UIImage(data: data) {
                performSegue(withIdentifier: "showComposeSegue", sender: image)
            }
        }
    }
}
