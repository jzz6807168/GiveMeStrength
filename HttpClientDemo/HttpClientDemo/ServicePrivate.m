//
//  ServicePrivate.m
//  HttpClientDemo
//
//  Created by qq on 16/5/3.
//  Copyright © 2016年 qq. All rights reserved.
//

#import "ServicePrivate.h"

@implementation ServicePrivate

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson{
    if ([json isKindOfClass:[NSDictionary class]] &&
        [validatorJson isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = json ;
        NSDictionary *validator = validatorJson ;
        BOOL result = YES ;
        NSEnumerator *enumerator = [validator keyEnumerator] ;
        NSString *key ;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]] ||
                [value isKindOfClass:[NSArray class]]) {
                result = [self checkJson:value withValidator:format];
                if (!result) {
                    break;
                }
            } else{
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
             [validatorJson isKindOfClass:[NSArray class]]){
        NSArray *validatorArray = (NSArray *)validatorJson ;
        if (validatorArray.count > 0) {
            NSArray *array = json;
            NSDictionary *validator = validatorJson[0];
            for (id item in array) {
                BOOL result = [self checkJson:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:validatorJson]){
        return YES;
    } else {
        return NO;
    }
}

@end
