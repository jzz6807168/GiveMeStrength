//
//  NSURLRequest+NetworkingMethods.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "NSURLRequest+NetworkingMethods.h"
#import <objc/runtime.h>

static void *NetworkingRequestParams;

@implementation NSURLRequest (NetworkingMethods)

- (void)setRequestParams:(id)requestParams
{
    objc_setAssociatedObject(self, &NetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (id)requestParams
{
    return objc_getAssociatedObject(self, &NetworkingRequestParams);
}

@end
