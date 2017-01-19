//
//  BrowserView.swift
//  MOA
//
//  Created by qq on 17/1/18.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit

class BrowserView: UIView ,UIWebViewDelegate{
    var browser: UIWebView?
    var stat: UILabel?
    var refresh: UIButton?
    var indicator: UIActivityIndicatorView?
    var lastRequest:NSURLRequest?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //clear cookie
        let cookies:Array = HTTPCookieStorage.shared.cookies!
        if cookies.isEmpty == false {
            for cookie:HTTPCookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
            UserDefaults.standard .synchronize()
        }
        
        browser = UIWebView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        browser?.scrollView.bounces = false
        browser?.isHidden = true
        browser?.delegate = self
        
        var pathUrl:String = "https://moa.xiditech.com"
        
        if pathUrl == "https://moa.xiditech.com" {
            let datenow:Date = Date()
            let timesp:String = String(datenow .timeIntervalSince1970)
            pathUrl = "https://moa.xiditech.com/index.html?time=" + timesp
        }
        
        browser?.loadRequest(URLRequest.init(url: URL.init(string: pathUrl)!))
        let token:String = UserDefaults.standard .string(forKey: "token")!
        
        let string1 = "var XIDIAPP = XIDIAPP || {};XIDIAPP.getTokenFromApp=function(){return '"
        let string2 = "'};"
        
        let  ScriptString:String = string1 + token + string2
        print(ScriptString);
        browser?.stringByEvaluatingJavaScript(from: ScriptString)
        self .addSubview(browser!)
        
        //先是状态
        stat = UILabel.init(frame: CGRect(x: 0, y: frame.size.height/2-50, width: frame.size.width, height: 20))
        stat?.text = "页面加载中"
        stat?.textAlignment = .center
        self .addSubview(stat!)
        
        refresh = UIButton.init(type: .custom)
        refresh?.isHidden = true
        refresh?.frame = CGRect(x: frame.size.width/2-45, y: frame.size.height/2-20, width: 90, height: 40)
        refresh?.setTitle("请点击刷新", for: UIControlState())
        refresh?.addTarget(self, action: #selector(BrowserView.refreshBrowser), for: .touchUpInside)
        
        indicator = UIActivityIndicatorView.init(frame: CGRect(x: frame.size.width/2-20, y: frame.size.height/2-20, width: 40, height: 40))
        indicator?.activityIndicatorViewStyle = .whiteLarge
        indicator?.startAnimating()
        indicator?.color = UIColor.gray
        indicator?.hidesWhenStopped = true
        self .addSubview(indicator!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelWeb() {
        browser?.stopLoading()
        stat?.text = "网络不太给力，加载失败。"
        refresh?.isHidden = false
        stat?.isHidden = false
        
        indicator?.isHidden = true
    }
    
    func refreshBrowser() {
        refresh?.isHidden = true
        indicator?.isHidden = false
        indicator?.startAnimating()
        stat?.text = "页面加载中"
        browser?.loadRequest(lastRequest as! URLRequest)
        let token:String = UserDefaults.standard .string(forKey: "token")!
        
        let string1 = "var XIDIAPP = XIDIAPP || {};XIDIAPP.getTokenFromApp=function(){return '"
        let string2 = "'};"
        
        let  ScriptString:String = string1 + token + string2
        
        browser?.stringByEvaluatingJavaScript(from: ScriptString)
    }
    
    //UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let absoluteString:String = request.url!.absoluteString
        let path:String = request.url!.path
        print("requrl:" + absoluteString + "\npath:" + path + "\n")
        
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finish")
        stat?.isHidden = true
        refresh?.isHidden = true
        indicator?.isHidden = true
        browser?.isHidden = false
        
        if browser?.request?.url?.host == "moa.xiditech.com" {
            lastRequest = browser?.request as NSURLRequest?
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error.localizedDescription as Any)
        self.cancelWeb()
    }
    
}

