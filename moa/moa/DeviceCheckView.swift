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
        kv = Config .shared().kv
        let cd:UIDevice = UIDevice.current
        uuid = cd.identifierForVendor?.uuidString.lowercased()
        mac = Config .shared() .trim2mac(uuid)
        kv?.setObject(mac!, forKey: "mac" as NSCopying)
        
        //背景色
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.init(colorLiteralRed: 0x5f/255.0, green: 0x5e/255.0, blue: 0x65/255.0, alpha: 1).cgColor]
        self.layer .insertSublayer(gradient, at: 0)
        
        //背景图片
        let bgimg:UIImageView = UIImageView.init(image: UIImage.init(named: "logo-index"))
        bgimg.frame = CGRect(x: fwidth/2-52, y: fheight/2-100, width: 104, height: 200)
        self .addSubview(bgimg)
        
        //进度显示器
        indicator = UIActivityIndicatorView.init(frame: CGRect(x: fwidth/2-20, y: fheight/2, width: 40, height: 40))
        indicator?.activityIndicatorViewStyle = .whiteLarge
        indicator?.startAnimating()
        indicator?.hidesWhenStopped = true
        self .addSubview(indicator!)
        
        //两个隐藏的按钮
        saveDeviceButton = UIButton.init(type: .custom)
        saveDeviceButton?.setTitle("申请设备认证", for: UIControlState())
        saveDeviceButton?.frame = CGRect(x: fwidth/2-65, y: fheight/2+3, width: 130, height: 40)
        saveDeviceButton?.isHidden = true
        self .addSubview(saveDeviceButton!)
        saveDeviceButton?.addTarget(self, action: #selector(DeviceCheckView.deviceSave), for: .touchUpInside)
        
        recheckButton = UIButton.init(type: .custom)
        recheckButton?.setTitle("设备此认证", for: UIControlState())
        recheckButton?.frame = CGRect(x: fwidth/2-50, y: fheight/2+3, width: 100, height: 40)
        recheckButton?.isHidden = true
        self .addSubview(recheckButton!)
        recheckButton?.addTarget(self, action: #selector(DeviceCheckView.deviceCheck), for: .touchUpInside)
        
        statLabel = UILabel.init(frame: CGRect(x: 0, y: fheight/2-55, width: fwidth, height: 50))
        statLabel?.font = UIFont.boldSystemFont(ofSize: statLabel!.font.pointSize)
        statLabel?.textAlignment = .center
        statLabel?.textColor = UIColor.red
        statLabel?.text = "正在认证设备"
        self .addSubview(statLabel!)
        
        idLabel = UILabel.init(frame: CGRect(x: 0, y: fheight/2-30, width: fwidth, height: 50))
        idLabel?.textAlignment = .center
        idLabel?.textColor = UIColor.red
        idLabel?.text = "设备号：" + mac!
        idLabel?.isHidden = true
        self .addSubview(idLabel!)
        
        let copyright:UILabel = UILabel.init(frame: CGRect(x: 0, y: fheight-80, width: fwidth, height: 40))
        copyright.textAlignment = .center
        copyright.textColor = UIColor.white
        let currentDate:Date = Date()
        let calendar:Calendar = Calendar.current
        let components:DateComponents = (calendar as NSCalendar) .components([.year,.month,.day], from: currentDate) // Get necessary date components
        
        let string1:String = "©"
        let yearString = String(describing: components.year)
        let string2:String = " Powered by xidibuy.com"
        
        copyright.text = string1 + yearString + string2
        self .addSubview(copyright)
        
        DispatchQueue.main.async {
            self .deviceCheck()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*check和save的数据包是一样的，只是地址不一样。*/
    func buildDeviceRequestWithUrl(_ url:String) -> NSMutableURLRequest {
        let cd:UIDevice = UIDevice.current
        let sign:String = Config.shared().md5(mac! + ((kv? .object(forKey: "_DATA_XIDIMOA_SIGN"))! as! String))
        let nameString:String = cd.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let modelString:String = cd.model.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemNameString:String = cd.systemName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemVersionString:String = cd.systemVersion.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let dataString:String = "uuid=" + uuid! + "&mac=" + mac! + "&sign=" + sign + "&name=" + nameString + "&model=" + modelString + "&systemName=" + systemNameString + "n" + systemVersionString
        let postData:Data = dataString .data(using: String.Encoding.utf8)!
        
        let request:NSMutableURLRequest = NSMutableURLRequest.init(url: URL.init(string: url)!)
        
        request.httpMethod = "POST"
        request.setValue(String(postData.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        return request
    }
    
    func deviceCheck() {
        statLabel?.text = "正在认证设备"
        indicator?.startAnimating()
        recheckButton?.isHidden = true
        saveDeviceButton?.isHidden = true
        recheckButton?.isEnabled = false
        
        NSURLConnection .sendAsynchronousRequest(self.buildDeviceRequestWithUrl((kv? .object(forKey: "_URL_AUTH_DEVICE"))! as!String) as URLRequest, queue: OperationQueue.init(), completionHandler:{
                (response, data, error) -> Void in
                DispatchQueue.main.async {
                    self.indicator?.stopAnimating()
                    if ((error) != nil) {
                        //Handle Error here
                        self.statLabel?.text = "网络连接出错，请稍后重试。"
                        self.recheckButton?.isHidden = false
                        print(error?.localizedDescription as Any)
                        
                    }else{
                        //Handle data in NSData type
                        
                        do {
                            let jsonObjects:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                            let jsonDic = jsonObjects as!Dictionary<String, Any>
                            let code = jsonDic["code"] as!NSNumber
                    
                            if code == 0 {
                                //登录成功
                                self.statLabel?.text = "设备已认证，正在登录。"
                                UserDefaults.standard .set(false, forKey: "waitingForBind")
                                UserDefaults.standard .synchronize()
                                
                                Config.shared() .setValue("2", forKey: "currentView")
                                
                            }else{
                                self.idLabel?.isHidden = false
                                if UserDefaults.standard .bool(forKey: "waitingForBind") {
                                    //waiting for bind
                                    self.statLabel?.text = "设备认证审核中…"
                                    self.recheckButton?.isHidden = false
                                }else{
                                    self.statLabel?.text = "设备未认证"
                                    self.saveDeviceButton?.isHidden = false
                                }
                            }
                            
                        } catch {
                            // deal with error
                            self.statLabel?.text = "解析服务器数据错误，请稍后重试。"
                            self.recheckButton?.isHidden = false
                        }
                    }
                    
                    self.recheckButton?.isEnabled = true
                }

            })
    }
    
    func deviceSave() {
        statLabel?.text = "正在注册设备:\n" + mac!
        indicator?.startAnimating()
        recheckButton?.isHidden = true
        saveDeviceButton?.isHidden = true
        saveDeviceButton?.isEnabled = false
        
        NSURLConnection .sendAsynchronousRequest(self.buildDeviceRequestWithUrl((kv? .object(forKey: "_URL_AUTH_DEVICE_APPLY"))! as! String) as URLRequest, queue: OperationQueue.init(), completionHandler:{
            (response, data, error) -> Void in
            DispatchQueue.main.async {
                self.indicator?.stopAnimating()
                if ((error) != nil) {
                    //Handle Error here
                    self.statLabel?.text = "网络连接出错，请稍后重试。"
                    self.saveDeviceButton?.isHidden = false
                    print(error?.localizedDescription as Any)
                    
                }else{
                    //Handle data in NSData type
                    do {
                        let jsonObjects:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                        let jsonDic = jsonObjects as!Dictionary<String,Any>
                        let code = jsonDic["code"] as!NSNumber
                        if code == 0 {
                            //登录成功
                            self.statLabel?.text = "设备注册成功，请等待审核。"
                            self.recheckButton?.isHidden = false
                            UserDefaults.standard .set(true, forKey: "waitingForBind")
                            UserDefaults.standard .synchronize()
                            
                        }else{
                            self.statLabel?.text = "注册设备失败。"
                            self.saveDeviceButton?.isHidden = false
                        }
                        
                    } catch {
                        // deal with error
                        self.statLabel?.text = "解析服务器数据错误，请稍后重试。"
                        self.saveDeviceButton?.isHidden = false
                    }
                }
                
                self.saveDeviceButton?.isEnabled = true
            }
            
        })
    }
}
