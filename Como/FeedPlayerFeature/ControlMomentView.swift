//
//  ControlMomentView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/9/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol ControlMomentViewDelegate {
    func protocolControlMomentViewDidHideControlView()
    func protocolControlMomentViewDidDownload()
}

@IBDesignable

class ControlMomentView: UIView {

    var view: UIView!
    let nibName: String = "ControlMomentView"
    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
//    @IBOutlet weak var downloadButton: UIButton!
//    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: ControlMomentViewDelegate?
    
    var views: Int? {
        get {
            return Int(viewsLabel.text!)
        }
        set(views) {
            viewsLabel.text = createText(value: views!)
        }
    }
    
    var likes: Int? {
        get {
            return Int(likesLabel.text!)
        }
        set(likes) {
            likesLabel.text = self.createText(value: likes!)
        }
    }
    
    @IBAction func deleteButtonPressed(sender: CustomButton) {
        delegate?.protocolControlMomentViewDidHideControlView()
    }
    
    @IBAction func downloadButtonPressed(sender: UIButton) {
        delegate?.protocolControlMomentViewDidHideControlView()
    }
    
    private func createText(value: Int) -> String {
        let string = "\(value)"
        return string
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
        
        view.backgroundColor = UIColor.clear
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        let colorStart = UIColor(white: 0, alpha: 0.0)
        let colorEnd = UIColor(white: 0, alpha: 0.3)
        gradient.colors = [colorStart.cgColor, colorEnd.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }

}
