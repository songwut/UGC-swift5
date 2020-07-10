//
//  SendToViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/6/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "SendToCell"
private let cellHeight = 80
private let selectViewDefaultHeight = 80

class SendToViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sendToTableView: UITableView!
    @IBOutlet weak var selectViewHeight: NSLayoutConstraint!
    @IBOutlet weak var storiesSelectedLabel: UILabel!
    
    var previewMediaVC: PreviewMediaViewController!
    var file: AnyObject!
    
    private var senderList = [[Any]]()
    private var sections = NSMutableArray()
    private var selectedStories = NSMutableArray()
    private var cellSize = CGSize.zero
    private var selectedCell: SendToCell!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sendToTableView.delegate = self
        self.sendToTableView.dataSource = self
        self.sendToTableView.separatorStyle = .none
        
        self.cellSize = CGSize(width: view.frame.size.width, height: CGFloat(cellHeight))
        self.comoApiGetSenderList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func comoApiGetSenderList() {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let latStr = userDefaults.object(forKey: DefaultKeys.latitude) as! String
        let lngStr = userDefaults.object(forKey: DefaultKeys.longitude) as! String
        let parameters = ["uuid": udid, "token": token, "lat": latStr, "lng": lngStr]
        AF.request(ComoAPI.senderList, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("comoApiGetSenderList backendJson", backendJson)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        print("comoApiGetSenderList ", result)
                        
                        let sections:Array = result["sender_group_list"]!.array!
                        
                        for section in sections {
                            
                            self.sections.add("\(section["group"])")
                            let storyArray = NSMutableArray()
                            
                            let storyList:Array = section["sender_list"].array!
                            for dict in storyList {
                                let story = StorySend(
                                    storyId: Int("\(dict["id"])")!,
                                    contentTypeId: Int("\(dict["content_type_id"])")!,
                                    image: "\(dict["image"])",
                                    title: "\(dict["name"])",
                                    description: "\(dict["desc"])",
                                    group: "\(dict["group"])",
                                    isSelected: "\(dict["is_selected"])".boolValue)
                                storyArray.add(story)
                                
                                if story.isSelected == true {
                                    self.selectedStories.add(story)
                                }
                                print("self.selectedStories", self.selectedStories)
                                print("storyArray", storyArray)
                            }
                            self.senderList.append(storyArray as! [Any])
                        }
                        print("self.senderList", self.senderList)
                        
                        self.manageStoriesString()
                        self.sendToTableView?.reloadData()
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    @IBAction func navBackButtonPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: {});
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.senderList.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section] as? String
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(hex: "#E4BF00")
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let title = self.tableView(tableView, titleForHeaderInSection: section)
        if (title == "") {
            return 0.0
        }
        return 30.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.senderList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SendToCell
        
        let story = self.senderList[indexPath.section][indexPath.row] as! StorySend
        
        cell.imageView?.image = UIImage(named: "profile_placeholder")
        cell.storyImageView?.setImage(story.image, placeholderImage: UIImage(named: "thumb_setup_user_borderless"))
        cell.title = story.title
        cell.isSelected = story.isSelected
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellSize.height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SendToCell
        let story = self.senderList[indexPath.section][indexPath.row] as! StorySend
        
        if cell.isSelected == true {
            cell.isSelected = false
            story.isSelected = false
            self.selectedStories.remove(story)
        } else {
            cell.isSelected = true
            story.isSelected = true
            self.selectedStories.add(story)
        }
        
        self.manageStoriesString()
    }
    
    func manageStoriesString() {
        
        if self.selectedStories.count > 0 {
            var selectedStr = ""
            
            let stories = NSArray(array:self.selectedStories) as! Array<StorySend>
            for story: StorySend in stories {
                if selectedStr == "" {
                    selectedStr = story.title!
                } else {
                    selectedStr = selectedStr + ", " + story.title!
                }
            }
            
            self.storiesSelectedLabel.text = selectedStr
        } else {
            self.storiesSelectedLabel.text = ""
        }
        
        print("self.selectedStories count", self.selectedStories.count)
    }
    
    @IBAction func sendToButtonPressed(sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil);
            self.previewMediaVC.dismiss(animated: true, completion: {
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                let swipeMenu = appDelegate.window!.rootViewController as! SwipeMenuController
                swipeMenu.moveToPage(SlidePage.storiesPage, animated: true)
                
                //                TODO: implement loading
                //                let loadView = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
                //                loadView.backgroundColor = UIColor.redColor()
                //                swipeMenu.view.addSubview(loadView)
            })
        }
        
        self.manageSendData()
        
    }
    
    func manageSendData() {
        
        var sendStr = ""
        let stories = NSArray(array:self.selectedStories) as! Array<StorySend>
        for story: StorySend in stories {
            let id = story.storyId
            let contentId = story.contentTypeId
            if sendStr == "" {
                sendStr = "\(String(describing: contentId)):\(String(describing: id))"
            } else {
                sendStr = sendStr + "," + "\(String(describing: contentId)):\(id)"
            }
        }
        self.comoApiCreateMoments(sendStr: sendStr, successHandler: successDataHandler)
    }
    
    func dataWithString(string: String) -> Data {
        return string.data(using: String.Encoding.utf8)!
        //return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    //TODO: uplaodImageData
    func uplaodImageData(RequestURL: String,postData:[String:AnyObject],successHandler: (String) -> (),failureHandler: (String) -> ()) -> () {
        let encoder = JSONParameterEncoder.default//URLEncoding.default
        // encoder = JURLEncoding.default
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        /*
        AF.request(RequestURL, method: .post, parameters: postData, encoder: encoder, headers: headers , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    print(response.response?.statusCode)
                    print("successHandler", response.result.value!)
                    successHandler(response.result.value!)
                case .failure(let error):
                    print("error:\(error)")
                }
        }
        */
    }
    
    func successDataHandler(responseData: String) {
        print ("IMAGE UPLOAD SUCCESSFUL    !!!")
    }
    
    func isVideo(file: AnyObject) -> Int {
        if self.file.isKind(of: UIImage.self) {
            return 0
        }
        return 1
    }
    
    func comoApiCreateMoments(sendStr: String, successHandler: (String) -> ()) {
        let lat = userDefaults.object(forKey: DefaultKeys.latitude) as! String
        let lng = userDefaults.object(forKey: DefaultKeys.longitude) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let type = "\(self.isVideo(file: self.file))"
        
        let parameters: [String:Any]? = ["token": token, "uuid": udid, "lat": lat, "lng": lng, "send": sendStr, "type": type]
        let urlString = "\(ComoAPI.uploadMomen)?token=\(token)&uuid=\(udid)&lat=\(lat)&lng=\(lng)"
        print("comoApiCreateMoments url", urlString)
        print("parameters", parameters)
        /*
        Alamofire.upload(
            .POST,
            urlString,
            headers: ["Authorization": "auth_token"],
            multipartFormData: { multipartFormData in
                if let fileSend = self.file as? UIImage {
                    let imageData = UIImageJPEGRepresentation(fileSend, 1)
                    multipartFormData.appendBodyPart(data: imageData!, name: "file", fileName: "imageFileName.jpg", mimeType: "image/jpeg")
                } else {
                    multipartFormData.appendBodyPart(fileURL: self.file as! NSURL, name: "file")
                }
                
                for (key, value) in parameters! {
                    multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                    //multipartFormData.appendBodyPart(data: self.dataWithString(value as! String), name: key)
                }
            },
            encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                        dispatch_async(dispatch_get_main_queue()) {
                            let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
                            let info = NotifyUploadInfo(progress: percent, isFail: false)
                            notificationCenter.postNotificationName(Notify.uploadMoment, object:info, userInfo:nil)
                        }
                    }
                    upload.responseJSON { response in
                        print("comoApiCreateMoments responseJSON", response)
                        switch response.result {
                        case .Success:
                            let backendJson = JSON(response.result.value!)
                            print("comoApiCreateMoments", backendJson)
                            if checkStatusOK(backendJson["status"].int!) {
                                let result = backendJson["result"].dictionary!
                                print("UPLOAD SUCCESSFUL!!", result)
                                successHandler("")
                            } else {
                                let errorMsg = backendJson["status_msg"].string!
                                alertWithTitle("", message:errorMsg , viewController: self, toFocus:nil)
                            }
                        case .Failure(let error):
                            print("responseJSON", error)
                            let info = NotifyUploadInfo(progress: 0.0, isFail: true)
                            notificationCenter.postNotificationName(Notify.uploadMoment, object:info, userInfo:nil)
                        }
                    }//end upload.responseJSON
                    
                case .Failure(let error):
                    print("encodingCompletion", error)
                }
        })
        */
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
