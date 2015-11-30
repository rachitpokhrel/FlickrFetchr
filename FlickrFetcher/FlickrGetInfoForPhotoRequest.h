//
//  FlickrGetInfoForPhotoRequest.h
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrGetInfoForPhotoResponse.h"

@interface FlickrGetInfoForPhotoRequest : NSObject
@property (nonatomic, strong) NSString *oauthConsumerKey;
@property (nonatomic, strong) NSString *oauthSecretKey;
@property (nonatomic, strong) NSString *oauthNonce;
@property (nonatomic, strong) NSString *oauthTimestamp;
@property (nonatomic, strong) NSString *oauthVerifier;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *accessTokenSecret;
@property (nonatomic, strong) NSString *url;

-(void)requestForPhoto:(NSString*)photoID secret:(NSString*)photoSecret withCompletionHandler:(void (^)(FlickrGetInfoForPhotoResponse *infoResponse, NSError *error))completionBlock;

@end
