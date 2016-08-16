//
//  BrowserView.swift
//  moa
//
//  Created by qq on 16/8/4.
//  Copyright © 2016年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit

class BrowserView: UIView ,UIWebViewDelegate{
    var kv: NSMutableDictionary?
    var browser: UIWebView?
    var stat: UILabel?
    var refresh: UIButton?
    var indicator: UIActivityIndicatorView?
    var failUrl:String?
    
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        kv = Config .sharedConfig().kv
        //clear cookie
        
        let cookies:Array = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!
        if cookies.isEmpty == false {
            for cookie:NSHTTPCookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
            NSUserDefaults .standardUserDefaults() .synchronize()
        }
        
        browser = UIWebView.init(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        browser?.scrollView.bounces = false
        browser?.hidden = true
        browser?.delegate = self
        
        var pathUrl:String = (kv? .objectForKey("_DOMAIN_XIDI_MOA"))! as!String
        
        if pathUrl == "https://moa.xiditech.com" {
            let datenow:NSDate = NSDate()
            let timesp:String = String(datenow .timeIntervalSince1970)
            pathUrl = "https://moa.xiditech.com/index.html?time=" + timesp
        }
        
        browser?.loadRequest(NSURLRequest.init(URL: NSURL.init(string: pathUrl)!))
        let token:String = NSUserDefaults .standardUserDefaults() .stringForKey("token")!
        
        let string1 = "var XIDIAPP = XIDIAPP || {};XIDIAPP.getTokenFromApp=function(){return '"
        let string2 = "'};"
        
        let  ScriptString:String = string1 + token + string2
        
        browser?.stringByEvaluatingJavaScriptFromString(ScriptString)
        self .addSubview(browser!)
        
        //先是状态
        stat = UILabel.init(frame: CGRectMake(0, frame.size.height/2-50, frame.size.width, 20))
        stat?.text = "页面加载中"
        stat?.textAlignment = .Center
        self .addSubview(stat!)
        
        refresh = UIButton.init(type: .Custom)
        refresh?.hidden = true
        refresh?.frame = CGRectMake(frame.size.width/2-45, frame.size.height/2-20, 90, 40)
        refresh?.setTitle("请点击刷新", forState: .Normal)
        refresh?.addTarget(self, action: #selector(BrowserView.refreshBrowser), forControlEvents: .TouchUpInside)
        
        indicator = UIActivityIndicatorView.init(frame: CGRectMake(frame.size.width/2-20, frame.size.height/2-20, 40, 40))
        indicator?.activityIndicatorViewStyle = .WhiteLarge
        indicator?.startAnimating()
        indicator?.color = UIColor.grayColor()
        indicator?.hidesWhenStopped = true
        self .addSubview(indicator!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelWeb() {
        browser?.stopLoading()
        stat?.text = "网络不太给力，加载失败。"
        refresh?.hidden = false
        stat?.hidden = false
        
        indicator?.hidden = true
    }
    
    func refreshBrowser() {
        refresh?.hidden = true
        indicator?.hidden = false
        indicator?.startAnimating()
        stat?.text = "页面加载中"
        browser?.loadRequest(NSURLRequest.init(URL: NSURL.init(string: failUrl!)!))
        
        let token:String = NSUserDefaults .standardUserDefaults() .stringForKey("token")!
        
        let string1 = "var XIDIAPP = XIDIAPP || {};XIDIAPP.getTokenFromApp=function(){return '"
        let string2 = "'};"
        
        let  ScriptString:String = string1 + token + string2
        
        browser?.stringByEvaluatingJavaScriptFromString(ScriptString)
    }
    
    //UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let absoluteString:String = request.URL!.absoluteString
        let path:String = request.URL!.path!
        print("requrl:" + absoluteString + "\npath:" + path + "\n")
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("finish")
        stat?.hidden = true
        refresh?.hidden = true
        indicator?.hidden = true
        browser?.hidden = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error)
        self.cancelWeb()
        failUrl! = error?.userInfo ["NSErrorFailingURLStringKey"]! as! String
        print("cancel:" + failUrl!)
    }

}
