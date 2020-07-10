//
//  SnapViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/25/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AssetsLibrary

class SnapViewController: UIViewController, ProgressBarViewDelegate{

    var SessionRunningAndDeviceAuthorizedContext = "SessionRunningAndDeviceAuthorizedContext"
    var CapturingStillImageContext = "CapturingStillImageContext"
    var RecordingContext = "RecordingContext"
    
    var mediaUrlSource: URL!
    var imageSource: UIImage!
    var mediaType: String!
    
    var sessionQueue: DispatchQueue!
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraInput: AVCaptureDeviceInput!
    var currentCamera: AVCaptureDevice!
    
    var deviceAuthorized: Bool  = false
    var backgroundRecordId = UIBackgroundTaskIdentifier.invalid
    var sessionRunningAndDeviceAuthorized: Bool {
        get {
            return (self.captureSession?.isRunning != nil && self.deviceAuthorized )
        }
    }
    var runtimeErrorHandlingObserver: AnyObject?
    var lockInterfaceRotation: Bool = false
    
    @IBOutlet weak var progressRecordView: ProgressBarView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressRecordView.delegate = self
        self.progressRecordView.alpha = 0
        self.sessionQueue = DispatchQueue(label: "session queue")
        
        self.checkDeviceAuthorizationStatus()
        
