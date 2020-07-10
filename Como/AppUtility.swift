//
//  AppUtility.swift
//  Como
//
//  Created by Songwut Maneefun on 5/13/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import GPUImage
import AVKit
import AVFoundation
import MobileCoreServices
import CoreLocation
import SDWebImage
import Alamofire

var appLocationManager = CLLocationManager()
var swipeMenuController: SwipeMenuController!
let videoTime = 10
let defaultPlayTime = 5
var imageFilteredOutPut: UIImage!
let millisec = 1000

struct DefaultKeys {
    static let isLogin = "isLogin"
    static let fbConnecting = "facebookConnecting"
    static let fbConnectStatus = "facebookConnectStatus"
    static let uuid = "uuid"
    static let token = "token"
    static let username = "username"
    static let password = "password"
    static let fullName = "fullName"
    static let email = "email"
    static let imageUrlString = "imageUrlString"
    static let mobileNumber = "mobileNumber"
    static let imageData = "imageData"
    static let phoneNumber = "phoneNumber"
    static let birthday = "birthday"
    static let latitude = "latitude"
    static let longitude = "longitude"
}

struct SecondInOne {
    static let oneSecond = 1
    static let minute = oneSecond * 60
    static let hour = minute * 60
    static let day = hour * 24
    static let week = day * 7
    static let month = day * 31
    static let year = day * 365
}

struct SlidePage {
    static let snapPage = 0
    static let storiesPage = 1
}

let connected = "Connected"

let domainAPI = "https://api-s1.comotalk.com/v1/"

struct ComoAPI {
    static let signup = "\(domainAPI)account/signup/"
    static let signupFacebook = "\(domainAPI)account/signup/facebook/"
    static let login = "\(domainAPI)account/login/"
    static let loginFacebook = "\(domainAPI)account/login/facebook/"
    static let updateUsername = "\(domainAPI)account/username/update/"
    static let storyList = "\(domainAPI)story/?file"
    static let storyCollection = "\(domainAPI)story/"
    static let senderList = "\(domainAPI)sender/group/"
    static let updateProfileImage = "\(domainAPI)account/image/update/"
    static let profileHistory = "\(domainAPI)account/history/"
    static let uploadMomen = "\(domainAPI)moment/upload/"
    static let stickerList = "\(domainAPI)sticker/"
    static let doodleList = "\(domainAPI)doodle/"
}

struct SettingTag {
    static let username = 1
    static let fullName = 2
    static let phoneNumner = 3
    static let email = 4
    static let password = 5
    static let birthday = 6
    static let facebook = 7
}

struct SignupFields {
    static let username = "username"
    static let password = "password"
    static let fullName = "fullName"
    static let email = "email"
    static let imageUrlString = "imageUrlString"
    static let mobileNumber = "mobileNumber"
    static let image = "image"
    static let token = "token"
}

let notificationCenter = NotificationCenter.default
struct Notify {
    static let uploadMoment = "uploadMoment"
}
struct NotifyInfo {
    static let progress = "progress"
    static let isFail = "isFail"
}

var previewContent = [String: Any]()

struct Medias {
    static let video = "video"
    static let image = "image"
}

let userDefaults = UserDefaults.standard

func checkStatusOK(statusCode: Int) -> Bool {
    if statusCode == 200 { return true }
    return false
}

func openSwipeMenu() {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let swipeMenu = mainStoryboard.instantiateViewController(withIdentifier: "SwipeMenuScreen") as! SwipeMenuController
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window!.rootViewController = swipeMenu
}

func openWelcomeScreen() {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let welcomeVC = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeScreen") as! WelcomeViewController
    let navWelcomeVC = UINavigationController(rootViewController: welcomeVC)
    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window!.rootViewController = navWelcomeVC
}

class BackendAPI {
    func loginWithFacebookSuccess(viewController: UIViewController, successBlock: () -> (), andFailure failureBlock: (NSError?) -> ()) {
        
    }
}

func alertWithTitle(title: String!, message: String, viewController: UIViewController, toFocus:UITextField!) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: {_ in
        if toFocus != nil {
            toFocus.becomeFirstResponder()
        }
    });
    alert.addAction(action)
    viewController.present(alert, animated: true, completion:nil)
}

func trimString(string: String) -> String {
    return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}

func checkImageOrientation(image: UIImage, name: String) {
    var orientation = ""
    switch image.imageOrientation {
    case .up:
        orientation = "Up"
    case .down:
        orientation = "Down"
    case .left:
        orientation = "Left"
    case .right:
        orientation = "Right"
    case .upMirrored:
        orientation = "UpMirrored"
    case .downMirrored:
        orientation = "DownMirrored"
    case .leftMirrored:
        orientation = "LeftMirrored"
    case .rightMirrored:
        orientation = "RightMirrored"
    default: break
        
    }
    print("\(name) : \(orientation) : \(image)")
}

