//
//  ViewController.swift
//  MOA
//
//  Created by qq on 17/1/13.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import IDZSwiftCommonCrypto

class ViewController: UIViewController, UIAlertViewDelegate {
    
    var fwidth : CGFloat?
    var fheight : CGFloat?
    var y : CGFloat?
    var token : String?
    var host : String?
    var statLabel : UILabel?    
    
    //切换几个view
    var loginView : LoginView?
    var deviceCheckView : DeviceCheckView?
    var browserView : BrowserView?
    var oldKey : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        fwidth = UIScreen.main.bounds.size.width
        fheight = UIScreen.main.bounds.size.height
        y = UIApplication.shared .statusBarFrame.size.height
        
        deviceCheckView = DeviceCheckView.init(frame: UIScreen.main.bounds)
        self.view .addSubview(deviceCheckView!)
        
        let updateAvailable:Bool = Config.sharedConfig.updateMoa()
        
        if (updateAvailable == true) {
            let updateAlert:UIAlertView = UIAlertView.init(title: "MOA更新", message: "MOA新版本已经发布，是否更新？", delegate: self , cancelButtonTitle: "不更新" , otherButtonTitles: "更新")
            updateAlert.show()
        }
        
        //通知中心
        NotificationCenter.default.addObserver(self, selector: #selector(changeView), name: NSNotification.Name(rawValue: "currentView"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*ipad 不旋转。*/
    override var shouldAutorotate : Bool {
        return false
    }
    
    func keyboardWillShow(_ note:Notification)  {
        let userInfo:AnyObject = note.userInfo! as AnyObject
        let kbSize:CGSize  = ((userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue.size)
        loginView?.keyboardShow(kbSize.height)
    }
    
    func changeView(noti:Notification) {
        switch noti.object as!String {
        case "2":            
            NotificationCenter.default .addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            if (self.loginView == nil) {
                self.loginView = LoginView.init(frame: CGRect(x: 0, y: 0, width: self.fwidth!, height: self.fheight!))
            }
            self.view .addSubview(self.loginView!)
            break
        case "3":
            
            self.view.frame = UIScreen.main.bounds
            self.view.backgroundColor = UIColor.init(colorLiteralRed: 0xf8/255.0, green: 0xf8/255.0, blue: 0xf8/255.0, alpha: 1)
            if (self.browserView == nil) {
                self.browserView = BrowserView.init(frame: CGRect(x: 0, y: self.y!, width: self.fwidth!, height: self.fheight!-self.y!))
            }
            self.view .addSubview(self.browserView!)
            
            break
        default:
            break
        }
        self.view .exchangeSubview(at: 0, withSubviewAt: 1)

        if oldKey == "1" {
            deviceCheckView?.removeFromSuperview()
        }else if oldKey == "2"{
            loginView?.removeFromSuperview()
            NotificationCenter.default .removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
        oldKey = noti.object as?String
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if (buttonIndex != 0) {
            UIApplication.shared .openURL(URL.init(string: "itms-services://?action=download-manifest&url=https://moa.xiditech.com/download/moa/moa.plist")!)
        }
    }
    
    func removeView(_ view:UIView) {
        view .removeFromSuperview()
    }

}

