//
//  NSMutableString+NetworkingMethods.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "NSMutableString+NetworkingMethods.h"
#import "NSObject+NetworkingMethods.h"

@implementation NSMutableString (NetworkingMethods)

- (void)appendUrlRequest:(NSURLRequest *)request
{
    [self appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [self appendFormat:@"\n\nHTTP Header\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [self appendFormat:@"\n\nHTTP Body\n\t%@", [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] defaultValue:@"\t\t\t\tN/A"]];
}

@end
