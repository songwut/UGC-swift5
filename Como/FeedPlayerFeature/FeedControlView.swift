//
//  FeedControlView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/9/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol FeedControlViewDelegate {
    func protocolFeedControlViewDidShowControlView()
}

@IBDesignable

class FeedControlView: UIView {

    var view: UIView!
    let nibName: String = "FeedControlView"
    
    @IBOutlet weak var userImageView: CustomImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var downButton: UIButton!
    
    var delegate: FeedControlViewDelegate?
    
    @IBAction func upButtonPressed(sender: UIButton) {
        sender.alpha = 0
        delegate?.protocolFeedControlViewDidShowControlView()
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
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }

}
