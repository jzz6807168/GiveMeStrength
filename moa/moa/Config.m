//
//  Config.m
//  moa
//
//  Created by zenith on 14/12/5.
//  Copyright (c) 2014年 xidibuy. All rights reserved.
//

#import "Config.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation Config
static Config *sharedGlobalData = nil;

+ (Config*)sharedConfig {
    if (sharedGlobalData == nil) {
        sharedGlobalData = [[super allocWithZone:NULL] init];
        sharedGlobalData.currentView = @"1";
        //TODO 注意多线程问题。
        sharedGlobalData.kv =[NSMutableDictionary new];
        [sharedGlobalData.kv setObject:@"b62171O9j14mz5RT" forKey:@"_DATA_XIDIMOA_SIGN"];
        [sharedGlobalData.kv setObject:@"j14mz5RT" forKey:@"_DATA_XIDIMOA_ENCRYPT_KEY"];

        [sharedGlobalData.kv setObject:@"https://moa.xiditech.com" forKey:@"_DOMAIN_XIDI_MOA"];
        [sharedGlobalData.kv setObject:[[sharedGlobalData.kv objectForKey:@"_DOMAIN_XIDI_MOA"] stringByAppendingString:@"/device/check"] forKey:@"_URL_AUTH_DEVICE"];
        [sharedGlobalData.kv setObject:[[sharedGlobalData.kv objectForKey:@"_DOMAIN_XIDI_MOA"] stringByAppendingString:@"/device/save"] forKey:@"_URL_AUTH_DEVICE_APPLY"];
        [sharedGlobalData.kv setObject:[[sharedGlobalData.kv objectForKey:@"_DOMAIN_XIDI_MOA"] stringByAppendingString:@"/passport/check"] forKey:@"_URL_AUTH_PASSPORT_CHECK"];
        [sharedGlobalData.kv setObject:[[sharedGlobalData.kv objectForKey:@"_DOMAIN_XIDI_MOA"] stringByAppendingString:@"/passport/sign"] forKey:@"_URL_AUTH_PASSPORT_SIGN"];

    }
    return sharedGlobalData;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (sharedGlobalData == nil)
        {
            sharedGlobalData = [super allocWithZone:zone];
            return sharedGlobalData;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
/**
 *  计算md5
 *
 *  @param input 输入字符串
 *
 *  @return 输出字符串
 */
- (NSString *) md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

- (NSString *)trim2mac:(NSString *)input {
    input=[[self md5:input] lowercaseString];
    NSMutableString *ret=[NSMutableString new];
    for (int i=0; i<6; i++) {
        [ret appendString:@":"];
        [ret appendString:[input substringWithRange:NSMakeRange(i*2, 2)]];
    }
    return [ret substringFromIndex:1];
}

/**
 *  对应java的DES/CBC/PKCS5Padding加密算法。
 *
 *  @param input 输入字符串
 *  @param key   加密key
 *
 *  @return 16进制表示的加密后的字符串
 */
- (NSString *)encrypt:(NSString*)input WithKey:(NSString *)key {
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;
    
    NSMutableData *keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    NSMutableData *ivData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    NSData *inputData=[input dataUsingEncoding:NSUTF8StringEncoding];
    [keyData setLength: 8];//非常重要！！！iOS默认API是PKCS7Padding，而java是PKCS5Padding
    
    status = CCCryptorCreate( kCCEncrypt, kCCAlgorithmDES, kCCOptionPKCS7Padding,
                             [keyData bytes], [keyData length], [ivData bytes],
                             &cryptor );
    
    size_t bufsize = CCCryptorGetOutputLength( cryptor, (size_t)[inputData length], true );
    void * buf = malloc( bufsize );
    size_t bufused = 0;
    size_t bytesTotal = 0;
    status = CCCryptorUpdate( cryptor, [inputData bytes], (size_t)[inputData length],
                             buf, bufsize, &bufused );
    bytesTotal += bufused;
    status = CCCryptorFinal( cryptor, buf + bufused, bufsize - bufused, &bufused );
    bytesTotal += bufused;
    NSData *outputData=[NSData dataWithBytesNoCopy: buf length: bytesTotal] ;
    
    //NSData 转换成16进制字符串
    const unsigned char *dataBuffer = (const unsigned char *)[outputData bytes];
    NSUInteger          dataLength  = [outputData length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

- (BOOL)updateMoa {
    BOOL updateAvailable = NO;
    
    NSDictionary *updateDictionary = [NSDictionary dictionaryWithContentsOfURL:
                                      [NSURL URLWithString:@"https://moa.xiditech.com/download/moa/moa.plist"]];
    if(updateDictionary)
    {
        NSArray *items = [updateDictionary objectForKey:@"items"];
        NSDictionary *itemDict = [items lastObject];
        
        NSDictionary *metaData = [itemDict objectForKey:@"metadata"];
        NSString *newversion = [metaData valueForKey:@"bundle-version"];
        NSString *currentversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        updateAvailable = [newversion compare:currentversion options:NSNumericSearch] == NSOrderedDescending;
    }
    
    return updateAvailable;
}

@end
