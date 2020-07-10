//
//  FilterCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/18/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

@IBDesignable

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var filterImageView: CustomImageView!
    @IBOutlet weak var filterTitle: UILabel!
    
    var view: UIView!
    let nibName: String = "FilterCell"
    
    var isImageCorner: Bool? {
        didSet {
            if isImageCorner == true {
                self.filterImageView.cornerRadius = self.filterImageView.frame.size.height / 2
            } else {
                self.filterImageView.cornerRadius = 0
            }
            self.filterImageView.clipsToBounds = true
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
