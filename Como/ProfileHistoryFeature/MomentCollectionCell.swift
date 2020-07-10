//
//  MomentCollectionCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/8/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol MomentCollectionCellDelegate {
    func protocolMomentCollectionCellDidDownload()
}

@IBDesignable
class MomentCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var momentImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    var delegate: MomentCollectionCellDelegate?
    
    var view: UIView!
    let nibName: String = "MomentCollectionCell"
    
    @IBAction func downloadButtonPressed(sender: UIButton) {
        delegate?.protocolMomentCollectionCellDidDownload()
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
