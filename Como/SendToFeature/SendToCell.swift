//
//  SendToCell.swift
//  Como
//
//  Created by Songwut Maneefun on 6/4/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol SendToCellDelegate {
    func protocolSendToCell(cell: SendToCell, isSelected:Bool, indexPath: NSIndexPath)
}

@IBDesignable class SendToCell: UITableViewCell {

    
    @IBOutlet weak var storyImageView: CustomImageView!
    @IBOutlet weak var storyName: UILabel!
    @IBOutlet weak var storyDesc: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var view: UIView!
    let nibName: String = "SendToCell"
    var delegate: SettingCellDelegate?
    var indexPath: NSIndexPath!
    
    @IBInspectable var storyImage: UIImage? {
        get {
            return self.storyImageView.image!
        }
        set(image) {
            self.storyImageView?.image = image!
        }
    }
    
    @IBInspectable var title: String? {
        get {
            return self.storyName.text!
        }
        set(title) {
            self.storyName.text? = title!
        }
    }
    
    @IBInspectable var desc: String? {
        get {
            return self.storyDesc.text!
        }
        set(desc) {
            self.storyDesc.text? = desc!
        }
    }
    
    func selected() {
        if isSelected == true {
            self.selectButton.setImage(UIImage(named: "ic_check_green_md"), for: .normal)
        } else {
            self.selectButton.setImage(UIImage(named: "ic_check_empty_md"), for: .normal)
        }
    }
    
    @IBAction func selectButtonPressed(sender: UIButton) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        
        imageView?.layer.cornerRadius = (imageView?.frame.size.height)! / 2
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }
}
