//
//  BaseAPICmd.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "BaseAPICmd.h"
#import "APIManager.h"
#import "NSDictionary+NetworkingMethods.h"
#import "ServiceKeys.h"
#import "ApiProxy.h"
#import "Aspects.h"

@interface BaseAPICmd ()

@property (nonatomic, copy,   readwrite) NSString     *absouteUrlString;
@property (nonatomic, assign, readwrite) NSInteger    requestId;
@property (nonatomic, copy,   readwrite) NSDictionary *cookie;
@property (nonatomic, copy,   readwrite) NSString     *serviceIdentifier;
@property (nonatomic, assign, readwrite) BOOL         isLoading;

@end

@implementation BaseAPICmd

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(BaseAPICmdDelegate)]) {
            self.child = (id<BaseAPICmdDelegate>) self;
            if ([self.child respondsToSelector:@selector(isRequestHook)]) {
                if ([self.child isRequestHook]) {
                    [ApiProxy aspect_hookSelector:NSSelectorFromString(@"callApiWithRequest:success:fail:") withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo, NSMutableURLRequest *request,id success,id fail) {
                        [self hookCallWithRequest:request];
                    } error:NULL];
                }
            }
        } else {
#ifdef DEBUGLOGGER
            NSAssert(0, @"子类必须要实现APIManager这个protocol。");
#endif
        }
    }
    return self;
}

#pragma mark - hook methods
- (void)hookCallWithRequest:(NSMutableURLRequest *)request
{
    if ([self.aspect respondsToSelector:@selector(apiCmd:request:)]) {
        [self.aspect apiCmd:self request:request];
    }
}

- (NSString *)absouteUrlString
{
    if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
        // 解析参数：URL 以及 上传的参数
        NSMutableString *methodName = [[NSMutableString alloc] initWithString:self.child.methodName];
        NSMutableDictionary *requestURLParam = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] init];
        
        NSDictionary *paramDict = [self.paramSource paramsForApi:self];
        NSArray *requestArray = paramDict[kReformParamArray];
        [paramDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
            if ([key rangeOfString:@"||"].length) {
                NSRange range = [methodName rangeOfString:key];
                [methodName replaceCharactersInRange:range withString:value];
            } else if ([key rangeOfString:@":"].length) {
                NSMutableString *valueKey = [NSMutableString stringWithString:key];
                NSRange range = [valueKey rangeOfString:@":"];
                [valueKey replaceCharactersInRange:range withString:@""];
                requestParam[valueKey] = value;
            } else {
                requestURLParam[key] = value;
            }
        }];
        
        if (requestArray.count != 0) {
            self.reformParams = requestArray;
        } else {
            self.reformParams = requestParam;
        }
        
        NSString *methodNameURL = [NSString stringWithFormat:@"%@?%@",methodName,[requestURLParam urlParamsString]];
        _absouteUrlString = [methodNameURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } else {
        _absouteUrlString = [self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return _absouteUrlString;
}

- (NSString *)serviceIdentifier
{
    if ([self.child respondsToSelector:@selector(serviceType)]) {
        _serviceIdentifier = [self.child serviceType];
    } else {
        _serviceIdentifier = kGenerateRequestService;
    }
    return _serviceIdentifier;
}
/**
 *   author jiang_cross, 16-05-04 17:39:14
 *
 *   isLoading
 *
 *   @return
 */
- (BOOL)isLoading
{
    _isLoading = [[APIManager manager] isLoadingWithRequestID:self.requestId];
    return _isLoading;
}
/**
 *   author jiang_cross, 16-05-04 17:39:59
 *
 *   取消当前的请求
 */
- (void)cancelRequest
{
    [[APIManager manager] cancelRequestWithRequestID:self.requestId];
}
/**
 *   @author jiang_cross, 16-05-04 17:40:05
 *
 *   开始请求数据
 */
- (void)loadData
{
    self.requestId = [[APIManager manager] performCmd:self];
}

- (void)dealloc
{
    if ([self.child respondsToSelector:@selector(isCancelled)]) {
        if ([self.child isCancelRequest]) {
            [self cancelRequest];
        }
    } else {
        [self cancelRequest];
    }
}
@end

