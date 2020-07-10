//
//  LineFeedView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/30/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class LineFeedView: UIView {

    private var verticalGrayLine = UIView(frame: CGRect.zero)
    
    @IBInspectable var lineColor: UIColor? {
        get {
            return verticalGrayLine.backgroundColor
        }
        set(lineColor) {
            verticalGrayLine.backgroundColor = lineColor
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView() {
        self.verticalGrayLine.backgroundColor = UIColor.gray
        addSubview(self.verticalGrayLine);
        self.verticalGrayLine.frame = CGRect(x: (self.frame.size.width / 2) - 0.5, y: 0, width: 1, height: self.frame.size.height)
    }
}
