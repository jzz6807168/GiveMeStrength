//
//  ViewController.swift
//  didi
//
//  Created by qq on 16/4/11.
//  Copyright © 2016年 qq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var name : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view?.backgroundColor=UIColor .cyanColor();
        
        self.navigationItem.title="哈哈";
        
        let barbutton:UIBarButtonItem = UIBarButtonItem.init(title: "xixi", style:.Plain , target: self, action:#selector(ViewController.backButtonTouched))
        self.navigationItem.rightBarButtonItem=barbutton
        
        let label: UILabel = UILabel()
        label.frame = CGRect(x:50, y:100, width:200, height:100)
        label.text = "swift"
        label.textAlignment = .Center
        self.view.addSubview(label)
        
        name = UITextField()
        name!.frame = CGRectMake(50,250, 200, 50)
        name!.backgroundColor = UIColor .whiteColor()
        name!.leftViewMode = .Always
        name!.leftView = UIImageView.init(image: UIImage.init(named: "ic_login_user"))
        name!.clearButtonMode = .WhileEditing
        name!.placeholder = "OA账号"
        self.view.addSubview(name!)
        
        var littleStr = "look over "
        let behindStr = "there"
        littleStr += behindStr;
        print(littleStr);
        
        let catCharacters: [Character] = ["C", "a", "t", "!", "🐱"]
        let catString = String(catCharacters)
        print(catString)
        
        let 🐶🐮 = "dogcow"
        print(🐶🐮);
        // 打印输出："Cat!🐱"
        
        let letButton:UIButton = UIButton.init(type: .Custom)
        letButton.frame = CGRectMake(50, 350, 100, 50)
        letButton .setTitle("滴沥当啷", forState: .Normal)
        letButton .setTitleColor(UIColor.blackColor(), forState: .Normal)
        letButton .titleLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        letButton .backgroundColor = UIColor.orangeColor()
        self.view .addSubview(letButton)
        letButton .addTarget(self, action: #selector(ViewController.letusgo), forControlEvents: .TouchUpInside)
        

        
    }
    
    func backButtonTouched() {
        
        print("点击了返回键")
    }

    func letusgo() {
        print("晶晶晶")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

