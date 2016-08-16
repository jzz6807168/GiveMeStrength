//
//  Config.h
//  moa
//
//  Created by zenith on 14/12/5.
//  Copyright (c) 2014年 xidibuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (nonatomic,copy) NSString *currentView;//当前视图。1/2/3
@property NSMutableDictionary *kv;

+ (Config*)sharedConfig;

- (NSString *)md5:(NSString *) input;
- (NSString *)encrypt:(NSString*)input WithKey:(NSString *)key;
- (NSString *)trim2mac:(NSString *)input;
- (BOOL)updateMoa;

@end