        self.openCamera()
    }
    
    func openCamera() {
        self.backgroundRecordId = UIBackgroundTaskIdentifier.invalid
        
        // camera loading code
        self.captureSession = AVCaptureSession()
        //AVCaptureSessionPresetHigh for record vedio
        //self.captureSession!.sessionPreset = AVCaptureSessionPresetInputPriority
        self.captureSession!.sessionPreset = AVCaptureSession.Preset.vga640x480
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        self.currentCamera = captureDevice
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        print("captureDevice", captureDevice!)
        
        if error == nil && self.captureSession!.canAddInput(input) {
            self.captureSession!.addInput(input)
            self.cameraInput = input
            
            print("cameraInput", self.cameraInput!)
            
            self.stillImageOutput = AVCapturePhotoOutput()
            //self.stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if self.captureSession!.canAddOutput(self.stillImageOutput!) {
                self.captureSession!.addOutput(self.stillImageOutput!)
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                self.previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                self.previewLayer!.frame = self.view.frame
                self.cameraPreview.layer.addSublayer(self.previewLayer!)
                DispatchQueue.main.async {
                    if (!(self.captureSession!.isRunning)) {
                        self.captureSession!.startRunning()
                        
                    }
                }
            }
        }
        
        let audioDevice: AVCaptureDevice = AVCaptureDevice.devices(for: AVMediaType.audio).first!
        
        var audioDeviceInput: AVCaptureDeviceInput?
        
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch let error2 as NSError {
            error = error2
            audioDeviceInput = nil
        } catch {
            fatalError()
        }
        
        if error != nil{
            print(error!)
            let alert = UIAlertController(title: "Error", message: error!.localizedDescription
                , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if self.captureSession!.canAddInput(audioDeviceInput!){
            self.captureSession!.addInput(audioDeviceInput!)
        }
        
        
        
        let movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if self.captureSession!.canAddOutput(movieFileOutput){
            self.captureSession!.addOutput(movieFileOutput)
            
            
            let connection: AVCaptureConnection? = movieFileOutput.connection(with: AVMediaType.video)
            let stab = connection?.isVideoStabilizationSupported
            if (stab != nil) {
                //connection!.enablesVideoStabilizationWhenAvailable = true
                connection!.preferredVideoStabilizationMode = .auto
            }
            
            self.movieFileOutput = movieFileOutput
            
        }
        
        let stillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
        if self.captureSession!.canAddOutput(stillImageOutput){
            //stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.captureSession!.addOutput(stillImageOutput)
            
            self.stillImageOutput = stillImageOutput
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sessionQueue.async {
            self.addObserver(self, forKeyPath: "sessionRunningAndDeviceAuthorized", options: [.old , .new] , context: &self.SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: "stillImageOutput.capturingStillImage", options:[.old , .new], context: &self.CapturingStillImageContext)
            self.addObserver(self, forKeyPath: "movieFileOutput.recording", options: [.old , .new], context: &self.RecordingContext)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: self.cameraInput?.device)
            
            weak var weakSelf = self
            self.runtimeErrorHandlingObserver = NotificationCenter.default.addObserver(forName: .AVCaptureSessionRuntimeError, object: self.captureSession, queue: nil, using: { (noti) in
                let strongSelf: SnapViewController = weakSelf!
                weakSelf?.sessionQueue.async(execute: {
                    //strongSelf.session?.startRunning()
                    if let sess = strongSelf.captureSession {
                        sess.startRunning()
                    }
                    //strongSelf.recordButton.title  = NSLocalizedString("Record", "Recording button record title")
                })
            })
            
            self.captureSession?.startRunning()
        }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        (self.cameraPreview.layer as! AVCaptureVideoPreviewLayer).connection!.videoOrientation = AVCaptureVideoOrientation(rawValue: toInterfaceOrientation.rawValue)!
        
        //        if let layer = self.previewView.layer as? AVCaptureVideoPreviewLayer{
        //            layer.connection.videoOrientation = self.convertOrientation(toInterfaceOrientation)
        //        }
        
    }
    override var shouldAutorotate: Bool {
        return !self.lockInterfaceRotation
    }
    //    observeValueForKeyPath:ofObject:change:context:
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &CapturingStillImageContext{
            let isCapturingStillImage: Bool = (change![NSKeyValueChangeKey(rawValue: NSKeyValueChangeKey.newKey.rawValue)]! as AnyObject).boolValue
            if isCapturingStillImage {
                self.runStillImageCaptureAnimation()
            }
            
        } else if context  == &RecordingContext{
            let isRecording: Bool = (change![NSKeyValueChangeKey.newKey]! as AnyObject).boolValue
            DispatchQueue.main.async {
                if isRecording {
                    self.cameraButton.isEnabled = false
                    
                } else {
                    self.cameraButton.isEnabled = true
                }
            }
        } else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Selector
    @objc func subjectAreaDidChange(_ notification: NSNotification) {
        print("subjectAreaDidChange")
        let devicePoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        self.focusWithMode(focusMode: AVCaptureDevice.FocusMode.continuousAutoFocus, exposureMode: AVCaptureDevice.ExposureMode.continuousAutoExposure, point: devicePoint, monitorSubjectAreaChange: false)
    }
    
    // MARK:  Custom Function
    
    func focusWithMode(focusMode:AVCaptureDevice.FocusMode, exposureMode:AVCaptureDevice.ExposureMode, point:CGPoint, monitorSubjectAreaChange:Bool){
        self.sessionQueue.async {
            let device: AVCaptureDevice! = self.cameraInput!.device
            
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode){
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode){
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
                
            }catch{
                print(error)
            }
        }
        
    }
    
    func runStillImageCaptureAnimation(){
        DispatchQueue.main.async {
            self.cameraPreview.layer.opacity = 0.0
            print("opacity 0")
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraPreview.layer.opacity = 1.0
                print("opacity 1")
            })
        }
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition:AVCaptureDevice.Position)->AVCaptureDevice{
        
        let devices = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType))
        var captureDevice: AVCaptureDevice = devices[0]
        
        for device in devices{
            if device.position == preferringPosition{
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
    func checkDeviceAuthorizationStatus(){
        let mediaType:String = AVMediaType.video.rawValue;
        
        AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: mediaType), completionHandler: { (granted: Bool) in
            if granted{
                self.deviceAuthorized = true;
            } else {
                DispatchQueue.main.async {
                    let alert: UIAlertController = UIAlertController(
                        title: "AVCam",
                        message: "AVCam does not have permission to access camera",
                        preferredStyle: UIAlertController.Style.alert);
                    
                    let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                        (action2: UIAlertAction) in
                        exit(0)
                    } )
                    
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.deviceAuthorized = false;
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //previewLayer!.frame = cameraPreview.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shutterButtonPressed(sender: UIButton) {
        if let videoConnection = stillImageOutput!.connection(with: AVMediaType.video) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            let photoSettings : AVCapturePhotoSettings!
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.flashMode = .off
            photoSettings.isHighResolutionPhotoEnabled = false
            stillImageOutput?.capturePhoto(with: photoSettings, delegate: self)
            /*
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCapturePhotoOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    print("capturedImage", image," size", image.size)
                    // remove UIImageOrientation
                    //let filpImage = CIImage(CGImage: image.CGImage!).imageByApplyingTransform(CGAffineTransformMakeScale(-1, 1))
                    //self.imageSource = UIImage(CIImage: filpImage)
                    self.imageSource = RBResizeImage(image, targetSize: image.size)
                    
                    previewContent.removeAllObjects()
                    previewContent.setObject(self.imageSource, forKey: Medias.image)
                    self.mediaType = Medias.image
                    print("imageSource", self.imageSource)
                    self.performSegueWithIdentifier("OpenPreviewMediaScreen", sender: self)
                }
            })
            */
        }
    }
    
    @IBAction func shutterButtonLongPress(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            print("record Began")
            self.progressRecordView.autoProgressing()
            showCameraUI(isShow: false)
            movieStartRecord()
            
        } else if sender.state == .ended {
            print("record Ended")
            self.progressRecordView.alpha = 0
            showCameraUI(isShow: true)
            movieStopRecord()
        }
    }
    
    @IBAction func logoTapped(sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "OpenProfileScreen", sender: self)
    }
    
    func showCameraUI(isShow: Bool) {
        self.cameraButton.isHidden = !isShow
        //self.shutterButton.alpha = CGFloat(isShow)
        self.flashButton.isHidden = !isShow
        self.logoImageView.isHidden = !isShow
        self.storiesButton.isHidden = !isShow
    }
    
    func protocolProgressBarViewProgressed(progressBarView: ProgressBarView) {
        print("protocolProgressBarViewProgressed")
        showCameraUI(isShow: true)
        movieStopRecord()
    }
    
    func movieStopRecord() {
        self.movieFileOutput!.stopRecording()
    }
    
    func movieStartRecord() {
        
        //self.recordButton.enabled = false
        
        self.sessionQueue.async(execute: {
            if !self.movieFileOutput!.isRecording {
                self.lockInterfaceRotation = true
                
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordId = UIApplication.shared.beginBackgroundTask(expirationHandler: {})
                    
                }
                
                if let videoConnection = self.movieFileOutput!.connection(with: AVMediaType.video) {
                    
                    self.movieFileOutput!.connection(with: AVMediaType.video)!.videoOrientation = AVCaptureVideoOrientation(rawValue: videoConnection.videoOrientation.rawValue )!
                    
                    // Turning OFF flash for video recording
                    self.setFlashMode(flashMode: AVCaptureDevice.FlashMode.off, device: self.cameraInput!.device)
                    
                    let outputFilePath  = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("movie.mp4")
                    
                    if (videoConnection.isActive) {
                        self.movieFileOutput!.startRecording(to: outputFilePath!, recordingDelegate: self)
                    }
                }
            }
        })
        
    }
    
    func setFlashMode(flashMode: AVCaptureDevice.FlashMode, device: AVCaptureDevice){
        
        if device.hasFlash && device.isFlashModeSupported(flashMode) {
            var error: NSError? = nil
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
                
            } catch let error1 as NSError {
                error = error1
                print(error1)
            }
        }
        
    }
    
    @IBAction func flashButtonPressed(sender: UIButton) {
        /*
         let avDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
         
         // check if the device has torch
         if avDevice.hasTorch {
         // lock your device for configuration
         sender.setImage(UIImage(named: "ic_flash_on"), forState: .Normal)
         // lock your device for configuration
         do {
         try avDevice.lockForConfiguration()
         } catch {
         print("flash error")
         }
         // check if your torchMode is on or off. If on turns it off otherwise turns it on
         if avDevice.torchActive {
         avDevice.torchMode = AVCaptureTorchMode.Off
         sender.setImage(UIImage(named: "ic_flash_off"), forState: .Normal)
         } else {
         // sets the torch intensity to 100%
         do {
         try avDevice.setTorchModeOnWithLevel(1.0)
         } catch {
         print("flash error")
         }
         //    avDevice.setTorchModeOnWithLevel(1.0, error: nil)
         }
         // unlock your device
         avDevice.unlockForConfiguration()
         }
         */
        var iconFlash = UIImage(named: "ic_flash_off")
        
        if self.currentCamera.flashMode == .off {
            iconFlash = UIImage(named: "ic_flash_on")
            self.setFlashMode(flashMode: AVCaptureDevice.FlashMode.on, device: self.currentCamera)
            
        } /* else if self.currentCamera.flashMode == .On {
             iconFlash = UIImage(named: "ic_flash_on")
             self.setFlashMode(AVCaptureFlashMode.Auto, device: self.currentCamera)
             //TODO: design add auto flash
         } */else {
            iconFlash = UIImage(named: "ic_flash_off")
            self.setFlashMode(flashMode: AVCaptureDevice.FlashMode.off, device: self.currentCamera)
        }
        sender.setImage(iconFlash, for: .normal)
    }
    
    @IBAction func switchCamButtonPressed(sender: UIButton) {
        
        self.cameraButton.isEnabled = false
        //self.recordButton.enabled = false
        self.shutterButton.isEnabled = false
        
        self.sessionQueue.async(execute: {
            
            let currentVideoDevice:AVCaptureDevice = self.cameraInput!.device
            let currentPosition: AVCaptureDevice.Position = currentVideoDevice.position
            var preferredPosition: AVCaptureDevice.Position = AVCaptureDevice.Position.unspecified
            
            switch currentPosition{
            case AVCaptureDevicePosition.front:
                preferredPosition = .back
                
            case AVCaptureDevicePosition.back:
                preferredPosition = .front
                
            case AVCaptureDevicePosition.unspecified:
                preferredPosition = .back
                
            @unknown default:
                fatalError()
            }
            
            let device:AVCaptureDevice = SnapViewController.deviceWithMediaType(mediaType: AVMediaType.video.rawValue, preferringPosition: preferredPosition)
            
            self.currentCamera = device
            
            var videoDeviceInput: AVCaptureDeviceInput?
            
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
            } catch _ as NSError {
                videoDeviceInput = nil
            } catch {
                fatalError()
            }
            
            self.captureSession!.beginConfiguration()
            
            self.captureSession!.removeInput(self.cameraInput)
            
            if self.captureSession!.canAddInput(videoDeviceInput!){
                
                NotificationCenter.default.removeObserver(self, name:NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object:currentVideoDevice)
                
                //self.setFlashMode(AVCaptureFlashMode.Auto, device: device)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange(_:)), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: device)
                
                self.captureSession!.addInput(videoDeviceInput!)
                self.cameraInput = videoDeviceInput
                
            } else {
                self.captureSession!.addInput(self.cameraInput)
            }
            
            self.captureSession!.commitConfiguration()
            
            DispatchQueue.main.async {
                self.shutterButton.isEnabled = true
                self.cameraButton.isEnabled = true
            }
            
        })
    }
    
    @IBAction func storiesButtonPressed(sender: UIButton) {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let swipeMenu = appDelegate.window!.rootViewController as! SwipeMenuController
        swipeMenu.moveToPage(SlidePage.storiesPage, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenPreviewMediaScreen" {
            let previewMediaVC =  segue.destination as! PreviewMediaViewController
            previewMediaVC.mediaType = self.mediaType
            
            if self.mediaType == Medias.image {
                print("send imageSource to PreviewMediaScreen", self.imageSource as Any)
                previewMediaVC.imageSource = self.imageSource
                
            } else if self.mediaType == Medias.video {
                previewMediaVC.mediaUrlSource = self.mediaUrlSource
            }
            
        }
    }

}

