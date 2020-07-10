//
//  HeaderReusableView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/8/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol MyStoryHeaderReusableViewDelegate {
    func protocolMyStoryHeaderReusableViewOpenMyStory()
}

@IBDesignable
class MyStoryHeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var userImageView: CustomImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    var delegate: MyStoryHeaderReusableViewDelegate?
    
    var view: UIView!
    let nibName: String = "MyStoryHeaderReusableView"
    
    func updateImageCorner() {
        self.userImageView.cornerRadius = self.userImageView.frame.size.height / 2
    }
    
    @IBAction func threeDotButtonPressed(sender: UIButton) {
        delegate?.protocolMyStoryHeaderReusableViewOpenMyStory()
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
