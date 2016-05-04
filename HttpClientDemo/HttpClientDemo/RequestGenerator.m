//
//  RequestGenerator.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "RequestGenerator.h"
#import "AFNetworking.h"
#import "BaseAPICmd.h"
#import "ServiceFactory.h"
#import "APILogger.h"
#import "NSURLRequest+NetworkingMethods.h"

@interface RequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation RequestGenerator

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static RequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RequestGenerator alloc] init];
    });
    return sharedInstance;
}

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    Service *service = [[ServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"GET";
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [APILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"GET"];
    return request;
}
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    Service *service = [[ServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",service.apiBaseUrl,url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kNetworkingTimeoutSeconds];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:NSJSONWritingPrettyPrinted error:NULL];
    NSDictionary *restfulHeader = [self commRESTHeadersWithService:service];
    [restfulHeader enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    request.requestParams = requestParams;
    [APILogger logDebugInfoWithRequest:request apiName:url service:service requestParams:requestParams httpMethod:@"POST"];
    return request;
}

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}
- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:url parameters:requestParams error:NULL];
    request.timeoutInterval = kNetworkingTimeoutSeconds;
    request.requestParams = requestParams;
    return request;
}
#pragma mark - private methods
- (NSDictionary *)commRESTHeadersWithService:(Service *)service
{
    NSMutableDictionary *headerDic = [[NSMutableDictionary alloc] init];
    if (service.cookis.count != 0) {
        [headerDic addEntriesFromDictionary:service.cookis];
    }
    
    [headerDic setValue:service.privateKey  forKey:@"apikey"];
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    return headerDic;
}

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end

