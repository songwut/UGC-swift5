//
//  UserMomentListViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/8/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ObjectMapper

private let reuseIdentifier = "MomentCollectionCell"

class ProfileHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MyMomentHeaderReusableViewDelegate, MomentCollectionCellDelegate, SuggestSnapViewDelegate {

    var storyId: Int!
    
    private var moments = NSMutableArray()
    private var cellSize = CGSize.zero
    private var headerSize = CGSize.zero
    private var viewCount = 0
    private var likeCount = 0
    private var momentCount = 0
    private var lastestMomentImageStr: String!
    
    private let flipPresentAnimationController = FlipPresentAnimationController()
    private let flipDismissAnimationController = FlipDismissAnimationController()
    private let swipeController = SwipeInteractionController()
    private var selectedCellFrame: CGRect!
    
    var momentHeaderView: MyMomentHeaderReusableView!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.historyCollectionView!.registerClass(MomentCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.historyCollectionView.delegate = self
        self.historyCollectionView.dataSource = self
        self.historyCollectionView?.showsVerticalScrollIndicator = false
        self.cellSize = CGSize(width: view.frame.width, height: view.frame.size.height * 0.2)
        self.headerSize = CGSize(width: view.frame.size.width, height: view.frame.size.height * 0.15)
        
        self.selectedCellFrame = CGRect(x: self.view.frame.size.width, y: 60, width: 60, height: 60)
        
        self.comoApiGetProfileHistory()
        
    }
    
    func createSuggestSnapView() {
        let midH = self.headerSize.height
        let suggestSnapView = SuggestSnapView(frame: CGRect(x: 0, y: 0, width: 320, height: 140))
        suggestSnapView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + (midH / 3));
        suggestSnapView.delegate = self
        self.historyCollectionView.addSubview(suggestSnapView)
    }
    
    func protocolStartSnapButtonPressed(sender: CustomButton) {
        print("go to snap view")
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let swipeMenu = appDelegate.window!.rootViewController as! SwipeMenuController
        swipeMenu.moveToPage(SlidePage.snapPage, animated: true)
    }
    
    func comoApiGetProfileHistory() {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let parameters = ["udid": udid, "token": token]
        print("parameters", parameters)
        let urlString = "\(ComoAPI.profileHistory)?token=\(token)&uuid=\(udid)"
        AF.request(urlString, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("comoApiGetProfileHistory", backendJson)
                    
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        let result = backendJson["result"].dictionary!
                        let momentList:Array = result["moment_list"]!.array!
                        
                        
                        
                        if momentList.count == 0 {
                            self.createSuggestSnapView()
                        } else {
                            
                            let latestMomentDict = result["latest_moment"]!.dictionary!
                            self.lastestMomentImageStr = latestMomentDict["path"]!.string!
                            
                            for dict in momentList {
                                print("moment" ,dict["id"])
                                let moment = Moment(
                                    id: Int("\(dict["id"])")!,
                                    views: Int("\(dict["views"])")!,
                                    likes: Int("\(dict["likes"])")!,
                                    type: Int("\(dict["type"])")!,
                                    latitude: Double("\(dict["latitude"])")!,
                                    longitude: Double("\(dict["longitude"])")!,
                                    timestamp: prettyTimestamp("\(dict["timestamp"])"),
                                    typeDisplay: "\(dict["type_display"])",
                                    isLiked: "\(dict["is_liked"])".boolValue,
                                    duration: Int("\(dict["duration"])")!,
                                    path: "\(dict["path"])",
                                    userName: "\(dict["account"]["name"])",
                                    userImage: "\(dict["account"]["image"])")
                                self.moments.add(moment)
                            }
                            
                        }
                        
                        self.historyCollectionView?.reloadData()
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error:\(error)")
                    
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func protocolMomentCollectionCellDidDownload() {
        print("Download")
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.moments.count
    }
    
    func createDetail(moment: Moment) -> String {
        let detailStr = "\(moment.views) views  \(moment.likes) likes"
        return detailStr
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MomentCollectionCell
        
        let moment = self.moments[indexPath.item] as! Moment
        
        let imageUrl = NSURL(string: moment.path)
        print("imageUrl", imageUrl as Any)
        if imageUrl != nil {
            cell.momentImageView.setImage(moment.path, placeholderImage: nil)
        }
        
        cell.detailLabel.text = self.createDetail(moment: moment)
        cell.timeLabel?.text = moment.timestamp
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.headerSize;
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            //MyStoryHeaderView
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MomentHeaderCell", for: indexPath as IndexPath) as! MyMomentHeaderReusableView
            headerView.updateImageCorner(height: self.headerSize.height - 16)
            headerView.backgroundColor = UIColor(hex: "#B7C0CE")
            headerView.title.text = "\(self.momentCount) Moments Last 24 hours"
            headerView.desc.text = "\(self.viewCount) views \(self.likeCount) Likes"
            if self.lastestMomentImageStr != nil {
                let imageUrl = NSURL(string: self.lastestMomentImageStr)
                if imageUrl != nil {
                    headerView.userImageView.setImage(self.lastestMomentImageStr, placeholderImage: nil)
                }

            }
            
            headerView.delegate = self
            self.momentHeaderView = headerView
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func protocolMyMomentHeaderReusableViewDidPlay() {
        print("DidPlay")
        //AppLoadingActivity.loadingOnScreen((self.navigationController?.view)!, loadingText: "load")
        self.openfeedPlayer(moments: moments)
    }
    
    func openfeedPlayer(moments: NSMutableArray) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let feedPlayerVC = mainStoryboard.instantiateViewController(withIdentifier: "FeedPlayerScreen") as! FeedPlayerViewController
        feedPlayerVC.moments = moments
        feedPlayerVC.transitioningDelegate = self
        let swipeController = SwipeInteractionController()
        swipeController.wireToViewController(viewController: feedPlayerVC)
        self.present(feedPlayerVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

extension ProfileHistoryViewController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        flipPresentAnimationController.originFrame = self.selectedCellFrame
        return flipPresentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        flipDismissAnimationController.destinationFrame = self.selectedCellFrame
        return flipDismissAnimationController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeController.interactionInProgress ? swipeController : nil
    }
}
