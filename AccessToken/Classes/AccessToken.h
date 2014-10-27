//
//  AccessToken.h
//  AccessToken
//
//  Created by 胡 桓铭 on 14/8/13.
//
//  Updated version 2 by hu on 14/10/27
//
//  Copyright (c) 2014年 agile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Created by hu on 14/8/13.
 *
 * Updated 1.0 by hu on 14/10/26
 *
 * AccessToken is a generic class base NSObject that build a access token which used to
 *  authenticated.
 * Subclasses can branched their custom attributes, or methods.
 *
 */

@interface AccessToken : NSObject

/**
 *  To determine whether there is a token and key.
 */
@property (readonly)Boolean isHasTokenAndKey;

/**
 *  Get static AccessToken instace.
 *
 *  @return AccessToken AccessToken Instance
 */

+(AccessToken *)sharedInstance;


/**
 *  Assign a value to token and key.
 *
 *  @param theToken token is gave by authenticated server
 *  @param thekey key is gave by authenticated server
 */

- (void)setToken:(NSString *)theToken AndKey:(NSString *)theKey;

/**
 *  Generate a params with access token.
 *
 *  @param params
 *  @param ttl it is the time for token‘s life. if this time bigger than 600s, it will be equal to 300s.
 *
 *  @return NSDictionary It can be upload to server.
 */
- (NSDictionary *)encode:(NSDictionary *)params AndTTL:(unsigned int)ttl;

/**
 *  Generate a params with access token and 300s life
 *
 *  @param params
 *  @return NSDictionary It can be upload to server.
 */
- (NSDictionary *)encode:(NSDictionary *)params;

/**
 *  remove token and key.
 */
- (void)clearTokenAndKey;

@end
