//
//  MomemtCell.swift
//  Como
//
//  Created by Songwut Maneefun on 5/28/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class MomemtCell: UICollectionViewCell {
    var view: UIView!
    let nibName: String = "MomentCell"
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    private func createText(value: Int) -> String {
        let string = "\(value)"
        return string
    }
    
    var day: Int? {
        get {
            return Int(self.dayLabel.text!)
        }
        set(day) {
            self.dayLabel?.text = self.createText(value: day!)
            setUpView()
        }
    }
    
    var month: String? {
        get {
            return self.monthLabel.text!
        }
        set(month) {
            self.monthLabel?.text = month!
            setUpView()
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
