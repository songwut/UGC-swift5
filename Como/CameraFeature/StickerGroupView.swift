//
//  StickerGroupView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol StickerGroupViewDelegate {
    func protocolStickerGroupViewDidSelectedStickerImage(image: UIImage)
}

class StickerGroupView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var view: UIView!
    let nibName: String = "StickerGroupView"
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    var delegate: StickerGroupViewDelegate?
    
    var Id: Int!
    var name: String!
    var stickers: NSMutableArray!
    
    var stickerCollections = NSMutableArray()
    var cellSizeSticker: CGSize!
    var cellSizeEmoji: CGSize!
    
    func setStickerList(sticker: NSMutableArray, name: String) {
        self.stickers = sticker
        self.name = name
        var cellNumber: CGFloat = 4
        if name == "EMOJI" {
            cellNumber = 5
        }
        let cellWidth = (view.frame.size.width * 0.8) / cellNumber
        let marginAll = view.frame.size.width * 0.2
        let matginOne = marginAll / (cellNumber + 1)
        let marginLR = matginOne * 2
        let margin = matginOne * (cellNumber - 1)
        
        
        self.cellSizeSticker = CGSize(width: cellWidth, height: cellWidth)
        self.stickerCollectionView!.register(StickerCell.self, forCellWithReuseIdentifier: name)
        self.stickerCollectionView.delegate = self
        self.stickerCollectionView.dataSource = self
        self.stickerCollectionView.showsVerticalScrollIndicator = false
        self.stickerCollectionView.isUserInteractionEnabled = true
        self.stickerCollectionView.allowsSelection = true
        self.stickerCollectionView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        
        self.layout.sectionInset = UIEdgeInsets(top: 10, left: marginLR / 2, bottom: 10, right: marginLR / 2)
        self.layout.itemSize = self.cellSizeSticker
        self.layout.minimumInteritemSpacing = margin / cellNumber
        self.layout.minimumLineSpacing = margin / cellNumber
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as! StickerCell
        
        let sticker = self.stickers[indexPath.item] as! Sticker
        cell.imageView.setImage(sticker.image, placeholderImage: UIImage(named: "thumb_setup_user_borderless"))

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let stickerCell = cell as? StickerCell {
            let image = UIImage(data: stickerCell.image.pngData()!)
            self.delegate?.protocolStickerGroupViewDidSelectedStickerImage(image: image!)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSizeSticker
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
