//
//  FlickrInterestingPhotosRequest.m
//  FlickrFetcher
//
//  Created by Rachit on 11/30/15.
//  Copyright © 2015 Rachit. All rights reserved.
//



#import "FlickrInterestingPhotosRequest.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"
#import "Photo.h"

@implementation FlickrInterestingPhotosRequest
-(void)requestWithPageNumber:(NSNumber*)pageNumber withCompletionHandler:(void (^) (NSMutableArray *photos, NSError *error))completionBlock{
    NSLog(@"AccessToken:%@",self.accessToken);
    NSLog(@"AccessTokenSecret:%@",self.accessTokenSecret);
    NSDictionary *parameters = @{ @"oauth_consumer_key": self.oauthConsumerKey,
                                  @"oauth_nonce": self.oauthNonce,
                                  @"oauth_verifier":self.oauthVerifier,
                                  @"oauth_token":self.accessToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.oauthTimestamp,
                                  @"oauth_version": @"1.0",
                                  @"nojsoncallback":@"1",
                                  @"format":@"json",
                                  @"page":[pageNumber stringValue],
                                  @"method":@"flickr.interestingness.getList"
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
        //NSLog(@"json %@",json[@"photos"][@"photo"]);
        NSArray *_ = json[@"photos"][@"photo"];
        NSMutableArray *photos = [NSMutableArray array];
        [_ enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Photo *photo = [[Photo alloc] init];
            photo.farm = [(NSDictionary*)obj objectForKey:@"farm"];
            photo.ID = [(NSDictionary*)obj objectForKey:@"id"];
            photo.owner = [(NSDictionary*)obj objectForKey:@"owner"];
            photo.secret = [(NSDictionary*)obj objectForKey:@"secret"];
            photo.title = [(NSDictionary*)obj objectForKey:@"title"];
            photo.server = [(NSDictionary*)obj objectForKey:@"server"];
            [photos addObject:photo];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(photos,error);
        });
    }] resume];
}
@end
