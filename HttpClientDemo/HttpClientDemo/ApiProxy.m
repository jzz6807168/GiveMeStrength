//
//  ApiProxy.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "ApiProxy.h"
#import "AFNetworking.h"
#import "RequestGenerator.h"
#import "URLResponse.h"
#import "APILogger.h"
#import "NetworkingConfiguration.h"

@interface ApiProxy ()

@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation ApiProxy

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ApiProxy alloc] init];
    });
    return sharedInstance;
}

- (NSInteger)callGETNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail
{
    NSMutableURLRequest *request = [[RequestGenerator sharedInstance] generateNormalGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail
{
    NSMutableURLRequest *request = [[RequestGenerator sharedInstance] generateNormalPOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}


- (NSInteger)callGETWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail
{
    NSMutableURLRequest *request = [[RequestGenerator sharedInstance] generateGETRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (NSInteger)callPOSTWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail
{
    NSMutableURLRequest *request = [[RequestGenerator sharedInstance] generatePOSTRequestWithRequestParams:params url:url serviceIdentifier:serviceIdentifier];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return requestId.integerValue;
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSOperation *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}


#pragma mark - private methods

/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSMutableURLRequest *)request success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail
{
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    AFHTTPRequestOperation *httpRequestOperation = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        [APILogger logDebugInfoWithResponse:operation.response
                                resposeString:operation.responseString
                                      request:operation.request
                                        error:NULL];
        URLResponse *response = [[URLResponse alloc] initWithResponseString:operation.responseString requestId:requestId request:request responseData:responseObject status:URLResponseStatusSuccess];
        success?success(response):nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        [APILogger logDebugInfoWithResponse:operation.response
                                resposeString:operation.responseString
                                      request:operation.request
                                        error:error];
        URLResponse *response = [[URLResponse alloc] initWithResponseString:operation.responseString requestId:requestId request:request responseData:operation.responseObject error:error];
        fail?fail(response):nil;
    }];
    
    self.dispatchTable[requestId] = httpRequestOperation;
    [[self.operationManager operationQueue] addOperation:httpRequestOperation];
    return requestId;
}

- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)operationManager
{
    if (_operationManager == nil) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        _operationManager.operationQueue.maxConcurrentOperationCount = 10;
        _operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        _operationManager.requestSerializer.timeoutInterval = kNetworkingTimeoutSeconds;
    }
    return _operationManager;
}

@end
