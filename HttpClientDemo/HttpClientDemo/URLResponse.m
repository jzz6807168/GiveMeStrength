//
//  URLResponse.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "URLResponse.h"
#import "NSURLRequest+NetworkingMethods.h"

@interface URLResponse ()

@property (nonatomic, assign, readwrite) URLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation URLResponse

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData status:(URLResponseStatus)status
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content       = responseData;
        self.status        = status;
        self.requestId     = [requestId integerValue];
        self.request       = request;
//        self.responseData  = responseData;
        self.requestParams = request.requestParams;
        self.isCache       = NO;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(id)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.status        = [self responseStatusWithError:error];
        self.requestId     = [requestId integerValue];
        self.request       = request;
//        self.responseData  = responseData;
        self.requestParams = request.requestParams;
        self.isCache       = NO;
        
        if (responseData) {
            self.content   = responseData;
        } else {
            self.content   = nil;
        }
    }
    return self;
}

#pragma mark - private methods
- (URLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        URLResponseStatus result = URLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = URLResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return URLResponseStatusSuccess;
    }
}

@end
