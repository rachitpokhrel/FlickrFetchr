//
//  FlickrOAuthTokenRequest.m
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "FlickrOAuthTokenRequest.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"

NSString * const requestTokenURL = @"https://www.flickr.com/services/oauth/request_token";

@interface FlickrOAuthTokenRequest()

@end

@implementation FlickrOAuthTokenRequest
-(void)requestWithCompletionHandler:(void (^) (FlickrOAuthTokenResponse *response, NSError *error))completionBlock {
    NSDictionary *parameters = @{ @"oauth_consumer_key": self.oauthConsumerKey,
                                  @"oauth_nonce": self.oauthNonce,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.oauthTimestamp,
                                  @"oauth_callback": self.oauthCallBack,
                                  @"oauth_version": @"1.0"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",self.oauthSecretKey,@""];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:requestTokenURL methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [NSString stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",requestTokenURL,stringParameters];
    
    NSOperationQueue *tokenQueue = [[NSOperationQueue alloc] init];
    
    [tokenQueue addOperationWithBlock:^{
        NSError *error = nil;
        NSString *tokenResults = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"tokenResults:%@",tokenResults);
        
        __block NSMutableDictionary *result = [NSMutableDictionary dictionary];
        NSArray *resultArray = [tokenResults componentsSeparatedByString:@"&"];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *_ = [obj componentsSeparatedByString:@"="];
            [result addEntriesFromDictionary:@{_[0]:_[1]}];
        }];
        
        FlickrOAuthTokenResponse *response = [[FlickrOAuthTokenResponse alloc] init];
        response.oauthToken = [result valueForKey:@"oauth_token"];
        response.oauthTokenSecret = [result valueForKey:@"oauth_token_secret"];
        NSLog(@"%@,%@",response.oauthToken,response.oauthTokenSecret);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response, error);
        });
    }];
}
@end
