//
//  DeviceCheckView.swift
//  MOA
//
//  Created by qq on 17/1/17.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import IDZSwiftCommonCrypto
import SwiftyJSON

class DeviceCheckView: UIView {
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
        let cd:UIDevice = UIDevice.current
        uuid = cd.identifierForVendor?.uuidString.lowercased()
        mac = Config.sharedConfig.trimToMac(uuid!)
        UserDefaults.standard .set(mac, forKey: "mac")
        UserDefaults.standard .synchronize()
        
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
        saveDeviceButton?.setTitle("申请设备认证", for: UIControlState.normal)
        saveDeviceButton?.frame = CGRect(x: fwidth/2-65, y: fheight/2+3, width: 130, height: 40)
        saveDeviceButton?.isHidden = true
        self .addSubview(saveDeviceButton!)
        saveDeviceButton?.addTarget(self, action: #selector(deviceSave), for: .touchUpInside)
        
        recheckButton = UIButton.init(type: .custom)
        recheckButton?.setTitle("设备此认证", for: UIControlState.normal)
        recheckButton?.frame = CGRect(x: fwidth/2-50, y: fheight/2+3, width: 100, height: 40)
        recheckButton?.isHidden = true
        self .addSubview(recheckButton!)
        recheckButton?.addTarget(self, action: #selector(deviceCheck), for: .touchUpInside)
        
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
        let components:DateComponents = (calendar as NSCalendar) .components([.year,.month,.day], from: currentDate)
        
        let string1:String = "©"
        let yearString = String(describing: components.year)
        let string2:String = " Powered by xidibuy.com"
        
        copyright.text = string1 + yearString + string2
        self .addSubview(copyright)
        
        self .deviceCheck()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
/*check和save的数据包是一样的，只是地址不一样。*/
    func deviceCheck() {
        statLabel?.text = "正在认证设备"
        indicator?.startAnimating()
        recheckButton?.isHidden = true
        saveDeviceButton?.isHidden = true
        recheckButton?.isEnabled = false
        
        let cd:UIDevice = UIDevice.current
        let input:String = mac! + "b62171O9j14mz5RT"
        let sign:String = hexString(fromArray: Digest(algorithm: .md5).update(string:input)?.final() ?? []).lowercased()
        let nameString:String = cd.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let modelString:String = cd.model.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemNameString:String = cd.systemName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemVersionString:String = cd.systemVersion.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        
        let dict = ["uuid":uuid!, "mac":mac!, "sign":sign, "name":nameString, "model":modelString, "systemName":systemNameString + "n" + systemVersionString]
        NetworkManager.sharedInstance.postRequest(urlString: "http://moa.xiditech.com/device/check", params: dict as [String : AnyObject]?, success: { (successResult) in
            let json = JSON(successResult)
            self.indicator?.stopAnimating()
            self.recheckButton?.isEnabled = true;
            if json["code"] == 0 {
                self.statLabel?.text = "设备已认证，正在登录。"
                UserDefaults.standard .set(false, forKey: "waitingForBind")
                UserDefaults.standard .synchronize()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentView"), object: "2")
                
            }else {
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
        }, failture: { (errorResult) in
            self.indicator?.stopAnimating()
            self.statLabel?.text = "网络连接出错，请稍后重试。"
            self.recheckButton?.isHidden = false
            self.recheckButton?.isEnabled = true;
            print(errorResult)
        })
    }
    
    func deviceSave() {
        statLabel?.text = "正在注册设备:\n" + mac!
        indicator?.startAnimating()
        recheckButton?.isHidden = true
        saveDeviceButton?.isHidden = true
        saveDeviceButton?.isEnabled = false
        
        let cd:UIDevice = UIDevice.current
        let input:String = mac! + "b62171O9j14mz5RT"
        let sign:String = hexString(fromArray: Digest(algorithm: .md5).update(string:input)?.final() ?? []).lowercased()
        let nameString:String = cd.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let modelString:String = cd.model.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemNameString:String = cd.systemName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let systemVersionString:String = cd.systemVersion.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let deviceToken:String! = UserDefaults.standard .string(forKey: "deviceToken")
        
        let dict = ["uuid":uuid!, "mac":mac!, "sign":sign, "name":nameString, "model":modelString, "systemName":systemNameString + "n" + systemVersionString, "deviceToken":deviceToken]
        
        NetworkManager.sharedInstance.postRequest(urlString: "http://moa.xiditech.com/device/save", params: dict as [String : AnyObject]?, success: { (successResult) in
            let json = JSON(successResult)
            self.indicator?.stopAnimating()
            self.saveDeviceButton?.isEnabled = true
            if json["code"] == 0 {
                self.statLabel?.text = "设备注册成功，请等待审核。"
                self.recheckButton?.isHidden = false
                UserDefaults.standard .set(true, forKey: "waitingForBind")
                UserDefaults.standard .synchronize()
                
            }else{
                self.statLabel?.text = "注册设备失败。"
                self.saveDeviceButton?.isHidden = false
            }
            
        }, failture: { (errorResult) in
            self.indicator?.stopAnimating()
            self.saveDeviceButton?.isEnabled = true
            self.statLabel?.text = "网络连接出错，请稍后重试。"
            self.saveDeviceButton?.isHidden = false
            print(errorResult)
        })
    }

}
