//
//  ViewController.swift
//  didi
//
//  Created by qq on 16/4/11.
//  Copyright © 2016年 qq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view?.backgroundColor=UIColor .cyanColor();
        
        self.navigationItem.title="哈哈";
        
        let barbutton:UIBarButtonItem = UIBarButtonItem.init(title: "xixi", style:.Plain , target: self, action:"backButtonTouched")
        self.navigationItem.rightBarButtonItem=barbutton
        
        let label: UILabel = UILabel()
        label.frame = CGRect(x:50, y:100, width:200, height:100)
        label.text = "swift"
        self.view.addSubview(label)
    }
    
    func backButtonTouched() {
        
        print("点击了返回键")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

