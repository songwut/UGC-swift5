//
//  SignupViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fullNameInputView: InputFieldView!
    @IBOutlet weak var emailInputView: InputFieldView!
    @IBOutlet weak var passwordInputView: InputFieldView!
    
    @IBOutlet weak var buttomHeight: NSLayoutConstraint!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        self.fullNameInputView.textField.delegate = self
        self.emailInputView.textField.delegate = self
        self.passwordInputView.secureText = true
        self.passwordInputView.textField.delegate = self
        
        self.fullNameInputView.textField.becomeFirstResponder()
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

    func isValidEmail (test:String!) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let valid = emailTest.evaluate(with: test)
        return valid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if (textField == self.fullNameInputView) {
            self.emailInputView.becomeFirstResponder()
        } else if (textField == self.emailInputView) {
            self.passwordInputView.becomeFirstResponder()
        } else {
            checkTextInput()
        }
        
        return true
    }
    
    func checkTextInput() {
        let title = "Error"
        var message = ""
        
        if self.fullNameInputView.textField.text! == "" {
            message += "Name empty"
            alertWithTitle(title: title, message: message, viewController: self, toFocus:self.fullNameInputView.textField)
            
        } else if !isValidEmail(test: self.emailInputView.textField.text) {
            message += "Invalid Email Address"
            alertWithTitle(title: title, message: message, viewController: self, toFocus:self.emailInputView.textField)
            
        } else if self.passwordInputView.textField.text! == "" {
            message += "Password empty"
            alertWithTitle(title: title, message: message, viewController: self, toFocus:self.passwordInputView.textField)
            
        } else if (self.passwordInputView.textField.text?.count)! < 6 {
            message += "Password must be at least 8 characters"
            alertWithTitle(title: title, message: message, viewController: self, toFocus:self.passwordInputView.textField)
        }
    }

    @IBAction func createMyAccountPressed(sender: CustomButton) {
        
        guard var email = self.emailInputView.textField.text, email != "" else {
            self.checkTextInput()
            return
        }
        
        guard let password = self.passwordInputView.textField.text, password != "" else {
            self.checkTextInput()
            return
        }
        
        guard var name = self.fullNameInputView.textField.text, name != "" else {
            self.checkTextInput()
            return
        }
        
        email = trimString(string: email)
        name = trimString(string: name)
        
        userDefaults.set(email, forKey: DefaultKeys.email)
        userDefaults.set(password, forKey: DefaultKeys.password)
        userDefaults.set(name, forKey: DefaultKeys.fullName)
        userDefaults.set("", forKey: DefaultKeys.phoneNumber)
        userDefaults.set("", forKey: DefaultKeys.birthday)
        userDefaults.set("", forKey: DefaultKeys.fbConnectStatus)
        userDefaults.set("", forKey: DefaultKeys.latitude)
        userDefaults.set("", forKey: DefaultKeys.longitude)
        self.comoApiSignupWithEmail(email: email, name: name, password: password)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenUsernameScreen" {
            
        }
    }
    
    func comoApiSignupWithEmail(email: String, name: String, password: String) {
        /*
        let udid = userDefaults.objectForKey(DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "email": email, "name": name, "password": password]
        
        Alamofire.request(.POST, ComoAPI.signup, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                let backendJson = JSON(response.result.value!)
                print("backendJson:", backendJson)
                
                if checkStatusOK(backendJson["status"].int!) {
                    let result = backendJson["result"].dictionary!
                    let token = "\(result["token"]!)"
                    let username = "\(result["profile"]!["username"])"
                    
                    userDefaults.setObject(username, forKey: DefaultKeys.username)
                    userDefaults.setObject(token, forKey: DefaultKeys.token)
                    self.performSegueWithIdentifier("OpenUsernameScreen", sender: self)
                    
                } else {
                    let errorMsg = backendJson["status_msg"].string!
                    alertWithTitle("", message:errorMsg , viewController: self, toFocus:self.passwordInputView.textField)
                }
                
            case .Failure(let error):
                print(error)
            }
        }
        */
    }
}
