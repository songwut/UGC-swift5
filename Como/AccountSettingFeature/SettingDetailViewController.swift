//
//  SettingDetailViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/2/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit

struct SettingDescription {
    static let username = "Your Username is used to log in and to secure your Como account."
    static let fullName = "Your Fullname is used to display on Como App."
    static let phoneNumner = "Your Phone Numner is used to secure your Como account."
    static let email = "Your Email Address is used to log in and to secure your Como account."
    static let password = "Your Password is used to log in and to secure your Como account."
    static let birthday = "Your birthday is used to send some gift to your Como account."
    static let facebook = "Your Facebook Account is used to identified your Como account."
}

class SettingDetailViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inputFieldView: InputFieldView!
    @IBOutlet weak var optionLabel: UILabel!
    
    var settingTag: Int!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputFieldView.textField.becomeFirstResponder()
        
        switch self.settingTag {
        case SettingTag.username:
            self.inputFieldView.icon = UIImage(named: "ic_user")
            self.inputFieldView.text = userDefaults.object(forKey: DefaultKeys.username) as? String
            self.descriptionLabel.text = SettingDescription.username
            return
        case SettingTag.fullName:
            self.inputFieldView.icon = UIImage(named: "ic_user")
            self.inputFieldView.text = userDefaults.object(forKey: DefaultKeys.fullName) as? String
            self.descriptionLabel.text = SettingDescription.fullName
            return
        case SettingTag.email:
            self.inputFieldView.icon = UIImage(named: "ic_mail")
            self.inputFieldView.text = userDefaults.object(forKey: DefaultKeys.email) as? String
            self.inputFieldView.placeHolder = "Your email address"
            self.descriptionLabel.text = SettingDescription.email
            return
        case SettingTag.password:
            self.inputFieldView.icon = UIImage(named: "ic_lock")
            self.inputFieldView.numberType = true
            self.inputFieldView.textField.isSecureTextEntry = true
            return
        case SettingTag.phoneNumner:
            //self.inputFieldView.icon = UIImage(named: "ic_mail")
            self.inputFieldView.text = userDefaults.object(forKey: DefaultKeys.phoneNumber) as? String
            self.inputFieldView.placeHolder = "Your phone number address"
            self.descriptionLabel.text = SettingDescription.phoneNumner
            return
        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
