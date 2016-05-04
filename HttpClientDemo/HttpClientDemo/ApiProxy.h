//
//  ApiProxy.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLResponse.h"

typedef void(^NetworkingCallBack)(URLResponse *response);

@interface ApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail;
- (NSInteger)callPOSTNormalWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail;

- (NSInteger)callGETWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail;
- (NSInteger)callPOSTWithParams:(id)params serviceIdentifier:(NSString *)serviceIdentifier url:(NSString *)url success:(NetworkingCallBack)success fail:(NetworkingCallBack)fail;


- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
