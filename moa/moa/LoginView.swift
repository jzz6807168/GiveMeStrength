//
//  LoginView.swift
//  MOA
//
//  Created by qq on 17/1/18.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import SwiftyJSON
import IDZSwiftCommonCrypto

class LoginView: UIView {
    var bgimg : UIImageView?
    var stat : UILabel?
    var name : UITextField?
    var password : UITextField?
    var buttonMarginBottom: CGFloat?    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor .init(colorLiteralRed: 0xf1/255.0, green: 0xf1/255.0, blue: 0xf1/255.0, alpha: 1)
        self.create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create() {
        self.isHidden = true
        let fwidth:CGFloat = frame.size.width;
        let fheight:CGFloat = frame.size.height;
        let mwidth:CGFloat = fwidth > 414 ? 414 : fwidth//对于iPhone6plus以及以下分辨率的都是全屏，其他的按最大尺寸。
        
        //背景图片
        bgimg = UIImageView.init(image: UIImage.init(named: "logo"))
        bgimg?.frame = CGRect(x: (fwidth-127.5)/2, y: fheight/2-150, width: 127.5, height: 43)
        self .addSubview(bgimg!)
        
        //显示状态
        stat = UILabel()
        stat?.frame = CGRect(x: (fwidth-mwidth)/2, y: fheight/2-50-0.5-40, width: mwidth, height: 40)
        stat?.text = "用户名/密码不匹配，请重试。"
        stat?.textColor = UIColor.red
        stat?.textAlignment = .center
        stat?.isHidden = true
        self .addSubview(stat!)
        
        //两个input
        name = UITextField()
        name?.frame = CGRect(x: (fwidth-mwidth)/2, y: fheight/2-50-0.5, width: mwidth, height: 50)
        name?.backgroundColor = UIColor.white
        name?.leftViewMode = .always
        name?.leftView = UIImageView.init(image: UIImage.init(named: "ic_login_user"))
        name?.clearButtonMode = .whileEditing
        name?.placeholder = "OA账号"
        self .addSubview(name!)
        
        password = UITextField()
        password?.frame = CGRect(x: (fwidth-mwidth)/2, y: fheight/2+0.5, width: mwidth, height: 50)
        password?.isSecureTextEntry = true
        password?.clearButtonMode = .whileEditing
        password?.backgroundColor = UIColor.white
        password?.leftViewMode = .always
        password?.leftView = UIImageView.init(image: UIImage.init(named: "ic_login_pass"))
        password?.placeholder = "OA密码"
        self .addSubview(password!)
        
        //一个按钮
        let submit:UIButton = UIButton.init(type: .custom)
        submit.setTitle("登录", for: UIControlState.normal)
        submit.setTitleColor(UIColor.white, for: UIControlState.normal)
        submit.frame = CGRect(x: (fwidth-mwidth)/2+20, y: fheight/2+80, width: mwidth-40, height: 50)
        submit.backgroundColor = UIColor .init(colorLiteralRed: 0x0d/255.0, green: 0xc6/255.0, blue: 0xa6/255.0, alpha: 1)
        submit.titleLabel?.font = UIFont .systemFont(ofSize: 20.0)
        submit.addTarget(self, action: #selector(login), for: .touchUpInside)
        self .addSubview(submit)
        
        buttonMarginBottom = 0.0
        
        self.tokenLogin()
    }
    
    func tokenLogin() {
        if (UserDefaults.standard .string(forKey: "token") != nil) {
            //如果token不为空，发送请求。
            self.showMsg("正在用本地token登录")
            let requestUrlStr:String = UserDefaults.standard .object(forKey: "token")! as! String
            
            let dict = ["token": requestUrlStr]
            NetworkManager.sharedInstance.postRequest(urlString: "http://moa.xiditech.com/passport/check", params: dict as [String : AnyObject]?, success: { (successResult) in
                let json = JSON(successResult)
                if json["code"] == 0 {
                    self .showMsg("token登录成功，正在跳转。")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentView"), object: "3")
                    return
                }else{

                }
            }, failture: { (errorResult) in
                
            })
            self.stat?.text = nil
            self.isHidden = false
        }else{
            self.stat?.text = nil
            self.isHidden = false
        }
    }
    
    func login() {
        if ((name?.text?.lengthOfBytes(using: String.Encoding.utf8))! > 0 && (password?.text?.lengthOfBytes(using: String.Encoding.utf8))! > 0) {
            let macStr:String = UserDefaults.standard .object(forKey: "mac")! as! String
            
            let key = arrayFrom(string: "j14mz5RT")
            let plainText = password?.text
            
            let cryptor = Cryptor(operation:.encrypt, algorithm:.des, options:.PKCS7Padding, key:key, iv:key)
            let cipherText = cryptor.update(string: plainText!)?.final()
            print(hexString(fromArray: cipherText!, uppercase: false))
            
            let passwordStr:String = hexString(fromArray: cipherText!, uppercase: false)
            
            let dict = ["mac":macStr, "password":passwordStr]
            NetworkManager.sharedInstance.postRequest(urlString: "http://moa.xiditech.com/passport/sign", params: dict as [String : AnyObject]?, success: { (successResult) in
                let json = JSON(successResult)
                if json["code"] == 0 {
                    //保存token.
                    let value = json["data"]["token"]
                    let token = value.description
                    UserDefaults.standard .set(token, forKey: "token")
                    UserDefaults.standard .synchronize()
                    //显示browser
                    self .showMsg("登录成功，正在跳转。")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentView"), object: "3")
                }else{
                    self .showMsg("登录失败，用户名密码错误!")
                }
            }, failture: { (errorResult) in
                self .showMsg("网络连接出错，请稍后重试。")
            })
        }
    }
    
    func showMsg(_ msg:String) {
        stat?.text = msg
        stat?.isHidden = false
    }
    
    func keyboardShow(_ kbheight:CGFloat) {
        //看看keyboard是否覆盖住button
        if (buttonMarginBottom!<kbheight && self.frame.origin.y>=0) {
            //向上移动frame
            UIView .beginAnimations(nil, context: nil)
            UIView .setAnimationDuration(0.3)
            
            var rect:CGRect = self.frame
            rect.origin.y -= UIScreen.main.bounds.height <= 480 ? 240.0-buttonMarginBottom! : (CGFloat(kbheight)-buttonMarginBottom!+5)-100
            self.frame = rect
            if UIScreen.main.bounds.height < 600 {
                bgimg?.isHidden = true
            }
        
            UIView .commitAnimations()
        }
    }
}
