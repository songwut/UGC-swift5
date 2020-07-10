//
//  SettingCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/1/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol SettingCellDelegate {
    func protocolSettingCell(cell: SettingCell, didPressedButton:UIButton, indexPath: NSIndexPath)
}

@IBDesignable

class SettingCell: UITableViewCell {

    var view: UIView!
    let nibName: String = "SettingCell"
    var delegate: SettingCellDelegate?
    var indexPath: NSIndexPath!
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    @IBAction func optionButtonPressed(sender: UIButton) {
        delegate?.protocolSettingCell(cell: self, didPressedButton: sender, indexPath: self.indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
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
