//
//  APIManager.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "APIManager.h"
#import "BaseAPICmd.h"
#import "AFNetworking.h"
#import "APILogger.h"
#import "ApiProxy.h"
#import "URLResponse.h"
#import "ServicePrivate.h"

#define CallAPI(REQUEST_METHOD, REQUEST_ID)                                                       \
{                                                                                       \
__weak __typeof(baseAPICmd) weakBaseAPICmd = baseAPICmd;                                          \
REQUEST_ID = [[ApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:baseAPICmd.reformParams serviceIdentifier:baseAPICmd.serviceIdentifier url:urlString success:^(URLResponse *response) { \
__strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;\
[self successedOnCallingAPI:response baseAPICmd:strongBaseAPICmd];                                          \
} fail:^(URLResponse *response) {                                                \
__strong __typeof(weakBaseAPICmd) strongBaseAPICmd = weakBaseAPICmd;\
[self failedOnCallingAPI:response withErrorType:BaseAPICmdErrorTypeDefault baseAPICmd:strongBaseAPICmd];  \
}];                                                                                 \
[self.requestIdList addObject:@(REQUEST_ID)];                                          \
}


@interface APIManager ()

@property (nonatomic, strong) NSMutableArray *requestIdList;

@end

@implementation APIManager

#pragma mark - life cycle
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static APIManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[APIManager alloc] init];
    });
    return manager;
}
#pragma mark - public metods
- (NSInteger)performCmd:(BaseAPICmd *)baseAPICmd
{
    NSInteger requestId = 0;
    if (baseAPICmd) {
        NSString *urlString = [baseAPICmd absouteUrlString];
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmdStartLoadData:)]) {
            [baseAPICmd.interceptor apiCmdStartLoadData:baseAPICmd];
        }
        if ([self isReachable]) {
            switch (baseAPICmd.child.requestType) {
                case BaseAPICmdRequestTypeGet:
                    CallAPI(GET, requestId);
                    break;
                case BaseAPICmdRequestTypePost:
                    CallAPI(POST, requestId);
                    break;
                case BaseAPICmdRequestTypeGetNormal:
                    CallAPI(GETNormal, requestId);
                    break;
                case BaseAPICmdRequestTypePostNormal:
                    CallAPI(POSTNormal, requestId);
                    break;
                default:
                    break;
            }
        } else {
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformFailWithResponse:nil];
            }
            if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:errorType:)]) {
                [baseAPICmd.delegate apiCmdDidFailed:baseAPICmd errorType:BaseAPICmdErrorTypeNoNetWork];
            }
            if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
                [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformFailWithResponse:nil];
            }
        }
    }
    return requestId;
}

- (void)cancelRequestWithRequestID:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[ApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)cancelAllRequest
{
    [[ApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}


- (BOOL)isLoadingWithRequestID:(NSInteger)requestID
{
    for (NSNumber *number in self.requestIdList) {
        if (number.integerValue == requestID) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - APICall

- (void)successedOnCallingAPI:(URLResponse *)response baseAPICmd:(BaseAPICmd *)baseAPICmd
{
    [self removeRequestIdWithRequestID:response.requestId];
    if ([baseAPICmd.child respondsToSelector:@selector(jsonValidator)]) {
        id json = [baseAPICmd.child jsonValidator];
        if ([ServicePrivate checkJson:response.content withValidator:json] == NO) {
            [self failedOnCallingAPI:response withErrorType:APIManagerErrorTypeNoContent baseAPICmd:baseAPICmd];
            return;
        }
    }
    
    if (response.content) {
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformSuccessWithResponse:)]) {
            [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformSuccessWithResponse:response];
        }
        if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidSuccess:response:)]) {
            [baseAPICmd.delegate apiCmdDidSuccess:baseAPICmd response:response];
        }
        if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformSuccessWithResponse:)]) {
            [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformSuccessWithResponse:response];
        }
    } else {
        [self failedOnCallingAPI:response withErrorType:APIManagerErrorTypeNoContent baseAPICmd:baseAPICmd];
    }
}

- (void)failedOnCallingAPI:(URLResponse *)response withErrorType:(BaseAPICmdErrorType)errorType baseAPICmd:(BaseAPICmd *)baseAPICmd
{
    [self removeRequestIdWithRequestID:response.requestId];
    if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:beforePerformFailWithResponse:)]) {
        [baseAPICmd.interceptor apiCmd:baseAPICmd beforePerformFailWithResponse:response];
    }
    if ([baseAPICmd.delegate respondsToSelector:@selector(apiCmdDidFailed:errorType:)]) {
        [baseAPICmd.delegate apiCmdDidFailed:baseAPICmd errorType:errorType];
    }
    if ([baseAPICmd.interceptor respondsToSelector:@selector(apiCmd:afterPerformFailWithResponse:)]) {
        [baseAPICmd.interceptor apiCmd:baseAPICmd afterPerformFailWithResponse:response];
    }
}

#pragma mark - private methods

- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
            break;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}


- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

#pragma mark - getters
- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}


@end
