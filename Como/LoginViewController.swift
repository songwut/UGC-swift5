//
//  LoginViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/24/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameInputView: InputFieldView!
    @IBOutlet weak var passwordInputView: InputFieldView!
    
    @IBOutlet weak var buttomHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        self.usernameInputView.textField.delegate = self
        self.passwordInputView.secureText = true
        self.passwordInputView.textField.delegate = self
        
        self.usernameInputView.textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //convert to minus value
        self.buttomHeight.constant = keyboardFrame.size.height * -1
        view.setNeedsLayout()
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.buttomHeight.constant = 0
        view.setNeedsLayout()
    }
    
    @IBAction func loginButtonPressed(sender: CustomButton) {
        
        guard let username = self.usernameInputView.textField.text, username != "" else {
            alertWithTitle(title: "", message: "Please fill in your Username", viewController: self, toFocus:self.usernameInputView.textField)
            return
        }
        
        guard let password = self.passwordInputView.textField.text, password != "" else {
            alertWithTitle(title: "", message: "Please fill in your Password", viewController: self, toFocus:self.passwordInputView.textField)
            return
        }
        
        self.comoApiLoginWithUsername(username: username, password: password)
    }
    
    func comoApiLoginWithUsername(username: String, password: String) {
        
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "username": username, "password": password]
        AF.request(ComoAPI.login, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        let username = "\(result["profile"]!["username"])"
                        let name = "\(result["profile"]!["name"])"
                        let email = "\(result["profile"]!["email"])"
                        let image = "\(result["profile"]!["image"])"
                        let token = "\(result["token"]!)"
                        
                        userDefaults.set(token, forKey: DefaultKeys.token)
                        userDefaults.set(username, forKey: DefaultKeys.username)
                        userDefaults.set(name, forKey: DefaultKeys.fullName)
                        userDefaults.set(email, forKey: DefaultKeys.email)
                        userDefaults.set(image, forKey: DefaultKeys.imageUrlString)
                        userDefaults.set("", forKey: DefaultKeys.phoneNumber)
                        userDefaults.set("", forKey: DefaultKeys.birthday)
                        userDefaults.set("", forKey: DefaultKeys.latitude)
                        userDefaults.set("", forKey: DefaultKeys.longitude)
                        userDefaults.set(true, forKey: DefaultKeys.isLogin)
                        
                        openSwipeMenu()
                    } else {
                        print("backendJson:", backendJson)
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:self.passwordInputView.textField)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
}
