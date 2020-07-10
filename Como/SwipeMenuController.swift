//
//  SwipeMenuController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/6/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices

class SwipeMenuController: EZSwipeController , CLLocationManagerDelegate{
    override func setupView() {
        super.setupView()
        datasource = self
        navigationBarShouldNotExist = true
        
        self.updateUserLocation()
    }
    
    func updateUserLocation() {
        
        let locationServiceStatus = CLLocationManager.authorizationStatus()
        print("locationServiceStatus", locationServiceStatus)
        if (CLLocationManager.locationServicesEnabled()) {
            appLocationManager = CLLocationManager()
            appLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            appLocationManager.requestWhenInUseAuthorization()
            appLocationManager.delegate = self
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorized:
            print("authorized")
        case .authorizedWhenInUse:
            appLocationManager.startUpdatingLocation()
        case .denied:
            print("denied")
        case .notDetermined:
            print("not determined")
        case .restricted:
            print("restricted")
        case .authorizedAlways:
            print("authorizedAlways")
        @unknown default:
            print("default")
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        let currLatitude = newLocation!.coordinate.latitude
        let currLongitude = newLocation!.coordinate.longitude
        print("newLocation lat:\(currLatitude) lng:\(currLongitude)")
        userDefaults.set("\(currLatitude)", forKey: DefaultKeys.latitude)
        userDefaults.set("\(currLongitude)", forKey: DefaultKeys.longitude)
        appLocationManager.stopUpdatingLocation()
    }
}

extension SwipeMenuController: EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController] {
        
        let snapVC = storyboard!.instantiateViewController(withIdentifier: "SnapScreen") as! SnapViewController;
        
        let soriesVC = storyboard!.instantiateViewController(withIdentifier: "StoriesScreen") as! StoriesCollectionViewController;
        let navSoriesVC = UINavigationController(rootViewController: soriesVC)
        
//        let greenVC = UIViewController()
//        greenVC.view.backgroundColor = UIColor.greenColor()
        
        return [snapVC, navSoriesVC]
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }

        override var prefersStatusBarHidden: Bool {
            return false
        }
    func changedToPageIndex(_ index: Int) {
        // You can do anything from here, for now we'll just print the new index
        print("changedToPageIndex", index)
        _ = UIApplication.shared
        
        switch index {
        case SlidePage.snapPage:
            UIApplication.shared.isStatusBarHidden = true
            
        case SlidePage.storiesPage:
            UIApplication.shared.isStatusBarHidden = false
            
        default:
            return
        }
        
        
//        if index == SlidePage.storiesPage {
//            
//        }
    }
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        var title = ""
        if index == 0 {
            title = "Charmander"
        } else if index == 1 {
            title = "Squirtle"
        } else if index == 2 {
            title = "Bulbasaur"
        }
        
        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.default
        //        navigationBar.barTintColor = QorumColors.WhiteLight
        print(navigationBar.barTintColor as Any)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            let rightButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: Selector(("a")))
            rightButtonItem.tintColor = UIColor.black
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 1 {
            let rightButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.bookmarks, target: self, action: Selector(("a")))
            rightButtonItem.tintColor = UIColor.black
            
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: Selector(("a")))
            leftButtonItem.tintColor = UIColor.black
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 2 {
            let leftButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: Selector(("a")))
            leftButtonItem.tintColor = UIColor.black
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = nil
        }
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }
}
/*
class SwipeMenuController: UIViewController {

    @IBOutlet weak var menuScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let snapScreenVC = storyboard!.instantiateViewControllerWithIdentifier("SnapScreen") as! SnapViewController;
        let snapScreenFrame = view.frame;
        snapScreenVC.view.frame = snapScreenFrame;
        
        addChildViewController(snapScreenVC);
        self.menuScrollView!.addSubview(snapScreenVC.view)
        snapScreenVC.didMoveToParentViewController(self)
        
        
        
        let storiesCVC = storyboard!.instantiateViewControllerWithIdentifier("StoriesScreen") as! StoriesCollectionViewController;
        var frame = storiesCVC.view.frame;
        frame.origin.x = view.frame.size.width;
        storiesCVC.view.frame = frame;
        
        addChildViewController(storiesCVC);
        self.menuScrollView!.addSubview(storiesCVC.view)
        storiesCVC.didMoveToParentViewController(self)
        
        self.menuScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height);
        self.menuScrollView.pagingEnabled = true;
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

}*/
