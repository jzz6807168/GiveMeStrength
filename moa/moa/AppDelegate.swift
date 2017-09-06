//
//  AppDelegate.swift
//  MOA
//
//  Created by qq on 17/1/13.
//  Copyright © 2017年 Xidi E-commerce Co. Ltd. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerAppNotificationSettings(launchOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.applicationIconBadgeNumber = 0;
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let nsdataStr = NSData.init(data: deviceToken)
        let token = nsdataStr.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
//        print("token==\(token)")
        
        let dict = ["deviceToken":token]
        NetworkManager.sharedInstance.postRequest(urlString: "http://www.xidibuy.com/device/save", params: dict as [String : AnyObject]?, success: { (successResult) in
            
        }, failture: { (errorResult) in
            
        })
        
        UserDefaults.standard .set(token, forKey: "deviceToken")
        UserDefaults.standard .synchronize()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let alert:UIAlertView = UIAlertView(title: "", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func registerAppNotificationSettings(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            let types = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
            notifiCenter.requestAuthorization(options: types, completionHandler: { (flag, error) in
                if flag {
                    print("iOS request notification success")
                }else{
                    print(" iOS 10 request notification fail")
                }
            })
        } else {
            //iOS8,iOS9注册通知
            let setting = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil)
        
            UIApplication.shared.registerUserNotificationSettings(setting)
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    //iOS10新增：处理前台收到通知的代理方法 
    @nonobjc @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void){
        let userInfo = notification.request.content.userInfo
        print("userInfo10:\(userInfo)")
        completionHandler([.sound,.alert])
    }
    //iOS10新增：处理后台点击通知的代理方法 
    @nonobjc @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void){
        let userInfo = response.notification.request.content.userInfo
        print("userInfo10:\(userInfo)")
        completionHandler()
    }
    
    @nonobjc func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("收到新消息Active\(userInfo)")
        if application.applicationState == UIApplicationState.active {
            // 从前台接受消息app
        }else{
            // 从后台接受消息后进入app 
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        completionHandler(.newData)
    }

}

