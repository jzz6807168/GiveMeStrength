//
//  NSArray+NetworkingMethods.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "NSArray+NetworkingMethods.h"

@implementation NSArray (NetworkingMethods)

/** 字母排序之后形成的参数字符串 */
- (NSString *)paramsString
{
    NSMutableString *paramsSting = [[NSMutableString alloc]init];
    
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([paramsSting length] == 0) {
            [paramsSting appendFormat:@"%@",obj];
        } else {
            [paramsSting appendFormat:@"&%@",obj];
        }
    }];
    
    return paramsSting;
}

/** 数组转json */
- (NSString *)jsonString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
