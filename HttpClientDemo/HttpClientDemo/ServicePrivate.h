//
//  ServicePrivate.h
//  HttpClientDemo
//
//  Created by qq on 16/5/3.
//  Copyright © 2016年 qq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicePrivate : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

@end
