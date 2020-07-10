//
//  CaptionView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/22/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@objc protocol CaptionViewDelegate {
    @objc optional
    func protocolCaptionViewDidActiveEditing(_ captionView: CaptionView)
    func protocolCaptionViewDidBeginEditing(_ captionView: CaptionView)
    func protocolCaptionViewDidEndEditing(_ captionView: CaptionView)
    func protocolCaptionViewDidCancelEditing(_ captionView: CaptionView)
    func protocolCaptionViewDidMove(_ captionView: CaptionView, position: CGPoint)
    func protocolCaptionViewDidChangeFrame(_ captionView: CaptionView, frame: CGRect)
    //func protocolCaptionViewDidClose(CaptionView: CaptionView)
}

class CaptionView: UIView {

    var delegate: CaptionViewDelegate?
    var isFlipHor = false
    var isMoveHor = false
    var isMoveVer = true
    var contentView = UIView()
    
    var textView = UITextView()
    private var minWidth: CGFloat = 0.0
    private var minHeight: CGFloat = 0.0
    private let padding: CGFloat = 5.0
    private let kSPUserResizableViewDefaultMinWidth: CGFloat = 48.0
    private let kSPUserResizableViewInteractiveBorderSize: CGFloat = 10.0
    private let kZDStickerViewControlSize: CGFloat = 36.0
    private let SHADOW_SIZE = CGSize(width: 0.5, height: 0.5)
    private var preventsPositionOutsideSuperview = false
    private var touchStart: CGPoint!
    
    var text: String? {
        didSet {
            self.textView.text = text
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    setNeedsDisplay()
        for touch in touches {
            touchStart = touch.location(in: self.superview)
            print("caption touchStart", touchStart as Any)
            self.delegate?.protocolCaptionViewDidBeginEditing(self)
        }
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    setNeedsDisplay()
        self.delegate?.protocolCaptionViewDidEndEditing(self)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    super.touchesCancelled(touches!, with: event)
    
    setNeedsDisplay()
        self.delegate?.protocolCaptionViewDidCancelEditing(self)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    setNeedsDisplay()
        for touch in touches {
            let touchPoint = touch.location(in: self.superview)
            self.delegate!.protocolCaptionViewDidMove(self, position: touchPoint)
            self.translateUsingTouchLocation(touchPoint: touchPoint)
            touchStart = touchPoint;
        }
    }
    
    func translateUsingTouchLocation(touchPoint: CGPoint) {
        var newCenter = CGPoint(x: self.center.x,
                                y: self.center.y + touchPoint.y - touchStart.y);
        if (self.preventsPositionOutsideSuperview) {
            let midPointX = self.bounds.midX;
            if (newCenter.x > self.superview!.bounds.size.width - midPointX) {
                newCenter.x = self.superview!.bounds.size.width - midPointX;
            }
            if (newCenter.x < midPointX) {
                newCenter.x = midPointX;
            }
            let midPointY = self.bounds.midY;
            if (newCenter.y > self.superview!.bounds.size.height - midPointY) {
                newCenter.y = self.superview!.bounds.size.height - midPointY;
            }
            if (newCenter.y < midPointY) {
                newCenter.y = midPointY;
            }
        }
        
        if self.isMoveHor == true && self.isMoveVer == true {
            self.center = newCenter
            print("isMove all")
            
        } else if self.isMoveHor == true {
            self.center = CGPoint(x: newCenter.x, y: self.center.y)
            print("isMoveHor")
            
        } else if self.isMoveVer == true {
            self.center = CGPoint(x: self.center.x, y: newCenter.y)
            print("isMoveHor")
        }
        
        self.delegate?.protocolCaptionViewDidChangeFrame(self, frame: self.frame)
    }
    
    func removeWithAnimate(animate: Bool) {
        if animate == true {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = self.transform.scaledBy(x: 0.3, y: 0.3)
                self.alpha = 0
            }) { (done) in
                self.removeFromSuperview()
            }
        } else {
            self.removeFromSuperview()
        }
        
    }
    
    func setTextView() {
        
        //[self.textView setTextContainerInset:UIEdgeInsetsMake(0, 12, 0, 12)];
        let textViewFrame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.textView = UITextView(frame: textViewFrame)
        self.textView.font = UIFont.systemFont(ofSize: 20)
        self.textView.minimumZoomScale = 0.4
        self.textView.textAlignment = .center
        self.textView.textColor = UIColor.white
        self.textView.backgroundColor = UIColor.clear
        self.textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        self.textView.isUserInteractionEnabled = false
        
        contentView.removeFromSuperview()
        contentView = self.textView
        contentView.frame = textViewFrame
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
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
        if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width * 0.5) {
            self.minWidth = kSPUserResizableViewDefaultMinWidth;
            self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
        } else {
            self.minWidth = self.bounds.size.width * 0.5;
            self.minHeight = self.bounds.size.height * 0.5;
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.contentTapped(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func contentTapped(_ recognizer: UITapGestureRecognizer) {
        delegate!.protocolCaptionViewDidActiveEditing!(self)
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && gestureRecognizer.isKind(of: UITapGestureRecognizer.self)
    }

}
