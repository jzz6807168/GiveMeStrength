//
//  DeviceCheckView.swift
//  moa
//
//  Created by qq on 16/8/4.
//  Copyright © 2016年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit

class DeviceCheckView: UIView {
    var kv: NSMutableDictionary?
    var uuid: String?
    var mac: String?
    var indicator: UIActivityIndicatorView?
    var saveDeviceButton: UIButton?
    var recheckButton: UIButton?
    var statLabel: UILabel?
    var idLabel: UILabel?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let fwidth:CGFloat = frame.size.width;
        let fheight:CGFloat = frame.size.height;
        kv = Config .sharedConfig().kv
        let cd:UIDevice = UIDevice.currentDevice()
        uuid = cd.identifierForVendor?.UUIDString.lowercaseString
        mac = Config .sharedConfig() .trim2mac(uuid)
        kv?.setObject(mac!, forKey: "mac")
        
        //背景色
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.mainScreen().bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.init(colorLiteralRed: 0x5f/255.0, green: 0x5e/255.0, blue: 0x65/255.0, alpha: 1).CGColor]
        self.layer .insertSublayer(gradient, atIndex: 0)
        
        //背景图片
        let bgimg:UIImageView = UIImageView.init(image: UIImage.init(named: "logo-index"))
        bgimg.frame = CGRectMake(fwidth/2-52, fheight/2-100, 104, 200)
        self .addSubview(bgimg)
        
        //进度显示器
        indicator = UIActivityIndicatorView.init(frame: CGRectMake(fwidth/2-20, fheight/2, 40, 40))
        indicator?.activityIndicatorViewStyle = .WhiteLarge
        indicator?.startAnimating()
        indicator?.hidesWhenStopped = true
        self .addSubview(indicator!)
        
        //两个隐藏的按钮
        saveDeviceButton = UIButton.init(type: .Custom)
        saveDeviceButton?.setTitle("申请设备认证", forState: .Normal)
        saveDeviceButton?.frame = CGRectMake(fwidth/2-65, fheight/2+3, 130, 40)
        saveDeviceButton?.hidden = true
        self .addSubview(saveDeviceButton!)
        saveDeviceButton?.addTarget(self, action: #selector(DeviceCheckView.deviceSave), forControlEvents: .TouchUpInside)
        
        recheckButton = UIButton.init(type: .Custom)
        recheckButton?.setTitle("设备此认证", forState: .Normal)
        recheckButton?.frame = CGRectMake(fwidth/2-50, fheight/2+3, 100, 40)
        recheckButton?.hidden = true
        self .addSubview(recheckButton!)
        recheckButton?.addTarget(self, action: #selector(DeviceCheckView.deviceCheck), forControlEvents: .TouchUpInside)
        
        statLabel = UILabel.init(frame: CGRectMake(0, fheight/2-55, fwidth, 50))
        statLabel?.font = UIFont.boldSystemFontOfSize(statLabel!.font.pointSize)
        statLabel?.textAlignment = .Center
        statLabel?.textColor = UIColor.redColor()
        statLabel?.text = "正在认证设备"
        self .addSubview(statLabel!)
        
        idLabel = UILabel.init(frame: CGRectMake(0, fheight/2-30, fwidth, 50))
        idLabel?.textAlignment = .Center
        idLabel?.textColor = UIColor.redColor()
        idLabel?.text = "设备号：" + mac!
        idLabel?.hidden = true
        self .addSubview(idLabel!)
        
        let copyright:UILabel = UILabel.init(frame: CGRectMake(0, fheight-80, fwidth, 40))
        copyright.textAlignment = .Center
        copyright.textColor = UIColor.whiteColor()
        let currentDate:NSDate = NSDate()
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let components:NSDateComponents = calendar .components([.Year,.Month,.Day], fromDate: currentDate) // Get necessary date components
        
        let string1:String = "©"
        let yearString = String(components.year)
        let string2:String = " Powered by xidibuy.com"
        
        copyright.text = string1 + yearString + string2
        self .addSubview(copyright)
        
        dispatch_async(dispatch_get_main_queue()) {
            self .deviceCheck()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*check和save的数据包是一样的，只是地址不一样。*/
    func buildDeviceRequestWithUrl(url:String) -> NSMutableURLRequest {
        let cd:UIDevice = UIDevice.currentDevice()
        let sign:String = Config.sharedConfig().md5(mac! + ((kv? .objectForKey("_DATA_XIDIMOA_SIGN"))! as! String))
        let nameString:String = cd.name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let modelString:String = cd.model.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let systemNameString:String = cd.systemName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let systemVersionString:String = cd.systemVersion.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        let dataString:String = "uuid=" + uuid! + "&mac=" + mac! + "&sign=" + sign + "&name=" + nameString + "&model=" + modelString + "&systemName=" + systemNameString + "n" + systemVersionString
        let postData:NSData = dataString .dataUsingEncoding(NSUTF8StringEncoding)!
        
        let request:NSMutableURLRequest = NSMutableURLRequest.init(URL: NSURL.init(string: url)!)
        
        request.HTTPMethod = "POST"
        request.setValue(String(postData.length), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        return request
    }
    
    func deviceCheck() {
        statLabel?.text = "正在认证设备"
        indicator?.startAnimating()
        recheckButton?.hidden = true
        saveDeviceButton?.hidden = true
        recheckButton?.enabled = false
        
        NSURLConnection .sendAsynchronousRequest(self.buildDeviceRequestWithUrl((kv? .objectForKey("_URL_AUTH_DEVICE"))! as!String), queue: NSOperationQueue.init(), completionHandler:{
                (response, data, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator?.stopAnimating()
                    if ((error) != nil) {
                        //Handle Error here
                        self.statLabel?.text = "网络连接出错，请稍后重试。"
                        self.recheckButton?.hidden = false
                        print(error)
                        
                    }else{
                        //Handle data in NSData type
                        
                        do {
                            let jsonObjects:AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    
                            if (jsonObjects .objectForKey("code") as! NSNumber) == 0 {
                                //登录成功
                                self.statLabel?.text = "设备已认证，正在登录。"
                                NSUserDefaults .standardUserDefaults() .setBool(false, forKey: "waitingForBind")
                                NSUserDefaults .standardUserDefaults() .synchronize()
                                
                                Config.sharedConfig() .setValue("2", forKey: "currentView")
                                
                            }else{
                                self.idLabel?.hidden = false
                                if NSUserDefaults .standardUserDefaults() .boolForKey("waitingForBind") {
                                    //waiting for bind
                                    self.statLabel?.text = "设备认证审核中…"
                                    self.recheckButton?.hidden = false
                                }else{
                                    self.statLabel?.text = "设备未认证"
                                    self.saveDeviceButton?.hidden = false
                                }
                            }
                            
                        } catch {
                            // deal with error
                            self.statLabel?.text = "解析服务器数据错误，请稍后重试。"
                            self.recheckButton?.hidden = false
                        }
                    }
                    
                    self.recheckButton?.enabled = true
                }

            })
    }
    
    func deviceSave() {
        statLabel?.text = "正在注册设备:\n" + mac!
        indicator?.startAnimating()
        recheckButton?.hidden = true
        saveDeviceButton?.hidden = true
        saveDeviceButton?.enabled = false
        
        NSURLConnection .sendAsynchronousRequest(self.buildDeviceRequestWithUrl((kv? .objectForKey("_URL_AUTH_DEVICE_APPLY"))! as! String), queue: NSOperationQueue.init(), completionHandler:{
            (response, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.indicator?.stopAnimating()
                if ((error) != nil) {
                    //Handle Error here
                    self.statLabel?.text = "网络连接出错，请稍后重试。"
                    self.saveDeviceButton?.hidden = false
                    print(error)
                    
                }else{
                    //Handle data in NSData type
                    do {
                        let jsonObjects:AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                        if (jsonObjects .objectForKey("code") as! NSNumber) == 0 {
                            //登录成功
                            self.statLabel?.text = "设备注册成功，请等待审核。"
                            self.recheckButton?.hidden = false
                            NSUserDefaults .standardUserDefaults() .setBool(true, forKey: "waitingForBind")
                            NSUserDefaults .standardUserDefaults() .synchronize()
                            
                        }else{
                            self.statLabel?.text = "注册设备失败。"
                            self.saveDeviceButton?.hidden = false
                        }
                        
                    } catch {
                        // deal with error
                        self.statLabel?.text = "解析服务器数据错误，请稍后重试。"
                        self.saveDeviceButton?.hidden = false
                    }
                }
                
                self.saveDeviceButton?.enabled = true
            }
            
        })
    }
}
