//
//  FlickrAccessTokenResponse.h
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrAccessTokenResponse : NSObject
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *accessTokenSecret;
@end
