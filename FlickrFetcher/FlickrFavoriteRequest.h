//
//  FlickrFavoriteRequest.h
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrFavoriteResponse.h"

@interface FlickrFavoriteRequest : NSObject
@property (nonatomic, strong) NSString *oauthConsumerKey;
@property (nonatomic, strong) NSString *oauthSecretKey;
@property (nonatomic, strong) NSString *oauthNonce;
@property (nonatomic, strong) NSString *oauthTimestamp;
@property (nonatomic, strong) NSString *oauthVerifier;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *accessTokenSecret;
@property (nonatomic, strong) NSString *url;

-(void)requestToFavorite:(BOOL)favorite photo:(NSString*)photoID withCompletionHandler:(void(^)(FlickrFavoriteResponse *response, NSError *error))completionBlock;
@end
