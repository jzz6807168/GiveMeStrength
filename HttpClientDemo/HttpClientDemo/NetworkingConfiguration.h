//
//  NetworkingConfiguration.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#ifndef HttpClientDemo_NetworkingConfiguration_h
#define HttpClientDemo_NetworkingConfiguration_h

typedef NS_ENUM(NSUInteger, URLResponseStatus)
{
    URLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的APIBaseCmd来决定。
    URLResponseStatusErrorTimeout,
    URLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

static NSTimeInterval kNetworkingTimeoutSeconds = 15.0f;

static NSString *const kReformParamArray = @"ReformParamArray";

#define DEBUGLOG

#define kConnectionProtocolKey  @"ConnectionProtocolKey"
#define kConnectionIPAddressKey @"ConnectionIPAddressKey"


#endif /* HttpClientDemo_NetworkingConfiguration_h */
