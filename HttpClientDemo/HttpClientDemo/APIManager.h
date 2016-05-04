//
//  APIManager.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BaseAPICmd;

@interface APIManager : NSObject

+ (instancetype)manager;

- (void)cancelRequestWithRequestID:(NSInteger)requestID;
- (void)cancelAllRequest;

- (BOOL)isLoadingWithRequestID:(NSInteger)requestID;

- (NSInteger)performCmd:(BaseAPICmd *)BaseAPICmd;

@end
