//
//  FiltersView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/17/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import GPUImage

protocol FiltersViewDelegate {
    func protocolFiltersViewDidSelectedFilter(filter: Filter)
}

@IBDesignable

class FiltersView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var view: UIView!
    let nibName: String = "FiltersView"
    var cellSize: CGSize!
    var miniImage: UIImage!
    let cellId = "FiltersCell"
    private var filteredImages = NSMutableArray()
    var delegate: FiltersViewDelegate?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
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
    
    func reloadFilterList() {
        
        
        let marginV: CGFloat = self.frame.size.height * 0.3
        let cellW = self.frame.size.width / 3.5
        
        //let cellWidth = (view.frame.size.width * 0.8) / cellNumber
        //let marginAll = view.frame.size.width * 0.2
        //let matginOne = marginAll / (cellNumber + 1)
        //let marginLR = matginOne * 2
        //let margin = matginOne * (cellNumber - 1)
        
        
        self.cellSize = CGSize(width: cellW, height: cellW - (marginV / 2))
        let topLayout = (self.frame.size.height - self.cellSize.height) / 2
        self.filterCollectionView!.register(FilterCell.self, forCellWithReuseIdentifier: cellId)
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.showsVerticalScrollIndicator = false
        self.filterCollectionView.isUserInteractionEnabled = true
        self.filterCollectionView.allowsSelection = true
        self.filterCollectionView.backgroundColor = UIColor(white: 1, alpha: 0.0)
        self.filterCollectionView.alpha = 1
        self.scrollView.alpha = 0
        self.filterCollectionView.reloadData()
        self.filterCollectionView.setNeedsLayout()
        self.filterCollectionView.setNeedsDisplay()
        print("CollectionView frame", self.filterCollectionView.frame)
        //self.collectionLayout.sectionInset = UIEdgeInsets(top: 10, left: marginLR / 2, bottom: 10, right: marginLR / 2)
        //self.collectionLayout.itemSize = self.cellSizeSticker
        //self.collectionLayout.minimumInteritemSpacing = margin / cellNumber
        //self.collectionLayout.minimumLineSpacing = margin / cellNumber
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FilterCell
        
        let filter = self.filteredImages[indexPath.row] as! Filter
        cell.filterTitle.text = filter.name
        cell.filterImageView.image = filter.image
        
        let size1 = cell.frame.size.height - cell.filterTitle.frame.size.height
        let imgMargin: CGFloat = 4
        let size2 = cell.frame.size.width - (imgMargin * 2)
        let imgSize = min(size1, size2)
        cell.filterImageView.frame = CGRect(x: (cell.frame.size.width - imgSize) / 2, y: 0, width: imgSize, height: imgSize)
        cell.isImageCorner = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //let cell = collectionView.cellForItemAtIndexPath(indexPath) as! StickerCell
        //let image = UIImage(data: UIImagePNGRepresentation(cell.image)!)
        //self.delegate?.protocolStickerGroupViewDidSelectedStickerImage(image!)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    func processFilterWithImage(image: UIImage) {
        checkImageOrientation(image: image, name: "processFilterMiniImage")
        
        
        
        for filter: Filter in filterNameList {
            let filteredImg = filteredImageWithCIImage(image: image, filterName: filter.ciImageName)
            let filter = Filter(filterName: filter.name, ciImageName: filter.ciImageName, image: filteredImg, tag:filter.tag)
            
            self.filteredImages.add(filter)
            
            if self.filteredImages.count == filterNameList.count {
                self.createFilterScrollView()
                //self.reloadFilterList()
            }
        }
        
//        let filterOp = comoFilterOperations[2] as FilterOperationInterface
//        self.filterProcess(image, filterOperation: filterOp) { (image) in
//            let imgv = UIImageView(frame: CGRect(x: 0, y: 60, width: 300, height: 300))
//            imgv.image = image
//            self.view.addSubview(imgv)
//        }
        
    }
    
    func createFilterScrollView() {
        var svX: CGFloat = 0.0
        
        let svHeight = self.frame.size.height;
        let marginV: CGFloat = self.frame.size.height * 0.2
        let imgMargin: CGFloat = 4
        let cellW = self.frame.size.height * 0.8
        let cellsize = CGSize(width: cellW, height: cellW - (marginV / 2))
        let labelHeight = cellsize.height * 0.2
        
        for i in 0 ..< self.filteredImages.count {
            //let filterOperation: FilterOperationInterface = filters[i]
            let filter = self.filteredImages[i] as! Filter
            
            let cellFrame = CGRect(x: svX, y: (self.frame.size.height - cellsize.height) / 2, width: cellsize.width, height: cellsize.height)
            let cellView = UIView(frame: cellFrame)
            
            let labelFrame = CGRect(x: 0, y: cellView.frame.size.height - labelHeight, width: cellView.frame.size.width, height: labelHeight)
            let label = UILabel(frame: labelFrame)
            label.text = filter.name
            label.font = UIFont.systemFont(ofSize: 12.0)
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
            
            let size1 = cellView.frame.size.height - labelHeight
            let size2 = cellView.frame.size.width - (imgMargin * 2)
            let imgSize = min(size1, size2)
            let imageView = CustomImageView(frame: CGRect(x: (cellView.frame.size.width - imgSize) / 2, y: 0, width: imgSize, height: imgSize))
            imageView.cornerRadius = imgSize / 2
            imageView.isUserInteractionEnabled = true
            imageView.tag = filter.tag!
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = filter.image
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.filterTapped(_:)))
            imageView.addGestureRecognizer(tap)
            //imageView.image = self.filteredImages[i] as? UIImage
            cellView.addSubview(label)
            cellView.addSubview(imageView)
            
            svX = svX + cellView.frame.size.width
            
            self.scrollView.addSubview(cellView)
        }
        
        let contentwidth = cellsize.width * CGFloat(self.filteredImages.count)
        self.scrollView.contentSize = CGSize(width: contentwidth, height: svHeight)
    }
    
    @objc func filterTapped(_ recognizer: UITapGestureRecognizer) {
        let imageView = recognizer.view as! UIImageView
        let filter = self.filteredImages[indexFromTag(tag: imageView.tag)] as! Filter
        self.delegate?.protocolFiltersViewDidSelectedFilter(filter: filter)
    }

}
