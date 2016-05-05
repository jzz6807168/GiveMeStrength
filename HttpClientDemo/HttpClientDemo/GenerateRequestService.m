//
//  GenerateRequestService.m
//  HttpClientDemo
//
//  Created by qq on 16/5/3.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "GenerateRequestService.h"

@implementation GenerateRequestService
#pragma mark - AIFServiceProtocal
- (BOOL)isOnline
{
    return YES;
}

- (NSString *)onlineApiBaseUrl
{
//    URL.HostName;
//    return @"app.xidibuy.com";
    return @"apis.baidu.com";
}

- (NSString *)onlineApiVersion
{
    return @"";
}

- (NSString *)onlinePublicKey
{
    return @"";
}

- (NSString *)onlinePrivateKey
{
    return @"2f89fc72d09998b22585ba93205580f8";
}

- (NSString *)offlineApiBaseUrl
{
    return self.onlineApiBaseUrl;
}

- (NSString *)offlineApiVersion
{
    return self.onlineApiVersion;
}

- (NSString *)offlinePublicKey
{
    return self.onlinePublicKey;
}

- (NSString *)offlinePrivateKey
{
    return self.onlinePrivateKey;
}

- (NSDictionary *)cookis
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionCookies"];
    if (data == nil) {
        return nil;
    }
    NSArray *arcCookis = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in arcCookis) {
        [cookieStorage setCookie:cookie];
    }
    NSDictionary *sheaders = [NSHTTPCookie requestHeaderFieldsWithCookies:arcCookis];
    return sheaders;
}

@end
