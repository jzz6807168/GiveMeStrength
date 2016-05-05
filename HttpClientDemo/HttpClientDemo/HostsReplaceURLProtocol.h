//
//  HostsReplaceURLProtocol.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HostsReplaceConfigurationDelegate <NSObject>

- (void)replaceHostName:(NSString *)hostName toIPAddress:(NSString *)IPAddress;

@end

@interface HostsReplaceURLProtocol : NSURLProtocol

+ (void)configureHostsWithBlock:(void (^)(id <HostsReplaceConfigurationDelegate> configuration))block;

@end
