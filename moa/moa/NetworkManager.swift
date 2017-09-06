//
//  NetworkManager.swift
//  MOA
//
//  Created by qq on 17/1/18.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

private let NetworkManagerShareInstance = NetworkManager()

class NetworkManager {
    class var sharedInstance : NetworkManager {
        return NetworkManagerShareInstance
    }
}

extension NetworkManager {
//    MARK: - GET 请求 
//    let tools : NetworkManager.shareInstance!
    
    func getRequest(urlString: String, params : [String : AnyObject]? = nil, success : @escaping (_ response : [String : AnyObject])->(), failture : @escaping (_ error : Error)->()) {
        Alamofire.request(urlString, method: .get, parameters: params)
            .responseJSON { (response) in
//                当请求后response是我们自定义的，这个变量用于接受服务器响应的信息
//                使用switch判断请求是否成功，也就是response的result
                switch response.result {
                case .success(let value):
//                    if let value = response.result.value as? [String: AnyObject] {
                        success(value as! [String : AnyObject])
//                    }

                    let json = JSON(value)
                    print(json)
                case .failure(let error):
                    failture(error)
                    print("error:\(error)")
                }
        }
        
    }
//    MARK: - POST 请求
    func postRequest(urlString : String, params : [String : AnyObject]? = nil, success : @escaping (_ response : [String : AnyObject])->(), failture : @escaping (_ error : Error)->()) {
        
        Alamofire.request(urlString, method: HTTPMethod.post, parameters: params).responseJSON { (response) in
            switch response.result{
            case .success:
                if let value = response.result.value as? [String: AnyObject] {
                    success(value)
                    let json = JSON(value)
                    print(json)
                }
            case .failure(let error):
                failture(error)
                print("error:\(error)")
            }
            
        }
    }
}
