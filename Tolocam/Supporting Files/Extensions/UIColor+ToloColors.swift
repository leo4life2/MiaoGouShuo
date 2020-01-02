//
//  UIColor+ToloColors.swift
//  Tolocam
//
//  Created by Leo on 2018/9/7.
//  Copyright © 2018 leo. All rights reserved.
//

import UIKit

extension UIColor {
    static let toloBlue = UIColor(red: 93.0/255.0, green: 215.0/255.0, blue: 217.0/255.0, alpha: 1)
    static let toloPink = UIColor(red: 253.0/255.0, green: 104.0/255.0, blue: 134.0/255.0, alpha: 1)
    
    class func color(hexString hex: String) -> UIColor {
        return UIColor.color(hexString: hex, alpha: 1)
    }
    
    class func color(hexString hex: String, alpha: CGFloat = 1) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.count < 6 {
            return UIColor.clear
        }
        if cString.hasPrefix("0X") {
            cString = String(cString[String.Index(encodedOffset: 2)...])
        }
        
        if cString.hasPrefix("#") {
            cString = String(cString[String.Index(encodedOffset: 1)...])
        }
        if cString.count != 6 {
            return UIColor.clear
        }
        let rString = String(cString[String.Index(encodedOffset: 0) ..< String.Index(encodedOffset: 2)])
        let gString = String(cString[String.Index(encodedOffset: 2) ..< String.Index(encodedOffset: 4)])
        let bString = String(cString[String.Index(encodedOffset: 4) ..< String.Index(encodedOffset: 6)])
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    /// UIColor 转 UIImage
    
    ///
    
    /// - Returns: UIImage
    func toImage(size: CGSize? = nil) -> UIImage {
        let width = size?.width != nil ? size!.width : CGFloat(1)
        let height = size?.height != nil ? size!.height : CGFloat(1)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
