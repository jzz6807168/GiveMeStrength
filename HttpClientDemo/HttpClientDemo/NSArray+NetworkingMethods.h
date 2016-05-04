//
//  NSArray+NetworkingMethods.h
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NetworkingMethods)

/** 字母排序之后形成的参数字符串 */
- (NSString *)paramsString;
/** 数组转json */
- (NSString *)jsonString;

@end
