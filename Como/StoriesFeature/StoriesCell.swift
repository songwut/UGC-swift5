//
//  StoriesCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/9/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class StoriesCell: UICollectionViewCell {

    @IBOutlet weak var storiesImageView: CustomImageView!
    @IBOutlet weak var storiesNotify: UIImageView!
    @IBOutlet weak var storiesTitle: UILabel!
    
    var view: UIView!
    let nibName: String = "StoriesCell"
    
    var corner: CGFloat? {
        didSet {
            self.storiesImageView.cornerRadius = corner!
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
