//
//  APILogger.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Service;

@interface APILogger : NSObject

+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams responseParams:(id)responseParams httpMethod:(NSString *)httpMethod requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName;
+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod error:(NSError *)error requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName;
+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error;
+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(Service *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod;

@end
