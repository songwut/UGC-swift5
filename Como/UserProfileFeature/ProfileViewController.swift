//
//  ProfileViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/28/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let reuseIdentifier = "MomentCell"
private let offset_HeaderStop:CGFloat = 136.0 // At this offset the Header stops its transformations
private let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
private let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SuggestSnapViewDelegate {

    
    private var moments = NSMutableArray()
    private var cellSize = CGSize.zero
    
    @IBOutlet weak var statView: StatView!
    @IBOutlet weak var userImageView: UserImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var momentsCollectionView: UICollectionView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var subHeader: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    var blurView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let username = userDefaults.object(forKey: DefaultKeys.username) as! String
        self.usernameLabel.text = "@\(username)"
        
        let fullName = userDefaults.object(forKey: DefaultKeys.fullName) as! String
        self.fullNameLabel.text = fullName
        print("username \(username) fullName \(fullName)")
        
        //blur cover
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurView = UIVisualEffectView(effect: blur)
        blurView.frame = coverImageView.bounds
        blurView.alpha = 0.0;
        header.insertSubview(blurView, belowSubview: userImageView)
        
        //update user image
        let imageUrlStr = userDefaults.object(forKey: DefaultKeys.imageUrlString) as! String
        let userImageUrl = NSURL(string: imageUrlStr)!
        //self.userImageView.kf_setImageWithURL(userImageUrl)
        self.userImageView.setImage(imageUrlStr, placeholderImage: UIImage(named: "thumb_setup_user_borderless"))
        
        let cellWidth = self.view.frame.width
        self.cellSize = CGSize(width: cellWidth, height: cellWidth * 0.7)

        self.momentsCollectionView!.register(MomemtCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.momentsCollectionView.delegate = self
        self.momentsCollectionView.dataSource = self
        
        self.statView.moments = 2
        self.statView.views = 5
        self.statView.likes = 4
        
        //test
        for i in 1 ..< 15 {
            let momemtGroup = MomentGroup(momentID: i, day: i, month: "may")
            self.moments.add(momemtGroup)
        }
        print("self.moments", self.moments)
        self.momentsCollectionView?.reloadData()
        
        //self.momentsCollectionView.alpha = 0
        
        //createSuggestSnapView()
    }
    
    func createSuggestSnapView() {
        let midH = header.bounds.height
        let suggestSnapView = SuggestSnapView(frame: CGRect(x: 0, y: 0, width: 320, height: 140))
        suggestSnapView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY + (midH / 3));
        suggestSnapView.delegate = self
        view.addSubview(suggestSnapView)
    }
    
    func protocolStartSnapButtonPressed(sender: CustomButton) {
        print("go to snap view")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func settingButtonPressed(sender: IconButton) {
        self.performSegue(withIdentifier: "OpenSettingScreen", sender: self)
    }
    
    @IBAction func screenDismiss(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true) {
            print("dismis Profile Screen")
        }
    }
    @IBAction func screenPaningUp(sender: UIPanGestureRecognizer) {
        //TODO: pan view controler up to dismis
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        var subHeaderTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        print("offset",offset)
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height) / 2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            let subHeaderScaleFactor:CGFloat = -(offset) / subHeader.bounds.height
            let subHeaderSizevariation = ((subHeader.bounds.height * (1.0 + subHeaderScaleFactor)) - subHeader.bounds.height)
            subHeaderTransform = CATransform3DTranslate(subHeaderTransform, 0, subHeaderSizevariation, 0)
            
            header.layer.transform = headerTransform
            subHeader.layer.transform = subHeaderTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            subHeaderTransform = CATransform3DTranslate(subHeaderTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            //fullNameLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            blurView.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            subHeader.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader) * -1
            // Avatar -----------
            
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / userImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((userImageView.bounds.height * (1.0 + avatarScaleFactor)) - userImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if userImageView.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            } else {
                if userImageView.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
                //subHeader.alpha -= 0.1
            }
            
        }
        
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        subHeader.layer.transform = subHeaderTransform
        //userImageView.layer.transform = avatarTransform
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 280);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.moments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MomemtCell
        
        let momentGroup = self.moments[indexPath.item] as! MomentGroup
        print("day", momentGroup.day)
        print("month", momentGroup.month)
        //cell.day = momentGroup.day
        //cell.month = momentGroup.month
        
        cell.dayLabel?.text = "\(momentGroup.day)"
        cell.monthLabel?.text = momentGroup.month
        cell.setNeedsDisplay()
        return cell
    }
    /*
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileHeaderCell", forIndexPath: indexPath)
            
            headerView.backgroundColor = UIColor.blueColor()
            
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "ProfileFooterCell", forIndexPath: indexPath)
            
            footerView.backgroundColor = UIColor.greenColor()
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
 */
    
    /*
    func comoApiGetAllMyMoments() {
        let token = userDefaults.objectForKey(DefaultKeys.token) as! String
        let udid = userDefaults.objectForKey(DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "token": token]
        
        Alamofire.request(.GET, ComoAPI.storyList, parameters: parameters).responseJSON { response in
            switch response.result {
            case .Success:
                let backendJson = JSON(response.result.value!)
                
                if checkStatusOK(backendJson["status"].int!) {
                    let result = backendJson["result"].dictionary!
                    guard let storyList:Array = result["story_list"]!.array where storyList.count > 0 else {
                        return
                    }
                    for dict in storyList {
                        let story = Story(
                            id: Int("\(dict["id"])")!,
                            image: "\(dict["image"])",
                            name: "\(dict["name"])",
                            location: "\(dict["location"])")
                        
                        self.stories.addObject(story)
                    }
                    self.collectionView?.reloadData()
                    
                } else {
                    let errorMsg = backendJson["status_msg"].string!
                    alertWithTitle("", message:errorMsg , viewController: self, toFocus:nil)
                }
                
            case .Failure(let error):
                print(error)
            }
        }
    } */
}
