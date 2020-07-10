//
//  WelcomeViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/14/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import SwiftyJSON

// according to SDK documentation, this is now possible, 
//check https://developers.facebook.com/docs/ios/getting-started/advanced#swift
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    
    var fbToken = ""
    var fbUserID = ""
    var fbLoginManager : LoginManager = LoginManager()
    
    let facebookReadPermissions = ["public_profile", "email", "user_friends"]
    //Some other options: "user_about_me", "user_birthday", "user_hometown", "user_likes", "user_interests", "user_photos", "friends_photos", "friends_hometown", "friends_location", "friends_education_history"
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookButtonPressed(sender: CustomButton) {
        self.loginToFacebookWithSuccess(callingViewController: self, successBlock: { (result: AnyObject?) in
            
            userDefaults.set(true, forKey: DefaultKeys.fbConnecting)
            print("loginToFacebookWithSuccess result", result!)
            self.updateSignupContent(result: result! as! [String : Any])
            
            //update facebook user to como backend
            let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
            
            self.comoApiLoginFacebook(udid: udid, fbAccessToken: self.fbToken)
            
            
            }) { (error: NSError?) in
            print("Error loginToFacebook", error as Any)
                //TODO: sucgest signup with email
        }
    }
    
    func comoApiSignupFacebookUser(udid: String, fbAccessToken: String) {
        let parameters = ["uuid": udid, "access_token": fbAccessToken]
        let headers = HTTPHeaders([:])
        let encoding = URLEncoding.default
        AF.request(ComoAPI.signupFacebook , method: .post, parameters: parameters, encoding: encoding, headers: headers, interceptor: nil)
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: { (response) in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success:
                        let backendJson = JSON(response.value!)
                        if checkStatusOK(statusCode: backendJson["status"].int!) {
                            openSwipeMenu()
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
                
            }
        )
    }
    
    func comoApiLoginFacebook(udid: String, fbAccessToken: String) {
        let parameters = ["uuid": udid, "access_token": fbAccessToken]
        let headers = HTTPHeaders([:])
        let encoding = URLEncoding.default
        AF.request(ComoAPI.loginFacebook, method: .get, parameters: parameters, encoder: encoding as! ParameterEncoder, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        let token = "\(result["token"]!)"
                        let username = "\(result["profile"]!["username"])"
                        let name = "\(result["profile"]!["name"])"
                        let email = "\(result["profile"]!["email"])"
                        let image = "\(result["profile"]!["image"])"
                        
                        userDefaults.set(token, forKey: DefaultKeys.token)
                        userDefaults.set(username, forKey: DefaultKeys.username)
                        userDefaults.set(name, forKey: DefaultKeys.fullName)
                        userDefaults.set(email, forKey: DefaultKeys.email)
                        userDefaults.set(image, forKey: DefaultKeys.imageUrlString)
                        userDefaults.set("", forKey: DefaultKeys.phoneNumber)
                        userDefaults.set("", forKey: DefaultKeys.birthday)
                        userDefaults.set(connected, forKey: DefaultKeys.fbConnectStatus)
                        userDefaults.set(true, forKey: DefaultKeys.isLogin)
                        
                        //openSwipeMenu()
                        self.performSegue(withIdentifier: "OpenUsernameScreenFromFacebookLogin", sender: self)
                        
                    } else if backendJson["status"].int! == 300 {
                        self.comoApiSignupFacebookUser(udid: udid, fbAccessToken: self.fbToken)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    func updateSignupContent(result: [String : Any]) {
        let facebookUserProfile: [String: Any] = result
        print("facebookUserProfile", facebookUserProfile)
        var userImageUrlStr = ""
        if let picture = facebookUserProfile["picture"] as? [String: Any],
            let data = picture["data"] as? [String: Any] {
            userImageUrlStr = data["url"] as? String ?? ""
        }
        
        userDefaults.set(facebookUserProfile["first_name"], forKey: DefaultKeys.username)
        userDefaults.set(facebookUserProfile["name"], forKey: DefaultKeys.fullName)
        userDefaults.set(facebookUserProfile["email"], forKey: DefaultKeys.email)
        userDefaults.set(userImageUrlStr, forKey: DefaultKeys.imageUrlString)
    }
    
    @IBAction func signupButtonPressed(sender: CustomButton) {
        userDefaults.set(false, forKey: DefaultKeys.fbConnecting)
        self.performSegue(withIdentifier: "OpenSignupScreen", sender: self)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        self.performSegue(withIdentifier: "OpenLoginScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenSignupScreen" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    func loginToFacebookWithSuccess(callingViewController: UIViewController, successBlock:@escaping (AnyObject?) -> (), andFailure failureBlock: @escaping (NSError?) -> ()) {
        
        if AccessToken.current != nil {
            //For debugging, when we want to ensure that facebook login always happens
            //TODO: remove test always login
            LoginManager().logOut()
            //Otherwise do:
            return
        }
        self.fbLoginManager.logIn(permissions: facebookReadPermissions, from: self) { (result, error) in
            if let fbloginresult = result {
                if fbloginresult.isCancelled {
                    LoginManager().logOut()
                    failureBlock(nil)
                    return
                }
                if fbloginresult.grantedPermissions.contains("email"),
                    let token = fbloginresult.token {
                    self.fbUserID = result!.token!.userID
                    self.fbToken = token.tokenString
                    self.getFacebookUserProfiles(successBlock: { (result: AnyObject) in
                        successBlock(result)
                        
                        }, andFailure: { (error: NSError?) in
                            failureBlock(error)
                    })
                }
            }
        }
    }

    func getFacebookUserProfiles(successBlock: @escaping (AnyObject) -> (), andFailure failureBlock: @escaping (NSError?) -> ()) {
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, birthday, bio, gender, hometown, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    successBlock(result as AnyObject)
                } else {
                    failureBlock(error as NSError?)
                }
            })
        }
    }
}
