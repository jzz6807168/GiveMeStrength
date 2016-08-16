//
//  LoginView.swift
//  moa
//
//  Created by qq on 16/8/2.
//  Copyright © 2016年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit

class LoginView: UIView {
    
    var bgimg : UIImageView?
    var stat : UILabel?
    var name : UITextField?
    var password : UITextField?
    var buttonMarginBottom: CGFloat?
    var kv: NSMutableDictionary?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.hidden = true
        kv=Config.sharedConfig().kv
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
        bgimg?.frame = CGRectMake((fwidth-127.5)/2, fheight/2-150, 127.5, 43)
        self .addSubview(bgimg!)
        
        //显示状态
        stat = UILabel()
        stat?.frame = CGRectMake((fwidth-mwidth)/2, fheight/2-50-0.5-40, mwidth, 40)
        stat?.text = "用户名/密码不匹配，请重试。"
        stat?.textColor = UIColor .redColor()
        stat?.textAlignment = .Center
        stat?.hidden = true
        self .addSubview(stat!)
        
        //两个input
        name = UITextField()
        name?.frame = CGRectMake((fwidth-mwidth)/2, fheight/2-50-0.5, mwidth, 50)
        name?.backgroundColor = UIColor .whiteColor()
        name?.leftViewMode = .Always
        name?.leftView = UIImageView.init(image: UIImage.init(named: "ic_login_user"))
        name?.clearButtonMode = .WhileEditing
        name?.placeholder = "OA账号"
        self .addSubview(name!)
        
        password = UITextField()
        password?.frame = CGRectMake((fwidth-mwidth)/2, fheight/2+0.5, mwidth, 50)
        password?.secureTextEntry = true
        password?.clearButtonMode = .WhileEditing
        password?.backgroundColor = UIColor .whiteColor()
        password?.leftViewMode = .Always
        password?.leftView = UIImageView.init(image: UIImage.init(named: "ic_login_pass"))
        password?.placeholder = "OA密码"
        self .addSubview(password!)
        
        //一个按钮
        let submit:UIButton = UIButton.init(type: .Custom)
        submit.setTitle("登录", forState: .Normal)
        submit.setTitleColor(UIColor .whiteColor(), forState: .Normal)
        submit.frame = CGRectMake((fwidth-mwidth)/2+20, fheight/2+80, mwidth-40, 50)
        submit.backgroundColor = UIColor .init(colorLiteralRed: 0x0d/255.0, green: 0xc6/255.0, blue: 0xa6/255.0, alpha: 1)
        submit.titleLabel?.font = UIFont .systemFontOfSize(20.0)
        submit.addTarget(self, action: #selector(LoginView.login), forControlEvents: .TouchUpInside)
        self .addSubview(submit)
        
        buttonMarginBottom = 0.0
        
        dispatch_async(dispatch_get_main_queue()) { 
            if self.tokenLogin() {
                self .showMsg("token登录成功，正在跳转。")
                Config.sharedConfig() .setValue("3", forKey: "currentView")
            }else{
                self.stat?.text = nil
                self.hidden = false
            }
        }
    }
    
    func tokenLogin() -> Bool {
        if (NSUserDefaults.standardUserDefaults() .stringForKey("token") != nil) {
            //如果token不为空，发送请求。
            self.showMsg("正在用本地token登录")
            
            let requestUrlStr:String = NSUserDefaults .standardUserDefaults() .objectForKey("token")! as! String
            
            
            let request:NSMutableURLRequest = self .buildPostRequestWithUrl((kv? .objectForKey("_URL_AUTH_PASSPORT_CHECK"))! as! String, data: "token=" + requestUrlStr)
            let data:NSData = try! NSURLConnection .sendSynchronousRequest(request, returningResponse: nil)
            
            let jsonObjects:AnyObject! = try? NSJSONSerialization .JSONObjectWithData(data, options: .MutableContainers)
            
            return (jsonObjects .objectForKey("code") as! NSNumber) == 0
        }else{
            return false
        }
    }
    
    func login() {
        
        if (name?.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 && password?.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {

            let macStr:String = (kv? .objectForKey("mac"))! as!String
            
            let passwordStr:String = Config.sharedConfig().encrypt(password?.text, withKey: (kv? .objectForKey("_DATA_XIDIMOA_ENCRYPT_KEY"))! as!String)

            let dataStr:String = "mac=" + macStr + "&password=" + passwordStr

            let urlStr:String = (kv? .objectForKey("_URL_AUTH_PASSPORT_SIGN"))! as!String
            
            let request:NSMutableURLRequest = self .buildPostRequestWithUrl(urlStr, data: dataStr)
            
            NSURLConnection .sendAsynchronousRequest(request, queue: NSOperationQueue.init(), completionHandler:{
                (response, data, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if ((error) != nil) {
                        //Handle Error here
                        self .showMsg("网络连接出错，请稍后重试。")
                        print(error)
                        
                    }else{
                        //Handle data in NSData type
                        
                        do {
                            let jsonObjects:AnyObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                            
                            if (jsonObjects .objectForKey("code") as! NSNumber) == 0 {
                                //保存token.
                                let token:String = jsonObjects .objectForKey("data")! .objectForKey("token")! as! String
                                NSUserDefaults .standardUserDefaults() .setObject(token, forKey: "token")
                                NSUserDefaults .standardUserDefaults() .synchronize()
                                //显示browser
                                self .showMsg("登录成功，正在跳转。")
                                Config .sharedConfig() .setValue("3", forKey: "currentView")
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
    
    func showMsg(msg:String) {
        stat?.text = msg
        stat?.hidden = false
    }
    
    func keyboardShow(kbheight:CGFloat) {
        
        //看看keyboard是否覆盖住button
        if (buttonMarginBottom<kbheight && self.frame.origin.y>=0) {
            //向上移动frame
            UIView .beginAnimations(nil, context: nil)
            UIView .setAnimationDuration(0.3)
            
            var rect:CGRect = self.frame
            rect.origin.y -= UIScreen.mainScreen().bounds.height <= 480 ? 240.0-buttonMarginBottom! : (CGFloat(kbheight)-buttonMarginBottom!+/*留出底下边框*/5)-100
            self.frame = rect
            if UIScreen.mainScreen().bounds.height < 600 {
                bgimg?.hidden = true
            }
            
            UIView .commitAnimations()

        }
    }
    
    func buildPostRequestWithUrl(url:String ,data:String) -> NSMutableURLRequest {
        let request:NSMutableURLRequest = NSMutableURLRequest.init(URL: NSURL.init(string: url)!)
        request.HTTPMethod = "POST"
        let  postData:NSData = data.dataUsingEncoding(NSUTF8StringEncoding)!
        
        request.setValue(String(postData.length), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        
        return request
    }
    
}
