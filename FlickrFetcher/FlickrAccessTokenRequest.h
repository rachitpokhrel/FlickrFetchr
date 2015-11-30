//
//  FlickrAccessTokenRequest.h
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrAccessTokenResponse.h"

@interface FlickrAccessTokenRequest : NSObject
@property (nonatomic, strong) NSString *oauthConsumerKey;
@property (nonatomic, strong) NSString *oauthSecretKey;
@property (nonatomic, strong) NSString *oauthNonce;
@property (nonatomic, strong) NSString *oauthTimestamp;
@property (nonatomic, strong) NSString *oauthVerifier;
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

-(void)requestWithCompletionHandler:(void (^) (FlickrAccessTokenResponse *response, NSError *error))completionBlock;
@end