func imageResized(image: UIImage, resize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = resize.width  / image.size.width
    let heightRatio = resize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    print("newSize", newSize)
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func indexFromTag(tag: Int) -> Int {
    return (tag - 1)
}
var formatServer:DateFormatter!
func getFormatServer() -> DateFormatter {
    if formatServer == nil {
        formatServer = DateFormatter()
        formatServer.timeZone = TimeZone(identifier: "UTC")
        formatServer.calendar = Calendar(identifier: .gregorian)
        formatServer.locale = Locale.current
        formatServer.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    return formatServer
}

var formatTimeOnly:DateFormatter!
func getFormatTimeOnly() -> DateFormatter {
    if formatTimeOnly == nil {
        formatTimeOnly = DateFormatter()
        formatTimeOnly.timeStyle = .short
        formatTimeOnly.dateStyle = .none
        formatTimeOnly.locale = Locale.current
    }
    return formatTimeOnly
}

var formatNormal:DateFormatter!
func getFormatNormal() -> DateFormatter {
    if formatNormal == nil {
        formatTimeOnly = DateFormatter()
        formatTimeOnly.timeStyle = .short
        formatTimeOnly.dateStyle = .medium
        formatTimeOnly.locale = Locale.current
    }
    return formatTimeOnly
}
func prettyTimestamp(_ dateStr: String!) -> String {
    print("dateStr", dateStr)
    let inputDate = getFormatServer().date(from: String(dateStr))!
    let prettyTimestamp: String!
    let delta = Int(Date().timeIntervalSince(inputDate))
    if(delta < SecondInOne.minute) {
        prettyTimestamp = "just now"
        
    } else if(delta < SecondInOne.minute * 2) {
        prettyTimestamp = "1 min ago"
        
    } else if(delta < SecondInOne.hour) {
        
        let min = floor(Double(delta / SecondInOne.minute))
        prettyTimestamp = "\(min) mins ago"
        
    } else if(delta < SecondInOne.hour * 2) {
        prettyTimestamp = "1 hour ago"
        
    } else if(delta < SecondInOne.day) {
        let hours = floor(Double(delta / SecondInOne.hour))
        prettyTimestamp = "\(hours) hours ago"
        
    } else if(delta < SecondInOne.day * 2 ) {
        let timeOnly = getFormatTimeOnly().string(from: inputDate)
        prettyTimestamp = "yesterday\(timeOnly)"
        
    } else {
        let normalDateTime = getFormatNormal().string(from: inputDate)
        prettyTimestamp = "\(normalDateTime)"
        
    }
    
    return prettyTimestamp;
}

func filteredImageWithCIImage(image: UIImage, filterName: String) -> UIImage {
    if filterName == "" {
        return image
    }
    let sourceImage = CIImage(image: image)
    let myFilter = CIFilter(name: filterName)
    myFilter?.setDefaults()
    myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
    
    let context = CIContext(options: nil)
    let outputCGImage = context.createCGImage(myFilter!.outputImage!, from: myFilter!.outputImage!.extent)
    let filteredImage = UIImage(cgImage: outputCGImage!)
    return filteredImage
}

func generateThumnailFromVideoUrl(url: URL) -> UIImage {
    let imageGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
    let captueredTime = CMTimeMake(value: 1, timescale: 1)
    var actualTime = CMTime.zero
    var thumbnail : CGImage?
    do {
        thumbnail = try imageGenerator.copyCGImage(at: captueredTime, actualTime: &actualTime)
        
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    //let image = UIImage(CGImage: thumbnail!)
    let image = UIImage(cgImage: thumbnail!, scale: 1.0, orientation: .right)
    return RBResizeImage(image: image, targetSize: image.size)
}


//
//    func generateThumnail(url : NSURL, fromTime:Float64) -> UIImage {
//        let assetImgGenerate = AVAssetImageGenerator(asset: AVAsset(URL: url))
//        assetImgGenerate.appliesPreferredTrackTransform = true
//        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
//        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
//        let time: CMTime = CMTimeMakeWithSeconds(fromTime, 600)
//        let imageRef: CGImageRef?
//        do {
//            imageRef = try assetImgGenerate.copyCGImageAtTime(time, actualTime: nil)
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//        return UIImage(CGImage: imageRef!)
//    }

func filterProcess(image: UIImage, filterOperation:FilterOperationInterface, success: @escaping (UIImage) -> ()) {
    //GPUImage not stable
    let pictureInput = PictureInput(image:image)
    let pictureOutput = PictureOutput()
    
    let filter = filterOperation.operation
    
    pictureOutput.imageAvailableCallback = {image in
        success(image)
    }
    
    pictureInput --> filter --> pictureOutput
    pictureInput.processImage(synchronously:true)
    
}

//+ (NSString *)createPrettyTimestamp:(NSDate *)date {
//    NSString * prettyTimestamp;
//    
//    let delta = [[NSDate date] timeIntervalSinceDate:date];
//    
//    if(delta < SECOND_IN_ONE_MINUTE) {
//        prettyTimestamp = NSLocalizedString(@"just now", nil);
//        
//    } else if(delta < SECOND_IN_ONE_MINUTE * 2) {
//        prettyTimestamp = NSLocalizedString(@"1 min ago", nil);
//        
//    } else if(delta < SECOND_IN_ONE_HOUR) {
//        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%d mins ago", nil), (int)floor(delta / SECOND_IN_ONE_MINUTE)];
//        
//    } else if(delta < SECOND_IN_ONE_HOUR * 2) {
//        prettyTimestamp = NSLocalizedString(@"1 hour ago", nil);
//        
//    } else if(delta < SECOND_IN_ONE_DAY) {
//        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"%d hours ago", nil), (int) floor(delta/SECOND_IN_ONE_HOUR)];
//        
//    } else if(delta < SECOND_IN_ONE_DAY * 2 ) {
//        prettyTimestamp = [NSString stringWithFormat:NSLocalizedString(@"yesterday %@", nil), [[[MyUtils sharedClient] getTimeOnlyMediumStyleDateFormatter] stringFromDate:date]];
//    } else {
//        prettyTimestamp = [[[MyUtils sharedClient] getDateOnlyMediumStyleDateFormatter] stringFromDate:date];
//    }
//
//    return prettyTimestamp;
//}

class AppUtility: NSObject {
    
}

//var colorDarkNavy = UIColor(hexString: "#ffe700ff")
