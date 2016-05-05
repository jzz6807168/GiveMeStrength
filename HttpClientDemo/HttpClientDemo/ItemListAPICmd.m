//
//  ItemListAPICmd.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "ItemListAPICmd.h"

@implementation ItemListAPICmd

- (BaseAPICmdRequestType)requestType
{
    return BaseAPICmdRequestTypeGet;
}

- (NSString *)methodName
{
    //URL.path
    return @"/heweather/weather/free";
}

- (BOOL)isRequestHook
{
    return YES;
}

@end
