//
//  ViewController.swift
//  MOA
//
//  Created by qq on 17/1/13.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import IDZSwiftCommonCrypto

// MARK: - Crypto Demo
func test_StreamCryptor_AES_ECB() {
    
    print(trimToMac("b84c20e4-d1a8-4bed-85e6-b57be0fd4261"))
    
    let key = arrayFrom(string: "j14mz5RT")
    let plainText = "123456"
    
    let cryptor = Cryptor(operation:.encrypt, algorithm:.des, options:.PKCS7Padding, key:key, iv:key)
    let cipherText = cryptor.update(string: plainText)?.final()
    print(hexString(fromArray: cipherText!, uppercase: false))
}

func trimToMac (_ input:String) -> String {
    var tag = hexString(fromArray: Digest(algorithm: .md5).update(string:input)?.final() ?? []).lowercased()
    for i in 0 ..< 5 {
        tag .insert(":", at: tag.index(tag.startIndex, offsetBy: 3*i+2))
    }
    return tag .substring(to: tag.index(tag.startIndex, offsetBy: 17))
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test_StreamCryptor_AES_ECB()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

