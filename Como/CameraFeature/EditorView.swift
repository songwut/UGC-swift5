//
//  StickerView.swift
//  Como
//
//  Created by Songwut Maneefun on 6/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

protocol EditorViewDelegate {
    func protocolEditorViewDidClose()
    func protocolEditorViewDidBack()
    func protocolEditorViewDidSubmit(file: AnyObject)
    func protocolEditorViewDidSave(file: AnyObject)
    func protocolEditorViewFilterViewDidShow(show: Bool)
    //func protocolEditorViewDidMixStickers(view: UIView)
}

@IBDesignable

class EditorView: UIView, UIGestureRecognizerDelegate {
    
    var delegate: EditorViewDelegate?
    
    @IBOutlet weak var stickerTapControl: UISegmentedControl!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var stickerScrollView: UIScrollView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var captionsView: UIView!
    @IBOutlet weak var stickersView: UIView!
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var doodlesView: DoodlesView!
    
    var colorPicker: SWColorPicker!
    
    var imageSource: UIImage!
    var mediaUrlSource: URL!
    var mediaType: String!
    
    var captionView: StickerView!
    var captionTextView: UITextView!
    var captionFrame: CGRect!
    
    var isShowEditor: Bool = false
    var stickerTag = 1
    
    var view: UIView!
    let nibName: String = "EditorView"
    
    var isRemove: Bool = false
    private var binButton: UIButton!
    private let iconBack = UIImage(named: "ic_back")
    private let iconClose = UIImage(named: "ic_close_wh")
    
    func setStickers(stickers: NSMutableArray) {
        self.binButton.frame = CGRect(x: self.frame.size.width - (44 + 8), y: 8, width: 44, height: 44)
        self.binButton.alpha = 0
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        
        if stickers.count > 0 {
            self.stickerTapControl.selectedSegmentIndex = 0
            var svX: CGFloat = 0.0
            let labelHeight: CGFloat = 30;
            let svWidth = self.stickerScrollView.frame.size.width;
            let svHeight = self.stickerScrollView.frame.size.height - labelHeight;
            
            for group in stickers {
                let stickerGroup = group as! StickerGroup
                let labelFrame = CGRect(x: svX, y: 0, width: svWidth, height: labelHeight)
                let scFrame = CGRect(x: svX, y: labelHeight, width: svWidth, height: svHeight)
                let groupLabel = UILabel(frame: labelFrame)
                groupLabel.text = stickerGroup.groupName
                groupLabel.textAlignment = .center
                
                let stickerGroupView = StickerGroupView(frame: scFrame)
                stickerGroupView.setStickerList(sticker: stickerGroup.groupList, name: stickerGroup.groupName)
                stickerGroupView.delegate = self
                stickerGroupView.backgroundColor = UIColor.clear
                svX = svX + svWidth
                self.stickerScrollView.addSubview(groupLabel)
                self.stickerScrollView.addSubview(stickerGroupView)
            }
            
            let contentwidth = view.frame.size.width * CGFloat(stickers.count)
            self.stickerScrollView.contentSize = CGSize(width: contentwidth, height: labelHeight + svHeight)
        }
        
    }
    
    @IBAction func stickerTapControlValueChanged(sender: UISegmentedControl) {
        print("sender.selectedSegmentIndex",sender.selectedSegmentIndex)
        //        switch sender.selectedSegmentIndex {
        //        case 1:
        //            self.view.backgroundColor = UIColor.greenColor()
        //        case 2:
        //            self.view.backgroundColor = UIColor.blueColor()
        //        default:
        //            self.view.backgroundColor = UIColor.purpleColor()
        //        }
    }
    
    func animatebin(animate: Bool) {
        if animate {
            self.isRemove = true
            UIView.animate(withDuration: 0.2) {
                self.binButton.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }
            
        } else {
            self.isRemove = false
            UIView.animate(withDuration: 0.1) {
                self.binButton.transform = CGAffineTransform.identity
            }
        }
    }
    
