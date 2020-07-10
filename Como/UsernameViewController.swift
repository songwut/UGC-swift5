//
//  UsernameViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/16/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import MobileCoreServices
import Alamofire
import SwiftyJSON
import SDWebImage

class UsernameViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameInputView: InputFieldView!
    @IBOutlet weak var buttomHeight: NSLayoutConstraint!
    @IBOutlet weak var photoButton: IconButton!
    @IBOutlet weak var userImageView: UserImageView!
    
    private var imagePicker: UIImagePickerController!
    var newMedia = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        self.photoButton.layer.cornerRadius = 22
        
        self.usernameInputView.textField.delegate = self
        self.usernameInputView.textField.becomeFirstResponder()
        
        // Get facebook user profile if use facebookConnect
        
        if userDefaults.bool(forKey: DefaultKeys.fbConnecting) {
            
            let imageUrlStr = userDefaults.object(forKey: DefaultKeys.imageUrlString) as! String
            let userImageUrl = URL(string: imageUrlStr)!
            let phImg = UIImage(named: "thumb_setup_user_borderless")
            self.userImageView.sd_setImage(with: userImageUrl, placeholderImage: phImg, options: SDWebImageOptions(), progress: { (receivedSize, totalSize, url) in
                print("Download Progress: \(receivedSize)/\(totalSize)")
                
            }) { (image, error, cacheType, url) in
                print("Downloaded and set!")
                userDefaults.set(image!.pngData(), forKey: DefaultKeys.imageData)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        print("buttomHeight",self.buttomHeight.constant)
        self.buttomHeight.constant = keyboardFrame.size.height
        print("change buttomHeight",self.buttomHeight.constant)
        view.setNeedsLayout()
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.buttomHeight.constant = 0
        view.setNeedsLayout()
    }
    
    @IBAction func photoButtonPressed(sender: UIButton) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        // 2
        let takePhotoAction = UIAlertAction(title: "Take a Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //TODO: call imagepickerView controller
            self.getPhoto(sourceType: .camera)
        })
        
        let useCameraRollAction = UIAlertAction(title: "Select Photo in Camera roll", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //TODO: call imagepickerView controller
            self.getPhoto(sourceType: .photoLibrary)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            optionMenu.addAction(takePhotoAction)
        }
        optionMenu.addAction(useCameraRollAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func getPhoto(sourceType : UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)!
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
            newMedia = true
        }
    }
    
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.usernameInputView.textField.becomeFirstResponder()
    }
    /* //TODO: in feature when let user use vedio
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == (kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            print("didFinishPickingMediaWithInfo", image)
            self.userImageView.image = image
            
        } else {
            //TODO: in feature
        }
        
        self.usernameInputView.textField.becomeFirstResponder()
    }
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        print("didFinishPickingImage", image)
        self.userImageView.image = image
        userDefaults.set(image.pngData(), forKey: DefaultKeys.imageData)
        self.comoApiUpdateProfileImage(image: image)
        self.usernameInputView.textField.becomeFirstResponder()
    }
    
    @IBAction func confirmButtonPressed(sender: CustomButton) {
        
        guard let username = self.usernameInputView.textField.text, username != "" else {
            let message = "Username must be at least 6 characters"
            alertWithTitle(title: "", message: message, viewController: self, toFocus:self.usernameInputView.textField)
            return
        }
        
        self.comoApiUpdateUsername(username: username)
    }
    
    func comoApiUpdateUsername(username: String) {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "token": token, "username": username]
        AF.request(ComoAPI.updateUsername, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("backendJson:", backendJson)
                    
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        userDefaults.set(username, forKey: SignupFields.username)
                        userDefaults.set(true, forKey: DefaultKeys.isLogin)
                        self.usernameInputView.textField.resignFirstResponder()
                        openSwipeMenu()
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    func comoApiUpdateProfileImage(image: UIImage) {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let imageData = image.pngData()!
        let imageBase64Str:String = imageData.base64EncodedString()
            //imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let parameters = ["uuid": udid, "token": token, "image": imageBase64Str]
        AF.request(ComoAPI.updateProfileImage, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("backendJson:", backendJson)
                    
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        let image = "\(result["profile"]!["image"])"
                        userDefaults.set(image, forKey: DefaultKeys.imageUrlString)
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenCameraScreen" {
            //TODO: sucgest take photo/ vdo
        }
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let mediaType = info[UIImagePickerControllerMediaType] as! String
//        
//        self.dismissViewControllerAnimated(true, completion: nil)
//        
//        if mediaType.isEqualToString(kUTTypeImage as! String) {
//            let image = info[UIImagePickerControllerOriginalImage]
//                as! UIImage
//            
//            self.userImageView.image = image
//            
//            if (newMedia == true) {
//                UIImageWriteToSavedPhotosAlbum(image, self,
//                                               #selector(UsernameViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
//            } else if mediaType.isEqualToString(kUTTypeMovie as! String) {
//                // Code to support video here
//            }
//            
//        }
//    }
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertController.Style.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                                       completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //Disable spacebar in iOS keyboard
        if string == " " {
            return false
        } else {
            return true
        }
    }

}
