//
//  StoriesCollectionViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/26/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

private let reuseIdentifier = "StoriesCell"

class StoriesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, MyStoryHeaderReusableViewDelegate {

    private var stories = NSMutableArray()
    private var cellSize = CGSize.zero
    
    var progressBarView = ProgressBarView()
    
    private let flipPresentAnimationController = FlipPresentAnimationController()
    private let flipDismissAnimationController = FlipDismissAnimationController()
    private let swipeController = SwipeInteractionController()
    private var selectedCellFrame: CGRect!
    private var headerSize: CGSize!
    
    private var isMyStory = false
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(StoriesCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.isUserInteractionEnabled = true
        self.collectionView?.allowsSelection = true
        
        let cellWidth = (self.view.frame.width / 2)
        self.cellSize = CGSize(width: cellWidth, height: cellWidth + 30)
        
        self.createProgressView()
        
        
        notificationCenter.addObserver(self, selector: #selector(self.reciveNotifyUpload(_:)), name: NSNotification.Name(rawValue: Notify.uploadMoment), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.comoApiGetStoryList()
    }
    
    func createProgressView() {
        let progressFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 2)
        self.progressBarView = ProgressBarView(frame: progressFrame)
        self.progressBarView.progress = 0.0
        self.progressBarView.progressColor = UIColor(hex: "#FF3B65")
        self.progressBarView.alpha = 0;
        view.addSubview(self.progressBarView)
    }

    @objc func reciveNotifyUpload(_ notification: NSNotification) {
        let notifyObj = notification.object as! NotifyUploadInfo
        
        if Bool(notifyObj.isFail) || notifyObj.progress == 1.0 {
            self.progressBarView.alpha = 0
            self.comoApiGetStoryList()
            
        } else {
            self.progressBarView.progress = CGFloat(notifyObj.progress)
            self.progressBarView.alpha = 1
        }
    }
    
    func comoApiGetStoryList() {
        self.stories.removeAllObjects()
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "token": token]
        AF.request(ComoAPI.storyList, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("comoApiGetStoryList", backendJson)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        guard let storyList:Array = result["story_list"]!.array, storyList.count > 0 else {
                            return
                        }
                        for dict in storyList {
                            let story = Story(storyId: Int("\(dict["id"])")!,
                                image: "\(dict["image"])",
                                title: "\(dict["name"])",
                                isSelected: dict["is_notify"].boolValue,
                                typeDisplay: "\(dict["type_display"])")
                            
                            if story.typeDisplay != "My Story" {
                                self.stories.add(story)
                            } else {
                                self.isMyStory = true
                            }
                        }
                        
                        self.collectionView?.reloadData()
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    func comoApiGetStoryCollection(storyId: Int, lastItemId: Int) {
        AppLoadingActivity.loadingOnScreen(view: (self.navigationController?.view)!, loadingText: "load")
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let uuid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let lat = userDefaults.object(forKey: DefaultKeys.latitude) as! String
        let lng = userDefaults.object(forKey: DefaultKeys.longitude) as! String
        let parameters = ["token": token, "uuid": uuid,"lat": lat, "lng": lng, "story_id": "\(storyId)", "last_item": "\(lastItemId)"]
        let urlString = "\(ComoAPI.storyCollection)\(storyId)/?last_item=\(lastItemId)&token=\(token)&uuid=\(uuid)&lat=\(lat)&lng=\(lng)"
        print("parameters",parameters)
        print("urlString", urlString)
        AF.request(urlString, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("comoApiGetStoryCollection", backendJson)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        guard let momentList:Array = result["moment_list"]?.array, momentList.count > 0 else {
                            AppLoadingActivity.remove(animate: true)
                            return
                        }
                        let moments = NSMutableArray()
                        for dict in momentList {
                            /*
                            let moment = Moment(
                                id: Int(dict["id"])),
                                views: Int("\(dict["views"])"),
                                likes: Int("\(dict["likes"])"),
                                type: Int("\(dict["type"])"),
                                latitude: Double("\(dict["latitude"])"),
                                longitude: Double("\(dict["longitude"])"),
                                timestamp: prettyTimestamp(checkString("\(dict["timestamp"])")),
                                typeDisplay: checkString("\(dict["type_display"])"),
                                isLiked: checkString("\(dict["is_liked"])").boolValue,
                                duration: checkInt("\(dict["duration"])"),
                                path: checkString("\(dict["path"])"),
                                userName: checkString("\(dict["account"]["name"])"),
                                userImage: checkString("\(dict["account"]["image"])"))
                            moments.addObject(moment)
                            */
                        }
                        AppLoadingActivity.remove(animate: true)
                        self.openfeedPlayer(moments: moments)
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    @IBAction func cameraButtonPressed(sender: UIButton) {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let swipeMenu = appDelegate.window!.rootViewController as! SwipeMenuController
        swipeMenu.moveToPage(SlidePage.snapPage, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.stories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! StoriesCell
        
        let story = self.stories[indexPath.item] as! Story
        
        cell.storiesImageView.setImage(story.image, placeholderImage: UIImage(named: "thumb_setup_user_borderless"))
        
        cell.storiesNotify.alpha = story.isSelected.toAlpha()
        
        cell.corner = (self.cellSize.width - 16) / 2.08
        cell.storiesImageView?.backgroundColor = UIColor(hex: "#DDDDDD")
        cell.storiesTitle?.text = story.title
    
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.isMyStory == true {
            self.headerSize = CGSize(width: view.frame.size.width, height: view.frame.size.height * 0.15)
        } else {
            self.headerSize = CGSize.zero
        }
        return self.headerSize
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            //MyStoryHeaderView
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoryHeaderCell", for: indexPath) as! MyStoryHeaderReusableView
            headerView.updateImageCorner()
            headerView.backgroundColor = UIColor(hex: "#B7C0CE")
            headerView.delegate = self
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "StoryFooterCell", for: indexPath)
            
            footerView.backgroundColor = UIColor.clear
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StoriesCell
        
        let story = self.stories[indexPath.item] as! Story
        print("didSelectItemAtIndexPath", story.storyId)
        
        //for any cell in collectionView
        self.selectedCellFrame = collectionView.layoutAttributesForItem(at: indexPath as IndexPath)!.frame
        print("self.selectedCellFrame", self.selectedCellFrame!)
        self.comoApiGetStoryCollection(storyId: story.storyId, lastItemId: 0)
    }
    
    func openfeedPlayer(moments: NSMutableArray) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedPlayerVC = mainStoryboard.instantiateViewController(withIdentifier: "FeedPlayerScreen") as! FeedPlayerViewController
        feedPlayerVC.moments = moments
        feedPlayerVC.transitioningDelegate = self
        self.swipeController.wireToViewController(viewController: feedPlayerVC)
        self.present(feedPlayerVC, animated: true, completion: nil)
        
    }
    
    func protocolMyStoryHeaderReusableViewOpenMyStory() {
        self.performSegue(withIdentifier: "OpenMyStoryFromPush", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

extension StoriesCollectionViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        flipPresentAnimationController.originFrame = self.selectedCellFrame
        return flipPresentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        flipDismissAnimationController.destinationFrame = self.selectedCellFrame
        return flipDismissAnimationController
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeController.interactionInProgress ? swipeController : nil
    }
}
