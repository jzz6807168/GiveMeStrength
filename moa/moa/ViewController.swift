//
//  ViewController.swift
//  moa
//
//  Created by qq on 16/8/2.
//  Copyright © 2016年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit

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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "currentView" {
            switch String(change![NSKeyValueChangeNewKey]!) {
            case "2":
                
                NSNotificationCenter.defaultCenter() .addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
                if (self.loginView == nil) {
                    self.loginView = LoginView.init(frame: CGRectMake(0, 0, self.fwidth!, self.fheight!))
                }
                self.view .addSubview(self.loginView!)
                break
            case "3":
                
                self.view.frame = UIScreen.mainScreen().bounds
                self.view.backgroundColor = UIColor.init(colorLiteralRed: 0xf8/255.0, green: 0xf8/255.0, blue: 0xf8/255.0, alpha: 1)
                if (self.browserView == nil) {
                    self.browserView = BrowserView.init(frame: CGRectMake(0, self.y!, self.fwidth!, self.fheight!-self.y!))
                }
                self.view .addSubview(self.browserView!)
                
                break
            default:
                break
            }
        }
        self.view .exchangeSubviewAtIndex(0, withSubviewAtIndex: 1)
        
        switch String(change![NSKeyValueChangeOldKey]!) {
        case "1":
            deviceCheckView?.removeFromSuperview()
            break
        case "2":
            loginView?.removeFromSuperview()
            NSNotificationCenter.defaultCenter() .removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            break
            
        default:
            break
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != 0) {
            UIApplication.sharedApplication() .openURL(NSURL.init(string: "itms-services://?action=download-manifest&url=https://moa.xiditech.com/download/moa/moa.plist")!)
        }
    }
    
    func removeView(view:UIView) {
        view .removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view, typically from a nib.
        fwidth = UIScreen.mainScreen().bounds.size.width
        fheight = UIScreen.mainScreen().bounds.size.height
        y = UIApplication.sharedApplication() .statusBarFrame.size.height
        
        let cs = "changeView".UTF8String
        let buffer = UnsafeMutablePointer<Int8>(cs)
        
        Config.sharedConfig() .addObserver(self, forKeyPath: "currentView", options: [.New,.Old], context: buffer)
        
        deviceCheckView = DeviceCheckView.init(frame: UIScreen.mainScreen().bounds)
        self.view .addSubview(deviceCheckView!)
        
        let updateAvailable:Bool = Config.sharedConfig().updateMoa()

        if (updateAvailable == true) {
            let updateAlert:UIAlertView = UIAlertView.init(title: "MOA更新", message: "MOA新版本已经发布，是否更新？", delegate: self , cancelButtonTitle: "不更新" , otherButtonTitles: "更新")
            updateAlert.show()

        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*ipad 不旋转。*/
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func keyboardWillShow(note:NSNotification)  {
        let userInfo:AnyObject = note.userInfo!
        let kbSize:CGSize  = (userInfo[UIKeyboardFrameBeginUserInfoKey]!?.CGRectValue().size)!
        loginView?.keyboardShow(kbSize.height)
    }


}

