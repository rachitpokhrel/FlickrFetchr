//
//  FlickrOAuthTokenRequest.h
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrOAuthTokenResponse.h"

@interface FlickrOAuthTokenRequest : NSObject
@property (nonatomic, strong) NSString *oauthConsumerKey;
@property (nonatomic, strong) NSString *oauthSecretKey;
@property (nonatomic, strong) NSString *oauthNonce;
@property (nonatomic, strong) NSString *oauthTimestamp;
@property (nonatomic, strong) NSString *oauthCallBack;

-(void)requestWithCompletionHandler:(void (^) (FlickrOAuthTokenResponse *response, NSError *error))completionBlock;

@end
