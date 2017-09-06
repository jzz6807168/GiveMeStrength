//
//  Config.swift
//  MOA
//
//  Created by qq on 17/1/18.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import IDZSwiftCommonCrypto
import SwiftyJSON
import Foundation

private let ConfigsharedConfig = Config()

class Config {
    class var sharedConfig : Config {
        return ConfigsharedConfig
    }
}

extension Config {
    
    func trimToMac (_ input:String) -> String {
        var tag = hexString(fromArray: Digest(algorithm: .md5).update(string:input)?.final() ?? []).lowercased()
        for i in 0 ..< 5 {
            tag .insert(":", at: tag.index(tag.startIndex, offsetBy: 3 * i + 2))
        }
        return tag .substring(to: tag.index(tag.startIndex, offsetBy: 17))
    }
    
    
    func updateMoa() -> Bool {
        var updateAvailable:Bool = false
        
        let updateDictionary:NSDictionary! = NSDictionary.init(contentsOf: NSURL.init(string: "http://moa.xiditech.com/download/moa/moa.plist") as! URL)
        if (updateDictionary != nil) {
            
            let json = JSON(updateDictionary)
            switch json.type {
            case .dictionary:
                let items = json["items"].array
                let lastjson = items?.last
                
                let newversion:String = (lastjson?["metadata"]["bundle-version"].description)!
                let currentversion:String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
                updateAvailable = ((newversion as NSString).floatValue > (currentversion as NSString).floatValue)
                break
            default:
                updateAvailable = false
                break
            }
        }
        
        return updateAvailable
    }
}
