//
//  UIView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/29/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = size.width  / self.size.width
        let heightRatio = size.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height:size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        print("newSize", newSize)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}

extension Int {
    func toString () -> String? {
        return "\(self)"
    }
    
    func toBool () -> Bool? {
        switch self {
        case 0:
            return false
        case 1:
            return true
        default:
            
            return nil
        }
    }
}

extension Bool {
    func toInt () -> Int! {
        switch self {
        case false:
            return 0
            
        case true:
            return 1
            
        }
    }
    
    func toAlpha () -> CGFloat! {
        switch self {
        case false:
            return 0.0
            
        case true:
            return 1.0
            
        }
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class  var  className: String {
        return String(describing: self)
    }
}



