//
//  AccessToken.m
//  AccessToken
//
//  Created by 胡 桓铭 on 14/8/13.
//  Updated version 2 by hu on 14/10/27
//  Copyright (c) 2014年 agile. All rights reserved.
//

#import "AccessToken.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

#define kisHasToken @"isHasTokenAndKey"
#define kToken @"tokenOfAccessToken"
#define kKey @"keyOfAccessToken"

@implementation AccessToken

+ (NSInteger)version
{
    return 2;
}

+(AccessToken *)sharedInstance
{
    static AccessToken *staticAccessToken;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticAccessToken = [[AccessToken alloc] init];
    });
    return staticAccessToken;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isHasTokenAndKey = [[NSUserDefaults standardUserDefaults] boolForKey:kisHasToken];
    }
    return self;
}

- (NSString*)token
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kToken];
}

- (NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kKey];
}

- (void)setToken:(NSString *)theToken AndKey:(NSString *)theKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:theToken forKey:kToken];
    [userDefaults setObject:theKey forKey:kKey];
    [userDefaults setBool:YES forKey:kisHasToken];
    [userDefaults synchronize];
    _isHasTokenAndKey = true;
}

- (NSDictionary *)encode:(NSDictionary *)params AndTTL:(unsigned int)ttl
{
    if (self.isHasTokenAndKey == false) {
        return nil;
    }
    unsigned int theTTL = ttl;
    if (theTTL > 600){
        theTTL = 600;
    }
    NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] init];
    
    [mutableParams setObject:[self token] forKey:@"token"];
    
    NSString *base64ParamsString = [self base64EncodeParams:params AndTTL:ttl];
    
    [mutableParams setObject:base64ParamsString forKey:@"params"];
    
    NSString *encryptionString = [self hmac_sha1:[self key] text:base64ParamsString];
    
    [mutableParams setObject:encryptionString forKey:@"encryption"];
    
    return [mutableParams copy];
}


- (NSString *)base64EncodeParams:(NSDictionary*)params AndTTL:(unsigned int)ttl
{
    NSMutableDictionary *mutableParams = [params mutableCopy];
    [mutableParams setObject:@"1" forKey:@"device"];
    [mutableParams setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970] + ttl] forKey:@"deadline"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[mutableParams copy]
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [self base64Encode:[self trim:jsonDataString]];
}


- (NSDictionary *)encode:(NSDictionary *)params
{
    return [self encode:params AndTTL:300];
}

- (NSString *)hmac_sha1:(NSString *)theKey text:(NSString *)text{
    
    const char *cKey  = [theKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    return [self urlSafeBase64Encode:[HMAC base64EncodedStringWithOptions:0]];
}

- (NSString *)base64Encode:(NSString *)string
{
    NSString *base64String = [[string dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    return [self urlSafeBase64Encode:base64String];
}

- (NSString *)trim:(NSString *)string
{
    NSString *theString = string;
    theString = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    theString = [theString stringByReplacingOccurrencesOfString:@" " withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    theString = [theString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    return theString;
}


- (NSString *)urlSafeBase64Encode:(NSString *)string
{
    NSString *theString = string;
    theString = [theString stringByReplacingOccurrencesOfString:@"=" withString:@"."];
    theString = [theString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    theString = [theString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return theString;
}

- (void)clearTokenAndKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kToken];
    [userDefaults removeObjectForKey:kKey];
    [userDefaults removeObjectForKey:kisHasToken];
    _isHasTokenAndKey = false;
    [userDefaults synchronize];
}

@end
