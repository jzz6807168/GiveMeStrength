//
//  AppDelegate.m
//  HttpClientDemo
//
//  Created by qq on 16/4/15.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "AppDelegate.h"
#import "SimplePingHelper.h"
#import "HostsReplaceURLProtocol.h"
//#import "AFNetworking.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSURLProtocol registerClass:[HostsReplaceURLProtocol class]];
    //@"www.sina.com",@"www.hao123.com",@"www.taobao.com",@"www.qq.com"
    [SimplePingHelper simpleHostpings:@[@"apis.baidu.com"/*@",app.xidibuy.com,appshop.xidibuy.com"*/] completeBlock:^(NSArray *hostPingTimeArray) {
        [HostsReplaceURLProtocol configureHostsWithBlock:^(id<HostsReplaceConfigurationDelegate> configuration) {
            NSDictionary *hostDict = hostPingTimeArray.firstObject;
            [configuration replaceHostName:@"apis.baidu.com"/*@",app.xidibuy.com,appshop.xidibuy.com"*/ toIPAddress:hostDict.allKeys.firstObject];
        }];
        NSLog(@"%@",hostPingTimeArray);
    }];
    
    /*
     AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
     manager.responseSerializer=[AFHTTPResponseSerializer serializer];
     [manager.requestSerializer setValue:@"2f89fc72d09998b22585ba93205580f8" forHTTPHeaderField:@"apikey"];
     
     
     NSDictionary * dic = @{@"city":@"shanghai"};
     
     //发送数据
     [manager GET:@"http://apis.baidu.com/heweather/weather/free" parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
     }];
     */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
