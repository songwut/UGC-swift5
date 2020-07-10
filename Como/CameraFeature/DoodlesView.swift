//
//  DoodlesView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/20/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class DoodlesView: UIView, UIScrollViewDelegate {

    var view: UIView!
    let nibName: String = "DoodlesView"
    var isEdited = false
    var selectedDoodleImage:UIImage!
    var doodles = NSMutableArray()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func layoutSubviews() {
        //other element
    }
    
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
    
    func populateDoodles(doodles: NSMutableArray) {
        self.doodles = doodles
        var svX: CGFloat = 0.0
        let svHeight = self.frame.size.height;
        let cellsize = CGSize(width: self.frame.size.width,height: self.frame.size.height)
        print("populateDoodles cellsize", cellsize)
        for i in 0 ..< doodles.count {
            let doodle = doodles[i] as! Doodle
            
            let cellFrame = CGRect(x: svX, y: 0, width: cellsize.width, height: cellsize.height)
            let cellView = UIView(frame: cellFrame)
            let imageView = UIImageView(frame: cellFrame)
            imageView.tag = i + 1
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            if (doodle.image != nil)  {
                imageView.image = self.imageWithDoodle(doodle: doodle, screenSize: cellsize)
            } else {
                imageView.setImage(doodle.imageStr, placeholderImage: nil) { (image) in
                    imageView.image = self.imageWithDoodleImage(doodle: doodle, image: image, screenSize: cellsize)
                }

            }
            
            imageView.backgroundColor = UIColor.clear
            //let tap = UITapGestureRecognizer(target: self, action: #selector(self.filterTapped(_:)))
            //imageView.addGestureRecognizer(tap)
            
            svX = svX + cellView.frame.size.width
            
            self.scrollView.addSubview(imageView)
        }
        
        let contentwidth = cellsize.width * CGFloat(doodles.count)
        self.scrollView.contentSize = CGSize(width: contentwidth, height: svHeight)
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
        self.isUserInteractionEnabled = true
    }
    
    func imageWithDoodleImage(doodle: Doodle, image:UIImage, screenSize: CGSize) -> UIImage {
        print("image", image)
        let minSize = min(screenSize.width, screenSize.height) * 0.9
        
        let size = CGSize(width: minSize, height: minSize);
        let newImage = RBResizeImage(image: image, targetSize: size)
        UIGraphicsBeginImageContextWithOptions(screenSize, false, 0.0);
        print("minSize", minSize)
        var drawFrame: CGRect
        if doodle.isFullScreen == true {
            drawFrame = CGRect(x: (screenSize.width - minSize) / 2, y: (screenSize.height - minSize) / 2 ,width: minSize, height: minSize)
            print("drawFrame", drawFrame)
        } else {
            let dSize = screenSize.width * 0.9
            drawFrame = CGRect(x: (screenSize.width - dSize) / 2, y: screenSize.height - dSize ,width: dSize, height: dSize)
        }
        
        newImage.draw(in: drawFrame)
        
        let completeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return completeImage
        
    }
    
    func imageWithDoodle(doodle: Doodle, screenSize: CGSize) -> UIImage {
        let image = doodle.image
        let size = CGSize(width: screenSize.width, height: screenSize.height);
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        
        var drawFrame: CGRect
        if doodle.isFullScreen == true {
            drawFrame = CGRect(x: 0, y: 0 ,width: screenSize.width, height: screenSize.height)
        } else {
            let dSize = screenSize.width * 0.9
            drawFrame = CGRect(x: (screenSize.width - dSize) / 2, y: screenSize.height - dSize ,width: dSize, height: dSize)
        }
        
        image!.draw(in: drawFrame)
        
        let completeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        return completeImage
        
    }
//    func mergeImageWithDrawAndStickers(sourceImage mainImage: UIImage, drawImage: UIImage, stickersView: UIView, success: (UIImage?) -> (UIImage)) {
//        let callerQueue = dispatch_get_main_queue()
//        let processQueue = dispatch_queue_create("mergeImageWithDraw", nil)
//        dispatch_async(processQueue) {
//            let size = CGSize(mainImage.size.width, mainImage.size.height);
//            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
//            //1. main image
//            mainImage.drawInRect(CGRectMake(0,0,size.width, size.height))
//            
//            //complete
//            let completeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext();
//            dispatch_async(callerQueue, {
//                success(completeImage)
//            })
//        }
//    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexOfPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        switch indexOfPage {
        case 0:
            self.isEdited = false
        default:
            self.isEdited = true
            self.selectedDoodleImage = self.imageInPage(pageIndex: Int(indexOfPage))!
            print("selectedDoodleImage", self.selectedDoodleImage as Any)
        }
        print("doodle scroll indexOfPage", indexOfPage,"isEdit", self.isEdited)
    }
    
    func imageInPage(pageIndex: Int) -> UIImage? {
        let doodleTag = pageIndex + 1
        for view in self.scrollView.subviews {
            let imageView = view as! UIImageView
            if imageView.tag == doodleTag && imageView.image != nil {
                return imageView.image!
            }
        }
        return nil
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
}
