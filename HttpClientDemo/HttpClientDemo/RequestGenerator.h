//
//  RequestGenerator.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestGenerator : NSObject

+ (instancetype)sharedInstance;

- (NSMutableURLRequest *)generateGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generatePOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

- (NSMutableURLRequest *)generateNormalGETRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;
- (NSMutableURLRequest *)generateNormalPOSTRequestWithRequestParams:(id)requestParams url:(NSString *)url serviceIdentifier:(NSString *)serviceIdentifier;

@end
