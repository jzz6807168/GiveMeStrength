//
//  Service.m
//  HttpClientDemo
//
//  Created by qq on 16/5/2.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "Service.h"

@implementation Service

-(instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(ServiceProtocal)]) {
            self.child = (id<ServiceProtocal>)self;
        }
    }
    return self;
}

#pragma mark - getters and setters
-(NSString *)publicKey
{
    return self.child.isOnline ? self.child.onlinePublicKey : self.child.offlinePublicKey;
}
-(NSString *)privateKey
{
    return self.child.isOnline ? self.child.onlinePrivateKey : self.child.offlinePrivateKey;
}
-(NSString *)apiBaseUrl
{
    return self.child.isOnline ? self.child.onlineApiBaseUrl : self.child.offlineApiBaseUrl;
}
-(NSString *)apiVersion
{
    return self.child.isOnline ? self.child.onlineApiVersion : self.child.offlineApiVersion;
}
-(NSDictionary *)cookis
{
    return self.child.cookis;
}

@end