    func protocolStickerViewDidCancelEditing(stickerView: StickerView) {
        
        self.setEditorToolAlpha(alpha: 1)
        self.binButton.alpha = 0
        print("Cancel")
    }
    
    func protocolStickerViewDidLongPressed(stickerView: StickerView) {
        print("LongPressed")
    }
    
    func setEditorToolAlpha(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.closeButton.alpha = alpha;
            self.submitButton.alpha = alpha;
            self.stickerButton.alpha = alpha;
            self.textButton.alpha = alpha;
            self.filterButton.alpha = alpha;
            self.drawButton.alpha = alpha;
        }
    }
    
    func realFrameWithFrame(stickerContentFramr frame: CGRect, realSize: CGSize, displayFrame: CGRect) -> CGRect {
        var realFrame: CGRect
        // Fine Percent between realImage virtualImageFrame
        // (can use both width or height it result same)
        let realHeight = realSize.height;
        let heightCutOut  = (realHeight - displayFrame.size.height);
        let percentCutOut = (heightCutOut / displayFrame.size.height) * 100;
        print("percentCutOut: ",percentCutOut);
        
        // SET New Frame For Crop frame
        let plusWidth = (frame.size.width * percentCutOut) / 100;
        let newWidth = frame.size.width + plusWidth;
        
        let plusHeight = (frame.size.height * percentCutOut) / 100;
        let newHeight = frame.size.height + plusHeight;
        
        let plusOriginX = (frame.origin.x * percentCutOut) / 100;
        var newOriginX = frame.origin.x + plusOriginX;
        
        let plusOriginY = (frame.origin.y * percentCutOut) / 100;
        var newOriginY = frame.origin.y + plusOriginY;
        
        //fix position if stickerMixview small than self.view
        if(frame.origin.x < 0 || frame.origin.x > 0 ){
            //fix X Horizontal position
            let plusMarginX = (displayFrame.origin.x * percentCutOut) / 100;
            let realMarginX = displayFrame.origin.x + plusMarginX;
            newOriginX = newOriginX - realMarginX;
        }
        
        if(frame.origin.y < 0 || frame.origin.y > 0){
            //fix Y Vertical position
            let plusMarginY = (displayFrame.origin.y * percentCutOut) / 100;
            let realMarginY = displayFrame.origin.y + plusMarginY;
            newOriginY = newOriginY - realMarginY;
        }
        realFrame = CGRect(x: newOriginX, y: newOriginY, width: newWidth, height: newHeight);
        
        return realFrame;
    }
    
    func degreesWithRadians(radians: Float) -> Float {
        return radians * (180.0 / Float(CGFloat.pi))
    }
    
    func imageRotate(stickerView: StickerView) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: stickerView.frame.size.width, height: stickerView.frame.size.height))
        let imageViewAngle = stickerView.value(forKeyPath: "layer.transform.rotation.z") as! Float
        //let imageViewAngle: CGFloat = [(NSNumber *)[contentView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        print("imageViewAngle: %f",imageViewAngle);
        print("imageViewdegrees: %f",self.degreesWithRadians(radians: imageViewAngle))
        let t = CGAffineTransform(rotationAngle: CGFloat(imageViewAngle));
        rotatedViewBox.transform = t;
        let rotatedSize = rotatedViewBox.frame.size;
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize);
        let bitmap = UIGraphicsGetCurrentContext();
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap!.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2);
        
        //   // Rotate the image context
        bitmap!.rotate(by: CGFloat(imageViewAngle));
        
        // Now, draw the rotated/scaled image into the context
        //UIImageView *imageView = (UIImageView *) [[contentView subviews] objectAtIndex:0];
        //กลับหัวภาพ
        if(stickerView.isFlipHor){
            // is Flip Horizontal
            bitmap!.scaleBy(x: -1.0, y: -1.0);
        }else{
            // is No Flip
            bitmap!.scaleBy(x: 1.0, y: -1.0);
        }
        
        
        let stickerSize = CGSize(width: stickerView.frame.size.width, height: stickerView.frame.size.height);
        let imageRect = CGRect(x: -(stickerSize.width / 2), y: -(stickerSize.height / 2), width: stickerView.frame.size.width, height: stickerView.frame.size.height)
        
        if stickerView.contentView.isKind(of: UIImageView.self) {
            print("is imageView");
            let imageView = stickerView.contentView as! UIImageView
            if let image = imageView.image?.cgImage {
                bitmap?.draw(image, in: imageRect)
            }
            
        } else if stickerView.contentView.isKind(of: UITextView.self) {
            print("is UITextView");
            let textView = stickerView.contentView as! UITextView
            if let cgStk = self.drawImageWithTextView(textView: textView).cgImage {
                bitmap?.draw(cgStk, in: imageRect)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!;
    }
    
    func imageRotateWithTextViewSticker(stickerView: StickerView) -> UIImage {
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: stickerView.frame.size.width, height: stickerView.frame.size.height))
        let imageViewAngle = stickerView.value(forKeyPath: "layer.transform.rotation.z") as! Float
        let t = CGAffineTransform(rotationAngle: CGFloat(imageViewAngle));
        rotatedViewBox.transform = t;
        let rotatedSize = rotatedViewBox.frame.size;
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize);
        let bitmap = UIGraphicsGetCurrentContext();
        bitmap?.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
        bitmap?.rotate(by: CGFloat(imageViewAngle))
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        
        let stickerSize = CGSize(width: stickerView.frame.size.width, height: stickerView.frame.size.height);
        let imageRect = CGRect(x: -(stickerSize.width / 2), y: -(stickerSize.height / 2), width: stickerView.frame.size.width, height: stickerView.frame.size.height)
        
        let textView = self.captionView.contentView as! UITextView
        if let cgText = self.drawImageWithTextView(textView: textView).cgImage {
            bitmap?.draw(cgText, in: imageRect)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!;
    }
    
    func drawFillCaptionSize(size: CGSize, fillColor: UIColor!) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        //TODO:  convert content rect
        context?.setFillColor(fillColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        context?.setLineWidth(0)
        
        context?.addRect(rectangle)
        context?.drawPath(using: .fillStroke)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!;
    }
    
    func drawImageWithTextView(textView: UITextView) -> UIImage {
        let size = CGSize(width: textView.frame.size.width, height: textView.frame.size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        textView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func countSubview(view: UIView) -> Int {
        return view.subviews.count
    }
    
    func hideEditor() {
        self.isShowEditor = false
        self.blurView.alpha = 0
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        self.submitButton.alpha = 1
        self.closeButton.setImage(self.iconClose, for: .normal)
    }
    
    @IBAction func downloadButtonPressed(sender: UIButton) {
        switch self.mediaType {
        case Medias.image:
            self.imageMerged(sourceImage: imageFilteredOutPut, stickersView: self.stickersView, success: { (image) in
                self.delegate!.protocolEditorViewDidSave(file: image!)
            })
        break
        case Medias.video:
            //TODO edit video
            self.delegate!.protocolEditorViewDidSave(file: self.mediaUrlSource as AnyObject)
        break
        default:
            break
        }
        
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        if self.isShowEditor == true {
            self.hideEditor()
            self.doodlesView.isUserInteractionEnabled = true
            self.showcolorPicker(show: false)
            self.delegate!.protocolEditorViewDidBack()
        } else {
            self.delegate!.protocolEditorViewDidClose()
        }
    }
    
    @IBAction func submitButtonPressed(sender: UIButton) {
        print("frame: ", self.stickersView.frame)
        self.imageMerged(sourceImage: imageFilteredOutPut,
                         stickersView: self.stickersView,
            success: { (image) in
                self.delegate!.protocolEditorViewDidSubmit(file: image!)
        })
    }
    
    func imageMerged(sourceImage mainImage: UIImage, stickersView: UIView, success: @escaping (UIImage?) -> ()) {
        let callerQueue = DispatchQueue.main
        let processQueue = DispatchQueue(label: "mergeImageWithDraw")
        processQueue.async {
            let size = CGSize(width: mainImage.size.width, height: mainImage.size.height);
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
            //1. main image
            mainImage.draw(in: CGRect(x: 0,y: 0,width: size.width, height: size.height))
            
            //2. draw image
            if self.drawView.isEdited == true {
                let drawImage = self.drawView.mainImageView.image
                drawImage!.draw(in: CGRect(x: 0,y: 0,width: size.width, height: size.height))
            }
            
            //3. stickers
            for view in stickersView.subviews {
                print("stickerView tag:\(view.tag) view: \(view)")
                let stickerView = view as! StickerView
                let rectContent = stickersView.convert(stickerView.contentView.frame, from: view)
                let rectOnScreen = self.convert(rectContent, from: stickersView)
                print("rectOnScreen", rectOnScreen)
                let imageSticker = self.imageRotate(stickerView: stickerView)
                let drawFrame = self.realFrameWithFrame(stickerContentFramr: rectOnScreen, realSize: self.imageSource.size, displayFrame: self.frame)
                imageSticker.draw(in: drawFrame)
            }
            
            //5. doodle
            if self.doodlesView.isEdited == true {
                let doodleImage = self.doodlesView.selectedDoodleImage
                doodleImage!.draw(in: CGRect(x: 0,y: 0,width: size.width, height: size.height))
            }
            
            //6. caption
            if self.captionView != nil {
                self.drawFillCaptionView(stickerView: self.captionView, mainView: self.view)
                self.drawCaptionView(stickerView: self.captionView, mainView: self.view)
            }
            
            //complete
            let completeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            callerQueue.async {
                success(completeImage)
            }
        }
    }
    
    func drawCaptionView(stickerView: StickerView, mainView: UIView) {
        let rectContent = mainView.convert(stickerView.contentView.frame, from: stickerView)
        let rectOnScreen = self.convert(rectContent, from: mainView)
        print("caption rectOnScreen", rectOnScreen)
        let drawFrame = self.realFrameWithFrame(stickerContentFramr: rectOnScreen, realSize: self.imageSource.size, displayFrame: self.frame)
        let imageCaption = self.imageRotateWithTextViewSticker(stickerView: self.captionView)
        imageCaption.draw(in: drawFrame)
    }
    
    func drawFillCaptionView(stickerView: StickerView, mainView: UIView) {
        let rectOnScreen = self.convert(stickerView.frame, from: mainView)
        print("fill captionrectOnScreen", rectOnScreen)
        let drawFrame = self.realFrameWithFrame(stickerContentFramr: rectOnScreen, realSize: self.imageSource.size, displayFrame: self.frame)
        let fillImage = self.drawFillCaptionSize(size: self.captionView.frame.size, fillColor:self.captionView.backgroundColor)
        
        fillImage.draw(in: drawFrame)
    }
    
    @IBAction func drawButtonPressed(sender: UIButton) {
        self.isShowEditor = true
        self.closeButton.setImage(self.iconBack, for: .normal)
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        self.submitButton.alpha = 0
        self.stickersView.alpha = 1
        self.stickersView.isUserInteractionEnabled = false
        self.blurView.alpha = 0
        self.drawView.alpha = 1
        self.drawView.isUserInteractionEnabled = true
        self.doodlesView.isUserInteractionEnabled = false
        
        self.showcolorPicker(show: true)
        self.delegate!.protocolEditorViewFilterViewDidShow(show: false)
    }
    
    func showcolorPicker(show: Bool) {
        let colorPickerFrame = CGRect(x: self.frame.size.width - 20, y: 50, width: 25, height: self.frame.size.height * 0.6)
        if self.colorPicker == nil {
            self.colorPicker = SWColorPicker(frame: colorPickerFrame)
            self.colorPicker.delegate = self
            self.addSubview(self.colorPicker)
        }
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            if show == true {
                self.colorPicker.alpha = 1
                self.colorPicker.frame = colorPickerFrame
            } else {
                self.colorPicker.alpha = 0
                self.colorPicker.frame.origin.x = self.frame.size.width
            }
        }) { (done) in
            
        }
    }
    
    @IBAction func filterButtonPressed(sender: UIButton) {
        self.isShowEditor = true
        self.closeButton.setImage(self.iconBack, for: .normal)
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        self.submitButton.alpha = 0
        self.stickersView.alpha = 1
        self.stickersView.isUserInteractionEnabled = true
        self.blurView.alpha = 0
        self.drawView.alpha = 1
        self.drawView.isUserInteractionEnabled = false
        self.doodlesView.isUserInteractionEnabled = true
        
        self.showcolorPicker(show: false)
        self.delegate!.protocolEditorViewFilterViewDidShow(show: true)
    }
    
    @IBAction func textButtonPressed(sender: UIButton) {
        self.isShowEditor = true
        self.closeButton.setImage(self.iconBack, for: .normal)
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        self.submitButton.alpha = 0
        self.stickersView.alpha = 1
        self.stickersView.isUserInteractionEnabled = false
        self.blurView.alpha = 0
        self.drawView.alpha = 1
        self.drawView.isUserInteractionEnabled = false
        self.doodlesView.isUserInteractionEnabled = true
        self.createCaptionView()
        self.showcolorPicker(show: false)
        self.delegate!.protocolEditorViewFilterViewDidShow(show: false)
    }
    
    func createCaptionView() {
        
        self.captionTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 60))
        self.captionTextView.font = UIFont.systemFont(ofSize: 20)
        self.captionTextView.minimumZoomScale = 0.4
        self.captionTextView.textAlignment = .center
        self.captionTextView.textColor = UIColor.white
        self.captionTextView.backgroundColor = UIColor.clear
        self.captionTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.captionTextView.becomeFirstResponder()
        self.captionTextView.isUserInteractionEnabled = true
        
        let captionFrame = CGRect(x: 0, y: (self.frame.size.height - 100) / 2, width: self.frame.size.width, height: 60)
        self.captionView = StickerView(frame: captionFrame)
        self.captionView.setSticker(view: self.captionTextView)
        self.captionView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        self.captionView.isMoveHor = false
        self.captionView.delegate = self
        self.doodlesView.addSubview(self.captionView)
        