extension SnapViewController : AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if(error != nil){
            print(error)
        }
        
        self.lockInterfaceRotation = false
        
        // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
        
        let backgroundRecordId = self.backgroundRecordId
        self.backgroundRecordId = UIBackgroundTaskIdentifier.invalid
        
        self.mediaUrlSource = outputFileURL as URL?
        print("outputFileURL", outputFileURL as Any)
        previewContent.removeAll()
        previewContent[Medias.video] = outputFileURL
        self.mediaType = Medias.video
        self.performSegue(withIdentifier: "OpenPreviewMediaScreen", sender: self)
        
        if backgroundRecordId != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(backgroundRecordId)
        }
        /*
         ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: {
         (assetURL:NSURL!, error:NSError!) in
         if error != nil{
         print(error)
         
         }
         
         do {
         try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)
         
         self.performSegueWithIdentifier("OpenPreviewMediaScreen", sender: self)
         } catch _ {
         }
         
         if backgroundRecordId != UIBackgroundTaskInvalid {
         UIApplication.sharedApplication().endBackgroundTask(backgroundRecordId)
         }
         })
         */
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let cgImageRepresentation = photo.cgImageRepresentation(),
            let orientationInt = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
            let imageOrientation = UIImage.Orientation(rawValue: Int(orientationInt)) {
            // Create image with proper orientation
            let cgImage = cgImageRepresentation.takeUnretainedValue()
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
            
            print("capturedImage", image," size", image.size)
            // remove UIImageOrientation
            //let filpImage = CIImage(CGImage: image.CGImage!).imageByApplyingTransform(CGAffineTransformMakeScale(-1, 1))
            //self.imageSource = UIImage(CIImage: filpImage)
            self.imageSource = RBResizeImage(image: image, targetSize: image.size)
            
            previewContent.removeAll()
            previewContent[Medias.image] = self.imageSource
            self.mediaType = Medias.image
            print("imageSource", self.imageSource as Any)
            self.performSegue(withIdentifier: "OpenPreviewMediaScreen", sender: self)
        }
        
    }
}
