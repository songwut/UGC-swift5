//
//  AccountSettingTableViewController.swift
//  Como
//
//  Created by Songwut Maneefun on 6/1/2559 BE.
//  Copyright © 2559 Conicle.Co.,Ltd. All rights reserved.
//

import UIKit
import FBSDKLoginKit

private let reuseIdentifier = "SettingCell"
private let cellHeight = 80

class AccountSettingTableViewController: UITableViewController, SettingCellDelegate, SettingFooterViewDelegate {

    @IBOutlet weak var settingFooterView: SettingFooterView!
    
    private var settings = NSMutableArray()
    private var cellSize = CGSize.zero
    private var selectedCell: SettingCell!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingFooterView.delegate = self
        self.cellSize = CGSize(width: view.frame.size.width, height: CGFloat(cellHeight))
        
        let already = "Already Set"
        let notSet = "Not Set"
        let notConnect = "Not Connect"
        
        let userName = userDefaults.object(forKey: DefaultKeys.username) as! String
        let fullName = userDefaults.object(forKey: DefaultKeys.fullName) as! String
        let phoneNumber = userDefaults.object(forKey: DefaultKeys.phoneNumber) as! String
        let fbStatus = userDefaults.object(forKey: DefaultKeys.fbConnectStatus) as! String
        let email = userDefaults.object(forKey: DefaultKeys.email) as! String
        let birthday = userDefaults.object(forKey: DefaultKeys.birthday) as! String
        
        self.settings = [
            SettingModel("Como ID", "@\(userName)", SettingTag.username),
            SettingModel("Full Name", fullName, SettingTag.fullName),
            SettingModel("Phone Number", self.checkText(text: phoneNumber, notSet), SettingTag.phoneNumner),
            SettingModel("Email", email, SettingTag.email),
            SettingModel("Password", already, SettingTag.password),
            SettingModel("Birthday", self.checkText(text: birthday, notSet), SettingTag.birthday),
            SettingModel("Facebook Connect", self.checkText(text: fbStatus, notConnect), SettingTag.facebook)
        ]
        self.tableView.reloadData()
    }
    
    func checkText(text: String, _ placeHolderStr: String) -> String {
        if (text).isEmpty { return placeHolderStr }
        return text
    }

    @IBAction func navBackButtonPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: {});
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! SettingCell
        let setting = (self.settings[indexPath.item] as! SettingModel)
        
        cell.title?.text = setting.title
        cell.detail?.text = setting.detail
        cell.tag = setting.tag
        cell.indexPath = indexPath
        cell.delegate = self
        cell.setSelected(true, animated: true)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellSize.height
    }
    
    func protocolSettingCell(cell: SettingCell, didPressedButton:UIButton, indexPath: NSIndexPath) {
        
        //cell.setSelected(true, animated: true)
        
        deselectAllCellInTableView(tableView: self.tableView, ignoreIndexPath: indexPath)
        
        self.selectedCell = tableView.cellForRow(at: indexPath as IndexPath) as? SettingCell
        self.selectedCell.view.backgroundColor = UIColor(hex: "#EBEFEF")
        
        print("selectedCell.tag:",selectedCell.tag)
        
        switch self.selectedCell.tag {
        case SettingTag.username,
             SettingTag.fullName,
             SettingTag.email,
             SettingTag.phoneNumner :
            self.performSegue(withIdentifier: "OpenSettingDetailScreen", sender: self)
            
        case SettingTag.password :
            //TODO: require old password
            return
        case SettingTag.birthday :
            return
        case SettingTag.facebook :
            return
        default:
            return
        }
    }
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! SettingCell
        selectedCell.view.backgroundColor = UIColor(hex: "#FFFFFF")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect = tableView.cellForRowAtIndexPath(indexPath) as! SettingCell
        cellToDeSelect.view.backgroundColor = UIColor(hex: "#EBEFEF")
    }
    */
    func deselectAllCellInTableView(tableView: UITableView, ignoreIndexPath: NSIndexPath) {
        
        for i in 0 ..< self.settings.count {
            let indexPath = NSIndexPath(item: i, section: 0)
            if indexPath != ignoreIndexPath {
                let cell = tableView.cellForRow(at: NSIndexPath(item: i, section: 0) as IndexPath) as! SettingCell
                cell.view.backgroundColor = UIColor(hex: "#FFFFFF")
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - SettingFooterViewDelegate
    func protocolSettingFooterViewDidLogout(sender: UIButton) {
        
        //TODO: logout
        
        let alert = UIAlertController(title: "Logout", message: "Do you really want to logout?", preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive ,handler: {_ in
            
            userDefaults.set(false, forKey: DefaultKeys.isLogin)
            LoginManager().logOut()
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeVC = mainStoryboard.instantiateViewController(withIdentifier: "WelcomeScreen") as! WelcomeViewController
            let nav = UINavigationController(rootViewController: welcomeVC)
            UIApplication.shared.keyWindow?.rootViewController = nav;
            
        });
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel ,handler: nil);
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion:nil)
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "OpenSettingDetailScreen" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let settingDetailVC =  segue.destination as! SettingDetailViewController
            settingDetailVC.settingTag = self.selectedCell.tag
        }
    }

}
