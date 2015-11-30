//
//  FlickrFavoriteRequest.m
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "FlickrFavoriteRequest.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"

@implementation FlickrFavoriteRequest
-(void)requestToFavorite:(BOOL)favorite photo:(NSString*)photoID withCompletionHandler:(void(^)(FlickrFavoriteResponse *response, NSError *error))completionBlock{
    NSString *method;
    if (favorite)
        method = [NSString stringWithFormat:@"flickr.favorites.add"];
    else
        method = [NSString stringWithFormat:@"flickr.favorites.remove"];
    
    NSDictionary *parameters = @{ @"oauth_consumer_key": self.oauthConsumerKey,
                                  @"oauth_nonce": self.oauthNonce,
                                  @"oauth_verifier":self.oauthVerifier,
                                  @"oauth_token":self.accessToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.oauthTimestamp,
                                  @"oauth_version": @"1.0",
                                  @"nojsoncallback":@"1",
                                  @"format":@"json",
                                  @"photo_id": photoID,
                                  @"method": method
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",self.oauthSecretKey,self.accessTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:self.url methog:@"POST" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [NSString stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",self.url,stringParameters];
    
    NSOperationQueue *favoriteQueue = [[NSOperationQueue alloc] init];
    [favoriteQueue addOperationWithBlock:^{
        NSError *error = nil;
        NSString *favoriteResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"favoritesresults:%@",favoriteResult);
        FlickrFavoriteResponse *response = [[FlickrFavoriteResponse alloc] init];
        if ([favoriteResult containsString:@"ok"])
            response.status = @"ok";
        else
            response.status = @"";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response, error);
        });
    }];
}
@end
