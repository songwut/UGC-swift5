//
//  PreviewMediaViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 5/24/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import GPUImage
import AssetsLibrary
import Photos

class PreviewMediaViewController: UIViewController, EditorViewDelegate, FiltersViewDelegate {

    var mediaUrlSource: URL!
    var imageSource: UIImage!
    var mediaType: String!
    var stickerCollections = NSMutableArray()
    var doodles = NSMutableArray()
    var assetCollection: PHAssetCollection!
    
    private var filterControlHideFrame: CGRect!
    private var filterControlShowFrame: CGRect!
    private var filtersView: FiltersView!
    
    var fileToSend: AnyObject!
    
    @IBOutlet weak var mediaView: MediaView!
    @IBOutlet weak var editorView: EditorView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.mediaView.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set default imageFilteredOutPut
        switch self.mediaType {
        case Medias.image:
            self.mediaView.image = self.imageSource
            imageFilteredOutPut = UIImage(cgImage: self.imageSource.cgImage!)
            self.editorView.imageSource = self.imageSource
            //break
        case Medias.video:
            imageFilteredOutPut = generateThumnailFromVideoUrl(url: self.mediaUrlSource)
            self.mediaView.playVideoWithUrl(url: self.mediaUrlSource)
            self.editorView.mediaUrlSource = self.mediaUrlSource
            //break
        default:
            break
        }
        
