//
//  FlickrOAuthTokenResponse.h
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrOAuthTokenResponse : NSObject
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@end
