//
//  APILogger.m
//  HttpClientDemo
//
//  Created by qq on 16/5/4.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "APILogger.h"
#import "Service.h"
#import "NSDictionary+NetworkingMethods.h"
#import "NSObject+NetworkingMethods.h"
#import "NSMutableString+NetworkingMethods.h"
#import "NetworkingConfiguration.h"

@implementation APILogger

+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams responseParams:(id)responseParams httpMethod:(NSString *)httpMethod requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName
{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"URL:\t\t\t%@\n",[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [logString appendFormat:@"Method:\t\t%@\n", httpMethod];
    [logString appendFormat:@"requestId:\t\t%@\n",requestId];
    [logString appendFormat:@"apiName:\t\t%@\n",apiName];
    [logString appendFormat:@"description:\t%@\n",apiCmdDescription];
    [logString appendFormat:@"requestParams:\t%@\n",requestParams];
    [logString appendFormat:@"responseParams:\n%@", responseParams];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
    
}


+ (void)logDebugInfoWithURL:(NSString *)url requestParams:(id)requestParams httpMethod:(NSString *)httpMethod error:(NSError *)error requestId:(NSNumber *)requestId apiCmdDescription:(NSString *)apiCmdDescription apiName:(NSString *)apiName
{
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"URL:\t\t\t%@\n",url];
    [logString appendFormat:@"Method:\t\t%@\n", httpMethod];
    [logString appendFormat:@"requestId:\t\t%@\n",requestId];
    [logString appendFormat:@"apiName:\t\t%@\n",apiName];
    [logString appendFormat:@"description:\t%@\n",apiCmdDescription];
    [logString appendFormat:@"requestParams:\t%@\n",requestParams];
    [logString appendFormat:@"Error Domain:\t\t\t\t\t%@\n", error.domain];
    [logString appendFormat:@"Error Domain Code:\t\t\t\t%ld\n", (long)error.code];
    [logString appendFormat:@"Error Localized Description:\t\t%@\n", error.localizedDescription];
    [logString appendFormat:@"Error Localized Failure Reason:\t\t%@\n", error.localizedFailureReason];
    [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
}

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request apiName:(NSString *)apiName service:(Service *)service requestParams:(id)requestParams httpMethod:(NSString *)httpMethod
{
#ifdef DEBUGLOG
    BOOL isOnline = NO;
    if ([service respondsToSelector:@selector(isOnline)]) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[service methodSignatureForSelector:@selector(isOnline)]];
        invocation.target = service;
        invocation.selector = @selector(isOnline);
        [invocation invoke];
        [invocation getReturnValue:&isOnline];
    }
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", [apiName defaultValue:@"N/A"]];
    [logString appendFormat:@"Method:\t\t\t%@\n", [httpMethod defaultValue:@"N/A"]];
    [logString appendFormat:@"Version:\t\t%@\n", [service.apiVersion defaultValue:@"N/A"]];
    [logString appendFormat:@"Service:\t\t%@\n", [service class]];
    [logString appendFormat:@"Status:\t\t\t%@\n", isOnline ? @"online" : @"offline"];
    [logString appendFormat:@"Public Key:\t\t%@\n", [service.publicKey defaultValue:@"N/A"]];
    [logString appendFormat:@"Private Key:\t%@\n", [service.privateKey defaultValue:@"N/A"]];
    [logString appendFormat:@"Params:\n%@", requestParams];
    
    [logString appendUrlRequest:request];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}

+ (void)logDebugInfoWithResponse:(NSHTTPURLResponse *)response resposeString:(NSString *)responseString request:(NSURLRequest *)request error:(NSError *)error
{
#ifdef DEBUGLOG
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n%@\n\n", responseString];
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendUrlRequest:request];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
    
    NSLog(@"%@", logString);
#endif
}


@end

