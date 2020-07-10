//
//  CustomButton.swift
//  Como
//
//  Created by Songwut Maneefun on 5/13/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class CustomButton: UIButton {
    
    var iconImageView = UIImageView(frame: CGRect.zero)
    
    @IBInspectable var icon: UIImage? {
        didSet {
            self.iconImageView.image = self.icon
            self.iconImageView.frame = CGRect(x: 30, y: (self.frame.size.height - 20) / 2, width: 20, height: 20)
        }
    }

    @IBInspectable var cornerRadiusValue: CGFloat = 10.0 {
        didSet {
            self.layer.cornerRadius = cornerRadiusValue
            setUpView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setUpView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            setUpView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        self.clipsToBounds = true
        
        if self.iconImageView.tag != 1 {
            self.addSubview(self.iconImageView);
            self.iconImageView.tag = 1
        }
        
    }

}
