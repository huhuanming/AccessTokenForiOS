//
//  AccessTokenTests.m
//  AccessTokenTests
//
//  Created by 胡 桓铭 on 14/8/13.
//  Copyright (c) 2014年 agile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#include "AccessToken.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface AccessTokenTests : XCTestCase

@end

@implementation AccessTokenTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testVersion {
    XCTAssertEqual([AccessToken version], 2);
}

- (void)testIsHasToken {
    [[AccessToken sharedInstance] clearTokenAndKey];
    Boolean exIsHasToken = [[AccessToken sharedInstance] isHasTokenAndKey];
    XCTAssertFalse(exIsHasToken);

    [[AccessToken sharedInstance] setToken:@"4c20393e-c2bc-4238-94a7-6182474286af" AndKey:@"--iS-TOfVaa1HUf1AJmQ0Q"];
    Boolean isHasTokenAndKey = [[AccessToken sharedInstance] isHasTokenAndKey];
    XCTAssertTrue(isHasTokenAndKey);
    
    [[AccessToken sharedInstance] clearTokenAndKey];
    XCTAssertFalse(exIsHasToken);
}

- (void)testEncodeParams {
    [[AccessToken sharedInstance] setToken:@"4c20393e-c2bc-4238-94a7-6182474286af" AndKey:@"--iS-TOfVaa1HUf1AJmQ0Q"];
    
    NSMutableDictionary *mutableParams = [[NSMutableDictionary alloc] init];
    [mutableParams setObject:@"哈哈哈.." forKey:@"a"];
    [mutableParams setObject:@"\"\"\"" forKey:@"b"];
    [mutableParams setObject:[NSNumber numberWithInt:12343] forKey:@"c"];
    
    NSDictionary *params = [[AccessToken sharedInstance] encode:[mutableParams copy]];
    
    XCTAssertEqual(params.count, 3);
    XCTAssertEqualObjects(params[@"token"], @"4c20393e-c2bc-4238-94a7-6182474286af");
    
    NSString *base64Params = [self urlSafeBase64Decode:params[@"params"]];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64Params options:0];
    NSString *decodedBase64Params = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[decodedBase64Params dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    XCTAssertEqualObjects(json[@"a"], mutableParams[@"a"]);
    XCTAssertEqualObjects(json[@"b"], mutableParams[@"b"]);
    XCTAssertEqualObjects(json[@"c"], mutableParams[@"c"]);
    XCTAssertNotNil(json[@"deadline"]);
    XCTAssertNotNil(json[@"device"]);
    XCTAssertEqualObjects([self hmac_sha1:@"--iS-TOfVaa1HUf1AJmQ0Q" text:params[@"params"]], params[@"encryption"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (NSString *)hmac_sha1:(NSString *)theKey text:(NSString *)text{
    
    const char *cKey  = [theKey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    
    char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    return [self urlSafeBase64Encode:[HMAC base64EncodedStringWithOptions:0]];
}

- (NSString *)urlSafeBase64Encode:(NSString *)string
{
    NSString *theString = string;
    theString = [theString stringByReplacingOccurrencesOfString:@"=" withString:@"."];
    theString = [theString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    theString = [theString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return theString;
}


- (NSString *)urlSafeBase64Decode:(NSString *)string
{
    NSString *theString = string;
    theString = [theString stringByReplacingOccurrencesOfString:@"." withString:@"="];
    theString = [theString stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
    theString = [theString stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
    return theString;
}

@end
