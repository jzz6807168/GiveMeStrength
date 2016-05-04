//
//  ServiceFactory.m
//  HttpClientDemo
//
//  Created by qq on 16/5/3.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "ServiceFactory.h"
#import "ServiceKeys.h"


/*************************************************************************************************/
/*                                        Base services                                          */
/*************************************************************************************************/
// 通用的service 用户基础API
#import "GenerateRequestService.h"

/*************************************************************************************************/
/*                                       third services                                          */
/*************************************************************************************************/


@interface ServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;

@end

@implementation ServiceFactory

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ServiceFactory alloc]init];
    });
    return sharedInstance;
}

- (Service<ServiceProtocal> *)serviceWithIdentifier:(NSString *)identifier
{
    if (self.serviceStorage[identifier] == nil) {
        self.serviceStorage[identifier] = [self newServiceWithIdentifier:identifier];
    }
    return self.serviceStorage[identifier];
}


#pragma mark - private methods
- (Service<ServiceProtocal> *)newServiceWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:kGenerateRequestService]) {
        return [[GenerateRequestService alloc]init];
    }
    return nil;
}

#pragma mark - getters and setters
- (NSMutableDictionary *)serviceStorage
{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc]init];
    }
    return _serviceStorage;
}


@end