//        let captionView = CaptionView(frame: captionFrame)
//        captionView.setTextView()
//        captionView.delegate = self
//        self.selectedTextView = captionView.textView
//        self.doodlesView.addSubview(captionView)
        
        
    }
    
    @IBAction func stickerButtonPressed(sender: UIButton) {
        self.isShowEditor = true
        self.closeButton.setImage(self.iconBack, for: .normal)
        self.blurView.alpha = 1
        self.stickerScrollView.alpha = 1
        self.stickerTapControl.alpha = 1
        self.submitButton.alpha = 0
        self.stickersView.alpha = 0
        self.stickersView.isUserInteractionEnabled = true
        self.drawView.alpha = 0
        self.drawView.isUserInteractionEnabled = false
        self.doodlesView.alpha = 0
        self.doodlesView.isUserInteractionEnabled = false
        self.showcolorPicker(show: false)
        self.delegate!.protocolEditorViewFilterViewDidShow(show: false)
    }
    
    func manageCloseButton() {
        if Bool(self.isShowEditor) {
            self.closeButton.setImage(self.iconBack, for: .normal)
        } else {
            self.closeButton.setImage(self.iconBack, for: .normal)
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
        
        self.stickerTapControl.alpha = 0
        
        self.binButton = UIButton(type: .custom)
        self.binButton.setImage(UIImage(named: "icon_bin_close"), for: .normal)
        self.binButton.frame = CGRect(x: self.frame.size.width - (44 + 8), y: 8, width: 44, height: 44)
        self.binButton.alpha = 0
        self.binButton.addTarget(self, action: #selector(self.binButtonDragEnter), for: .touchDragEnter)
        self.binButton.addTarget(self, action: #selector(self.binButtonPressed), for: .touchUpInside)
        self.addSubview(self.binButton)
        
        
        let doodlesViewTap = UITapGestureRecognizer(target: self, action: #selector(self.doodlesViewTapped(_:)))
        self.doodlesView.addGestureRecognizer(doodlesViewTap)
    }
    
    @objc func doodlesViewTapped(_ recognizer: UITapGestureRecognizer) {
        //TODO remove keyboard
        if self.captionTextView != nil {
            self.captionTextView.resignFirstResponder()
            self.captionTextView.isUserInteractionEnabled = false
        }
        
        self.delegate!.protocolEditorViewFilterViewDidShow(show: false)
        print("captionViewsTapped")
    }
    
    @objc func binButtonDragEnter() {
        print("binButtonDragEnter")
    }
    
    @objc func binButtonPressed() {
        print("binButtonPressed")
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.className, bundle: bundle)
        let view = nib.instantiate(withOwner: self ,options: nil)[0] as! UIView
        return view
    }

}

extension EditorView : SWColorPickerDelegate {
    func protocolSWColorPickerSelectedColor(color: UIColor) {
        self.drawView.settingColor(color: color)
    }
}

extension EditorView : StickerGroupViewDelegate {
    func protocolStickerGroupViewDidSelectedStickerImage(image: UIImage) {
        
        let stickerFrame = CGRect(x: (self.stickersView.frame.size.width - 100) / 2,
                                  y: (self.stickersView.frame.size.height - 100) / 2,
                                  width: 100, height: 100)
        let stickerImageview = UIImageView(image: image)
        stickerImageview.frame = CGRect(x: 0, y: 0, width: stickerFrame.size.width, height: stickerFrame.size.height)
        
        let stickerView = StickerView(frame: stickerFrame)
        stickerView.setSticker(view: stickerImageview)
        stickerView.tag = stickerTag
        stickerView.delegate = self
        self.stickersView.addSubview(stickerView)
        
        self.stickerTag += 1
        
        self.blurView.alpha = 0
        self.stickerScrollView.alpha = 0
        self.stickerTapControl.alpha = 0
        self.stickersView.alpha = 1
        self.drawView.alpha = 1
        self.drawView.isUserInteractionEnabled = true
        self.doodlesView.alpha = 1
        self.doodlesView.isUserInteractionEnabled = false
        
        //self.hideEditor()
    }
    
}
extension EditorView : StickerViewDelegate {
    func protocolStickerViewDidLongPressed(_ stickerView: StickerView) {
        
    }
    func protocolStickerViewDidCancelEditing(_ stickerView: StickerView) {
        
    }
    func protocolStickerViewDidActiveEditing(_ stickerView: StickerView) {
        
        print("Active")
    }
    
    func protocolStickerViewDidBeginEditing(_ stickerView: StickerView) {
        print("Begin")
        self.setEditorToolAlpha(alpha: 1)
        self.binButton.alpha = 0
        
        self.stickersView.bringSubviewToFront(stickerView)
    }
    
    func protocolStickerViewDidEndEditing(_ stickerView: StickerView) {
        print("End")
        self.setEditorToolAlpha(alpha: 1)
        self.binButton.alpha = 0
        
        if self.isRemove == true {
            self.isRemove = false
            stickerView.removeWithAnimate(animate: true)
        }
    }
    
    func protocolStickerViewDidMove(_ stickerView: StickerView, position: CGPoint) {
        self.setEditorToolAlpha(alpha: 0)
        self.binButton.alpha = 1
        
        //detech finger point in self.binButton.frame
        let rectRemoveArea = CGRect(x: self.binButton.frame.origin.x - 15, y: self.binButton.frame.origin.y, width: self.binButton.frame.size.width + 15, height: self.binButton.frame.size.height + 15)
        let rectContent = self.stickersView.convert(rectRemoveArea, from: view)
        if (rectContent.contains(position)) {
            self.animatebin(animate: true)
        } else {
            self.animatebin(animate: false)
        }
    }
}
