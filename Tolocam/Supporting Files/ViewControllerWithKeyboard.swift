//
//  ViewControllerWithKeyboard.swift
//  Tolocam
//
//  Created by Leo on 2018/9/7.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

class ViewControllerWithKeyboard: UIViewController {
    private var keyboardSize: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Listen for when keyboard shall appear
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc public func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        guard keyboardSize != nil && keyboardSize?.height != 0 else { return }
        
        self.view.frame.origin.y = -keyboardSize!.height
    }
    
    @objc public func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
}