        self.createFilterControlView()
        self.editorView.mediaType = self.mediaType
        self.editorView.delegate = self
        self.comoApiGetSticker()
        self.comoApiGetDoodle()
    }
    
    // MARK: - createFilterView
    func createFilterControlView() {
        let filterControlY = view.frame.size.height
        let filterControlH = view.frame.size.height * 0.2
        self.filterControlHideFrame = CGRect(x: 0, y: filterControlY, width: view.frame.size.width, height: filterControlH)
        self.filterControlShowFrame = CGRect(x: 0, y: filterControlY - filterControlH, width: view.frame.size.width, height: filterControlH)
        
        if self.filtersView == nil {
            self.filtersView = FiltersView(frame: self.filterControlHideFrame)
            let thumnail = RBSquareImageTo(image: imageFilteredOutPut, size: CGSize(width: 300,height: 300))
            self.filtersView.miniImage = thumnail
            self.filtersView.processFilterWithImage(image: thumnail)
            self.filtersView.alpha = 0
            self.filtersView.delegate = self
            self.view.addSubview(self.filtersView)
        }
    }
    
    func filterControlViewShow(show: Bool) {
        UIView.animate(withDuration: 0.3) {
            if show == true {
                self.filtersView.frame = self.filterControlShowFrame
                self.filtersView.alpha = 1
            } else {
                self.filtersView.frame = self.filterControlHideFrame
                self.filtersView.alpha = 0
            }
        }
    }
    
    // MARK: - FiltersViewDelegate
    func protocolFiltersViewDidSelectedFilter(filter: Filter) {
        switch self.mediaType {
        case Medias.image:
            self.mediaView.filterImage(filter: filter)
        //break
        case Medias.video:
            //self.mediaView.videoUrl = self.mediaUrlSource
            self.mediaView.filterVideo(filter: filter)
        //break
        default:
            break
        }
    }

    // MARK: - EditorViewDelegate
    func protocolEditorViewDidClose() {
        self.dismiss(animated: true) {
            print("dismis preview")
        }
    }
    
    func protocolEditorViewDidBack() {
        self.filterControlViewShow(show: false)
    }
    
    func protocolEditorViewDidSubmit(file: AnyObject) {
        self.fileToSend = file
        self.performSegue(withIdentifier: "OpenSendToFromPreview", sender: self)
    }
    
    func protocolEditorViewDidSave(file: AnyObject) {
        CustomPhotoAlbum.sharedInstance.saveFile(file: file, vc: self)
    }
    
    
    func protocolEditorViewFilterViewDidShow(show: Bool) {
        self.filterControlViewShow(show: show)
    }
    
    // MARK: -
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Now modify bottomView's frame here
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenSendToFromPreview" {
            self.mediaView.pause()
            let navVC =  segue.destination as! UINavigationController
            let sendToVC =  navVC.viewControllers[0] as! SendToViewController
            sendToVC.previewMediaVC = self
            
            switch self.mediaType {
            case Medias.image:
                sendToVC.file = self.fileToSend
            break
            case Medias.video:
                sendToVC.file = self.mediaUrlSource as AnyObject?
            break
            default:
                break
            }
        }
    }
    
    func comoApiGetSticker() {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let parameters = ["uuid": udid, "token": token]
        AF.request(ComoAPI.stickerList, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    let backendJson = JSON(response.value as Any)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        
                        self.stickerCollections.removeAllObjects()
                        
                        let result = backendJson["result"].dictionary!
                        let collections:Array = result["collection_list"]!.array!
                        for collection in collections {
                            
                            let stickerArray = NSMutableArray()
                            let stickerList:Array = collection["sticker_list"].array!
                            for dict in stickerList {
                                let sticker = Sticker(
                                    stickerId: Int("\(dict["id"])")!,
                                    image: "\(dict["image"])")
                                stickerArray.add(sticker)
                            }
                            let stickerGroup = StickerGroup(
                                groupId: Int("\(collection["id"])")!,
                                groupName: "\(collection["name"])",
                                groupList: stickerArray)
                            
                            self.stickerCollections.add(stickerGroup)
                            self.stickerCollections.add(stickerGroup)
                        }
                        
                        self.editorView.setStickers(stickers: self.stickerCollections)
                        
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                    
                case .failure(let error):
                    print("comoApiGetSticker error", error)
                }
        }
        
        
    }
    
    func comoApiGetDoodle() {
        let token = userDefaults.object(forKey: DefaultKeys.token) as! String
        let udid = userDefaults.object(forKey: DefaultKeys.uuid) as! String
        let lat = userDefaults.object(forKey: DefaultKeys.latitude) as! String
        let lng = userDefaults.object(forKey: DefaultKeys.longitude) as! String
        
        let urlString = "\(ComoAPI.doodleList)?token=\(token)&uuid=\(udid)&lat=\(lat)&lng=\(lat)"
        
        let parameters = ["uuid": udid, "token": token, "lat": lat, "lng": lng]
        AF.request(urlString, method: .get, parameters: parameters, encoder: JSONParameterEncoder.default, headers: nil , interceptor: nil)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    print("success")
                    let backendJson = JSON(response.value!)
                    print("comoApiGetDoodle", backendJson)
                    if checkStatusOK(statusCode: backendJson["status"].int!) {
                        
                        let result = backendJson["result"].dictionary!
                        let dodleList:Array = result["doodle_list"]!.array!
                        
                        let blankSticker = Doodle(id: 0, type: 0, imageStr: "", name: "", typeDisplay: "", isFullScreen: false, isSelected: false)
                        self.doodles.add(blankSticker)
                        
                        for dict in dodleList {
                            
                            let sticker = Doodle(
                                id: Int("\(dict["id"])")!,
                                type: Int("\(dict["type"])")!,
                                imageStr: "\(dict["image"])",
                                name: "\(dict["name"])",
                                typeDisplay: "\(dict["type_display"])",
                                isFullScreen:self.checkFullScreen(align: "\(dict["align_display"])"),
                                isSelected: false)
                            self.doodles.add(sticker)
                        }
                        
                        self.editorView.doodlesView.populateDoodles(doodles: self.doodles)
                    } else {
                        let errorMsg = backendJson["status_msg"].string!
                        alertWithTitle(title: "", message:errorMsg , viewController: self, toFocus:nil)
                    }
                case .failure(let error):
                    print("error")
                    
                }
        }
    }
    
    func checkFullScreen(align: String) -> Bool {
        if align == "CENTER" {
            return true
        }
        return false
    }
    
    struct DoodleTest {
        var fileName: String
        var isFull: Bool
    }
    func insertMoreDoodle() {
        
        let doodleTestList = [
            DoodleTest(fileName: "doodle_1.png", isFull: false),
            DoodleTest(fileName: "doodle_2.png", isFull: false),
            DoodleTest(fileName: "doodle_3.png", isFull: false),
            DoodleTest(fileName: "doodle_4.png", isFull: false),
            DoodleTest(fileName: "doodle_5.png", isFull: false),
            DoodleTest(fileName: "doodle_6.png", isFull: false),
            DoodleTest(fileName: "full_doodle_1.png", isFull: true),
            DoodleTest(fileName: "full_doodle_2.png", isFull: true)
        ]
        
        for doodleTest: DoodleTest in doodleTestList {
            let doodle = Doodle(
                id: 1,
                type: 1,
                imageStr: "",
                name: doodleTest.fileName,
                typeDisplay: "",
                isFullScreen:doodleTest.isFull,
                isSelected: false)
            doodle.image = UIImage(named: doodleTest.fileName)
            self.doodles.add(doodle)
        }
        
        print("insertMoreDoodle", self.doodles.count)
    }
}
