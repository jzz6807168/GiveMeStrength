//
//  LoginView.swift
//  moa
//
//  Created by qq on 16/8/2.
//  Copyright © 2016年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class LoginView: UIView {
    
    var bgimg : UIImageView?
    var stat : UILabel?
    var name : UITextField?
    var password : UITextField?
    var buttonMarginBottom: CGFloat?
    var kv: NSMutableDictionary?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        kv=Config.shared().kv
        self.backgroundColor = UIColor .init(colorLiteralRed: 0xf1/255.0, green: 0xf1/255.0, blue: 0xf1/255.0, alpha: 1)
        self.create()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create() {
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
        submit.setTitle("登录", for: UIControlState())
        submit.setTitleColor(UIColor.white, for: UIControlState())
        submit.frame = CGRect(x: (fwidth-mwidth)/2+20, y: fheight/2+80, width: mwidth-40, height: 50)
        submit.backgroundColor = UIColor .init(colorLiteralRed: 0x0d/255.0, green: 0xc6/255.0, blue: 0xa6/255.0, alpha: 1)
        submit.titleLabel?.font = UIFont .systemFont(ofSize: 20.0)
        submit.addTarget(self, action: #selector(LoginView.login), for: .touchUpInside)
        self .addSubview(submit)
        
        buttonMarginBottom = 0.0
        
        DispatchQueue.main.async { 
            if self.tokenLogin() {
                self .showMsg("token登录成功，正在跳转。")
                Config.shared() .setValue("3", forKey: "currentView")
            }else{
                self.stat?.text = nil
                self.isHidden = false
            }
        }
    }
    
    func tokenLogin() -> Bool {
        if (UserDefaults.standard .string(forKey: "token") != nil) {
            //如果token不为空，发送请求。
            self.showMsg("正在用本地token登录")
            
            let requestUrlStr:String = UserDefaults.standard .object(forKey: "token")! as! String
            
            
            let request:NSMutableURLRequest = self .buildPostRequestWithUrl((kv? .object(forKey: "_URL_AUTH_PASSPORT_CHECK"))! as! String, data: "token=" + requestUrlStr)
            let data:Data = try! NSURLConnection .sendSynchronousRequest(request as URLRequest, returning: nil)
            
            let jsonObjects:AnyObject! = try? JSONSerialization .jsonObject(with: data, options: .mutableContainers) as AnyObject!
            
            return (jsonObjects.object(forKey: "code") as! NSNumber) == 0
        }else{
            return false
        }
    }
    
    func login() {
        
        if (name?.text?.lengthOfBytes(using: String.Encoding.utf8) > 0 && password?.text?.lengthOfBytes(using: String.Encoding.utf8) > 0) {

            let macStr:String = (kv? .object(forKey: "mac"))! as!String
            
            let passwordStr:String = Config.shared().encrypt(password?.text, withKey: (kv? .object(forKey: "_DATA_XIDIMOA_ENCRYPT_KEY"))! as!String)

            let dataStr:String = "mac=" + macStr + "&password=" + passwordStr

            let urlStr:String = (kv? .object(forKey: "_URL_AUTH_PASSPORT_SIGN"))! as!String
            
            let request:NSMutableURLRequest = self .buildPostRequestWithUrl(urlStr, data: dataStr)
            
            NSURLConnection .sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.init(), completionHandler:{
                (response, data, error) -> Void in
                DispatchQueue.main.async {
                    if ((error) != nil) {
                        //Handle Error here
                        self .showMsg("网络连接出错，请稍后重试。")
                        print(error?.localizedDescription as Any)
                        
                    }else{
                        //Handle data in NSData type
                        
                        do {
                            let jsonObjects:Any = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers)
                            let jsonDic = jsonObjects as!Dictionary<String, Any>
                            let code = jsonDic["code"] as!NSNumber
                            
                            if code == 0 {
                                //保存token.
                                let data = jsonDic["data"] as!Dictionary<String, Any>
                                let token = data["token"] as!String
                                UserDefaults.standard .set(token, forKey: "token")
                                UserDefaults.standard .synchronize()
                                //显示browser
                                self .showMsg("登录成功，正在跳转。")
                                Config .shared() .setValue("3", forKey: "currentView")
                            }else{
                                self .showMsg("登录失败，用户名密码错误!")
                            }
                            
                        } catch {
                            // deal with error
                            self .showMsg("解析服务器数据错误，请稍后重试。")
                        }
                    }
                }
                
            })
            
        }else{
            self .showMsg("用户名密码/不能为空")
        }
        
    }
    
    func showMsg(_ msg:String) {
        stat?.text = msg
        stat?.isHidden = false
    }
    
    func keyboardShow(_ kbheight:CGFloat) {
        
        //看看keyboard是否覆盖住button
        if (buttonMarginBottom<kbheight && self.frame.origin.y>=0) {
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
    
    func buildPostRequestWithUrl(_ url:String ,data:String) -> NSMutableURLRequest {
        let request:NSMutableURLRequest = NSMutableURLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        let  postData:Data = data.data(using: String.Encoding.utf8)!
        
        request.setValue(String(postData.count), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        
        return request
    }
    
}
