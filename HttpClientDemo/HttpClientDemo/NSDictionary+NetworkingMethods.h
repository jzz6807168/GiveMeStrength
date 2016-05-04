//
//  NSDictionary+NetworkingMethods.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NetworkingMethods)

/** 字符串前面是没有问号的，如果用于POST，那就不用加问号，如果用于GET，就要加个问号 */
- (NSString *)urlParamsString;
/** 字典转json */
- (NSString *)jsonString;
/** 转义参数 */
- (NSArray *)transformedUrlParamsArray;

@end
