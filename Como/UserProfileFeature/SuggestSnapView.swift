//
//  SuggestSnapView.swift
//  Como
//
//  Created by Songwut Maneefun on 5/31/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol SuggestSnapViewDelegate {
    func protocolStartSnapButtonPressed(sender: CustomButton)
}

class SuggestSnapView: UIView {

    var view: UIView!
    let nibName: String = "SuggestSnapView"
    var delegate: SuggestSnapViewDelegate?
    
    @IBAction func startSnapButtonPressed(sender: CustomButton) {
        delegate?.protocolStartSnapButtonPressed(sender: sender)
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
