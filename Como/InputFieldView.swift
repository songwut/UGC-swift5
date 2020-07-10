//
//  InputFieldView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class InputFieldView: UIView {
    
    var view: UIView!
    let nibName: String = "InputFieldView"
    var textFieldFontSize: CGFloat!
    var paddingView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
    var border = CALayer()
    var borderColor: UIColor!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBInspectable var text: String? {
        get {
            return self.textField.text
        }
        set(text) {
            self.textField.text = text
        }
    }
    
    var secureText: Bool? {
        get {
            return self.textField.isSecureTextEntry
        }
        set(secureText) {
            self.textField.isSecureTextEntry = secureText!
        }
    }
    
    var fontSize: CGFloat? {
        get {
            return self.textFieldFontSize
        }
        set {
            self.textFieldFontSize = newValue
            self.textField.font = .systemFont(ofSize: fontSize!)
        }
    }
    
    @IBInspectable var numberType: Bool = false {
        didSet {
            switch numberType {
                case true:
                self.textField.keyboardType = .numberPad
                default:
                self.textField.keyboardType = .default
            }
        }
    }
    
    @IBInspectable var textAlignment: String = "left" {
        didSet {
            switch textAlignment {
            case "left":
                self.textField.textAlignment = .left
            case "right":
                self.textField.textAlignment = .right
            case "center":
                self.textField.textAlignment = .center
            default:
                self.textField.textAlignment = .left
            }
        }
    }
    
    @IBInspectable var placeHolder: String? {
        didSet {
            self.textField.placeholder = placeHolder
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            self.textField.textColor = textColor
        }
    }
    
    @IBInspectable var icon: UIImage? {
        get {
            return self.paddingView.image
        }
        set(icon) {
            self.paddingView.image = icon
            self.paddingView.contentMode = .scaleAspectFit
            self.textField.leftView = self.paddingView
            self.textField.leftViewMode = .always
        }
    }
    
    @IBInspectable var underLineColor: UIColor! {
        get {
            return self.borderColor
        }
        set(underLineColor) {
            self.superview!.setNeedsLayout()
            self.superview!.layoutIfNeeded()
            
            self.borderColor = underLineColor
            self.border.frame = CGRect(x: self.textField.frame.origin.x, y: self.textField.frame.size.height, width: self.textField.frame.size.width, height: 1);
            border.backgroundColor = underLineColor.cgColor
            layer.addSublayer(self.border)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }
}
