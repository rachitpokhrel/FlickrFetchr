//
//  FlickrGetInfoForPhotoRequest.m
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "FlickrGetInfoForPhotoRequest.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"

@implementation FlickrGetInfoForPhotoRequest
-(void)requestForPhoto:(NSString*)photoID secret:(NSString*)photoSecret withCompletionHandler:(void (^)(FlickrGetInfoForPhotoResponse *infoResponse, NSError *error))completionBlock{
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
                                  @"secret":photoSecret,
                                  @"method":@"flickr.photos.getInfo"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",self.oauthSecretKey,self.accessTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:self.url methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [NSString stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",self.url,stringParameters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        FlickrGetInfoForPhotoResponse *infoResponse = [[FlickrGetInfoForPhotoResponse alloc] init];
        infoResponse.isFavorite = json[@"photo"][@"isfavorite"];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(infoResponse,error);
        });
        
    }] resume];
}
@end
