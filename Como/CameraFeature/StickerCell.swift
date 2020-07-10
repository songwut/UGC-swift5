//
//  StickerCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/15/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class StickerCell: UICollectionViewCell {

    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var view: UIView!
    let nibName: String = "StickerCell"
    
    var image: UIImage! {
        didSet {
            self.imageView.image = image!
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
