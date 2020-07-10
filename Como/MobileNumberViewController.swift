//
//  MobileNumberViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/16/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

class MobileNumberViewController: UIViewController {

    @IBOutlet weak var mobileNumberInputView: InputFieldView!
    @IBOutlet weak var buttomHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        self.mobileNumberInputView.textField.becomeFirstResponder()
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
    
    @IBAction func confirmButtonPressed(sender: CustomButton) {
        
        guard let mobileNumber = self.mobileNumberInputView.textField.text, mobileNumber != "" else {
            let message = "Mobile Number must be at least 10 characters"
            alertWithTitle(title: title, message: message, viewController: self, toFocus:self.mobileNumberInputView.textField)
            return
        }
        
        userDefaults.set(mobileNumber, forKey: DefaultKeys.mobileNumber)
        performSegue(withIdentifier: "OpenUsernameScreen", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenUsernameScreen" {
            
        }
    }

}
