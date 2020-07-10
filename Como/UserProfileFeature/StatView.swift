//
//  StatView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/29/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class StatView: UIView {

    var view: UIView!
    let nibName: String = "StatView"
    
    @IBOutlet weak var momentsTitle: UILabel!
    @IBOutlet weak var viewsTitle: UILabel!
    @IBOutlet weak var likesTitle: UILabel!
    
    @IBOutlet weak var momentsValue: UILabel!
    @IBOutlet weak var viewsValue: UILabel!
    @IBOutlet weak var likesValue: UILabel!
    
    private func createText(value: Int) -> String {
        let string = "\(value)"
        return string
    }
    
    var moments: Int? {
        get {
            return Int(momentsValue.text!)
        }
        set(moments) {
            momentsValue.text = createText(value: moments!)
        }
    }
    
    var views: Int? {
        get {
            return Int(viewsValue.text!)
        }
        set(views) {
            viewsValue.text = createText(value: views!)
        }
    }
    
    var likes: Int? {
        get {
            return Int(likesValue.text!)
        }
        set(likes) {
            likesValue.text = self.createText(value: likes!)
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
