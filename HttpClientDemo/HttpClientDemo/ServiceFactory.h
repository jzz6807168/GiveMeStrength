//
//  ServiceFactory.h
//  HttpClientDemo
//
//  Created by qq on 16/5/3.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface ServiceFactory : NSObject

+ (instancetype)sharedInstance;
- (Service<ServiceProtocal> *)serviceWithIdentifier:(NSString *)identifier;

@end
