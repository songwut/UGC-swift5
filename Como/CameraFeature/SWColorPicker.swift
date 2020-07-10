//
//  SWColorPicker.swift
//  Como
//
//  Created by Songwut Maneefun on 6/20/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@objc protocol SWColorPickerDelegate {
    func protocolSWColorPickerSelectedColor(color: UIColor)
}

class SWColorPicker: UIView {

    var delegate: SWColorPickerDelegate?
    var currentSelectionY: CGFloat = 0.0
    let saturation = CGFloat(0.88)
    let brightness = CGFloat(0.88)
    let maxHueValues = 360
    let hues = (0...359).map { $0 }
    let fingerSize = CGSize(width: 100, height: 100)
    var selectedView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    
    @IBInspectable var selectedColor: UIColor! {
        didSet {
            if (selectedColor != self.selectedColor) {
                var hue: CGFloat = 0.0
                var temp: CGFloat = 0.0;
                if let selectedColor = self.selectedColor {
                    self.currentSelectionY = CGFloat(floorf(Float(hue) * Float(self.frame.size.height)));
                    self.setNeedsDisplay()
                }
                /*
                if ((selectedColor?.getHue(&hue, saturation: &temp, brightness: &temp, alpha: &temp)) != nil) {
                    
                }
                */
                self.delegate?.protocolSWColorPickerSelectedColor(color: selectedColor!)
                
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Set context & adapt to screen resolution
        let context = UIGraphicsGetCurrentContext()
        //let scale = UIScreen.mainScreen().scale
        //CGContextScaleCTM(context, scale, scale)
        
//        UIColor.blackColor().set()
//        var tempYPlace: CGFloat = self.currentSelectionY
//        if (tempYPlace < 0.0) {
//            tempYPlace = 0.0
//        } else if (tempYPlace >= self.frame.size.height) {
//            tempYPlace = self.frame.size.height - 1.0
//        }
//        let temp = CGRectMake(0.0, tempYPlace, self.frame.size.width, 1.0)
//        CGContextFillRect(context, temp)
        
        // Get height for each row
        self.currentSelectionY = frame.height / CGFloat(hues.count)
        print("hues.count", hues.count)
        
        // Draw one hue per row
        for hue in hues {
            let hueValue = CGFloat(hue) / CGFloat(maxHueValues)
            let color = UIColor(hue: hueValue, saturation: saturation, brightness: brightness, alpha: 1.0)
            context!.setFillColor(color.cgColor)
            let yPos = CGFloat(hue) * self.currentSelectionY
            context!.fill(CGRect(x: 0, y: yPos, width: frame.width, height: self.currentSelectionY))
        }
        self.setNeedsDisplay()
        
        //self.selectedView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        /*
        let context = UIGraphicsGetCurrentContext()
        //draw wings
        
        
        //draw central bar over it
        let cbxbegin = self.frame.size.width * 0.2;
        let cbwidth = self.frame.size.width * 0.6;
        let maxHeight = Int(self.frame.size.height)
        for y in 0 ..< maxHeight {
            let hue = y / maxHeight
            let color = UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
            CGContextSetFillColorWithColor(context, color.CGColor)
            let temp = CGRectMake(cbxbegin, CGFloat(y), cbwidth, 1.0);
            CGContextFillRect(context, temp)
        }
        */
    }
    
    func touchLocationChanged(touches: Set<UITouch>) {
        for touch in touches {
            self.currentSelectionY = touch.location(in: self).y
            let hue = (self.currentSelectionY / self.frame.size.height)
            self.selectedColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            print("Y:\(self.currentSelectionY) selectedColor: \(String(describing: self.selectedColor))")
            self.delegate?.protocolSWColorPickerSelectedColor(color: self.selectedColor)
            
            self.selectedView.center = CGPoint(x: touch.location(in: self).x, y: touch.location(in: self).y)
            self.selectedView.backgroundColor = self.selectedColor
            self.selectedView.alpha = 1
            //self.setNeedsDisplay()
        }
        
    }
    
    //TODO: get color from 
    func colorOfPoint(point: CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deinitialize(count: 4)
        return color
    }
    
    // mark - Touch Events
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    setNeedsDisplay()
        //update color
        self.touchLocationChanged(touches: touches)
        
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    setNeedsDisplay()
        self.touchLocationChanged(touches: touches)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    setNeedsDisplay()
        self.touchLocationChanged(touches: touches)
        self.selectedView.alpha = 0
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    
    setNeedsDisplay()
        self.selectedView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
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
        self.isUserInteractionEnabled = true
        self.selectedView.layer.cornerRadius = self.selectedView.frame.width / 2
        addSubview(self.selectedView)
    }
}
