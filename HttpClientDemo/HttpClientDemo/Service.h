//
//  Service.h
//  HttpClientDemo
//
//  Created by qq on 16/5/2.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

//所有Service的派生类都要符合这个protocal
@protocol ServiceProtocal <NSObject>

@property (nonatomic, readonly) BOOL isOnline;

@property (nonatomic, readonly) NSString *offlineApiBaseUrl;
@property (nonatomic, readonly) NSString *onlineApiBaseUrl;

@property (nonatomic, readonly) NSString *offlineApiVersion;
@property (nonatomic, readonly) NSString *onlineApiVersion;

@property (nonatomic, readonly) NSString *offlinePublicKey;
@property (nonatomic, readonly) NSString *onlinePublicKey;

@property (nonatomic, readonly) NSString *offlinePrivateKey;
@property (nonatomic, readonly) NSString *onlinePrivateKey;

@property (nonatomic, readonly) NSDictionary *cookis;

@end



@interface Service : NSObject

@property (nonatomic , strong ,readonly) NSString *apiBaseUrl;
@property (nonatomic , strong ,readonly) NSString *apiVersion;
@property (nonatomic , strong ,readonly) NSString *publicKey;
@property (nonatomic , strong ,readonly) NSString *privateKey;
@property (nonatomic , strong ,readonly) NSDictionary *cookis;

@property (nonatomic ,weak) id<ServiceProtocal> child;


@end
