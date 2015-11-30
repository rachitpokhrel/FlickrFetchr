//
//  FlickrAccessTokenRequest.m
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "FlickrAccessTokenRequest.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"

NSString * const oauthAccessTokenURL = @"https://www.flickr.com/services/oauth/access_token";

@interface FlickrAccessTokenRequest()

@end

@implementation FlickrAccessTokenRequest
-(void)requestWithCompletionHandler:(void (^) (FlickrAccessTokenResponse *response, NSError *error))completionBlock{
    NSDictionary *parameters = @{ @"oauth_consumer_key": self.oauthConsumerKey,
                                  @"oauth_nonce": self.oauthNonce,
                                  @"oauth_verifier":self.oauthVerifier,
                                  @"oauth_token":self.oauthToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.oauthTimestamp,
                                  @"oauth_version": @"1.0"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",self.oauthSecretKey,self.oauthTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:oauthAccessTokenURL methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [NSString stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",oauthAccessTokenURL,stringParameters];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
        NSError *error = nil;
        NSString *results = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"results:%@",results);
        __block NSMutableDictionary *access = [NSMutableDictionary dictionary];
        NSArray *accessTokenArray = [results componentsSeparatedByString:@"&"];
        [accessTokenArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *_ = [obj componentsSeparatedByString:@"="];
            [access addEntriesFromDictionary:@{_[0]:_[1]}];
        }];
        
        FlickrAccessTokenResponse *response = [[FlickrAccessTokenResponse alloc] init];
        response.fullname = [access objectForKey:@"fullname"];
        response.accessToken = [access objectForKey:@"oauth_token"];
        response.accessTokenSecret = [access objectForKey:@"oauth_token_secret"];
        response.userID = [access objectForKey:@"user_nsid"];
        response.username = [access objectForKey:@"username"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response, error);
        });
        
    }];
}
@end
