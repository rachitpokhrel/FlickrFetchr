//
//  Flickr.m
//  FlickrFetcher
//
//  Created by Rachit on 11/25/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "Flickr.h"
#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"
#import "AppDelegate.h"
#import "Photo.h"

static NSString *consumerKey = @"ca0869ee37e969ec014805907785cfc0";
static NSString *secretKey = @"062776ab5a5cad27";

NSString * const accessTokenURL = @"https://www.flickr.com/services/oauth/access_token";
NSString * const authorizationURL = @"https://www.flickr.com/services/oauth/authorize";
NSString * const tokenURL = @"https://www.flickr.com/services/oauth/request_token";
NSString * const callbackURL = @"iosflickr://";

NSString * const restURL = @"https://api.flickr.com/services/rest";

NSString * const oauthConsumerKey = @"oauth_consumer_key";
NSString * const oauthCallback = @"oauth_callback";
NSString * const oauthNonce = @"oauth_nonce";
NSString * const oauthTimestamp = @"oauth_timestamp";
NSString * const oauthSignatureMethod = @"oauth_signature_method";
NSString * const oauthVersion = @"oauth_version";
NSString * const accountType = @"flickr";

NSString * const oauthSignature = @"oauth_signature";

NSString * const oauthToken = @"oauth_token";
NSString * const oauthTokenSecret = @"oauth_token_secret";

NSString * const oauthVerifier = @"oauth_verifier";


@interface Flickr()
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *verifier;

@property (nonatomic, strong) NSString *oauthAccessToken;
@property (nonatomic, strong) NSString *oauthAccessTokenSecret;

@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *timestamp;

@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;

@end

@implementation Flickr

+(Flickr *)sharedFlickr{
    static Flickr *flickr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flickr = [[self alloc] init];
    });
    return flickr;
}

- (void)requestTokenWithCompletionHandler:(void(^)(NSString *authorizationURL,BOOL hasAccessToken, NSError *error))completionBlock
{
    [self _generateNonce];
    [self _generateTimestamp];

    NSDictionary *parameters = @{ @"oauth_consumer_key": consumerKey,
                                  @"oauth_nonce": self.nonce,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.timestamp,
                                  @"oauth_callback": callbackURL,
                                  @"oauth_version": @"1.0"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",secretKey,@""];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:tokenURL methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [self stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",tokenURL,stringParameters];
    
    NSOperationQueue *tokenQueue = [[NSOperationQueue alloc] init];
    __block NSString *tokenResults;
    [tokenQueue addOperationWithBlock:^{
        NSError *error = nil;
        tokenResults = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"tokenResults:%@",tokenResults);
        __block NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
        NSArray *resultArray = [tokenResults componentsSeparatedByString:@"&"];
        [resultArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *_ = [obj componentsSeparatedByString:@"="];
            [resultDictionary addEntriesFromDictionary:@{_[0]:_[1]}];
        }];
        self.oauthToken = [resultDictionary valueForKey:@"oauth_token"];
        self.oauthTokenSecret = [resultDictionary valueForKey:@"oauth_token_secret"];
        NSLog(@"%@,%@",self.oauthToken,self.oauthTokenSecret);
         NSString *authURL = [NSString stringWithFormat:@"%@?oauth_token=%@",authorizationURL,self.oauthToken];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(authURL,NO, error);
        });
        
    }];
    
    //exchanging authToke for access Token
    ((AppDelegate*)([UIApplication sharedApplication].delegate)).verifierCompletionBlock = ^(NSString *query){
        
        
        __block NSMutableDictionary *verifierDictionary = [NSMutableDictionary dictionary];
        NSArray *verifierArray = [query componentsSeparatedByString:@"&"];
        [verifierArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *_ = [obj componentsSeparatedByString:@"="];
            [verifierDictionary addEntriesFromDictionary:@{_[0]:_[1]}];
        }];
        //self.oauthToken = [verifierDictionary valueForKey:@"oauth_token"];
        self.verifier = [verifierDictionary valueForKey:@"oauth_verifier"];
        
        [self _generateNonce];
        [self _generateTimestamp];
        
        NSDictionary *parameters = @{ @"oauth_consumer_key": consumerKey,
                                      @"oauth_nonce": self.nonce,
                                      @"oauth_verifier":self.verifier,
                                      @"oauth_token":self.oauthToken,
                                      @"oauth_signature_method": @"HMAC-SHA1",
                                      @"oauth_timestamp": self.timestamp,
                                      @"oauth_version": @"1.0"
                                      };
        
        NSString *secret = [NSString stringWithFormat:@"%@&%@",secretKey,self.oauthTokenSecret];
        NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:accessTokenURL methog:@"GET" params:parameters secret:secret];
        NSMutableDictionary *requestParameters = [parameters mutableCopy];
        [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
        NSString *stringParameters = [self stringFromParameters:requestParameters];
        NSString *url = [NSString stringWithFormat:@"%@?%@",accessTokenURL,stringParameters];
        
        NSOperationQueue *accessTokenQueue = [[NSOperationQueue alloc] init];
        __block NSString *accessTokenResults;
        [accessTokenQueue addOperationWithBlock:^{
            NSError *accessTokenError = nil;
            accessTokenResults = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&accessTokenError];
            NSLog(@"accessTokenresults:%@",accessTokenResults);
            __block NSMutableDictionary *accessTokenDictionary = [NSMutableDictionary dictionary];
            NSArray *accessTokenArray = [accessTokenResults componentsSeparatedByString:@"&"];
            [accessTokenArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *_ = [obj componentsSeparatedByString:@"="];
                [accessTokenDictionary addEntriesFromDictionary:@{_[0]:_[1]}];
            }];
            self.fullname = [accessTokenDictionary objectForKey:@"fullname"];
            self.oauthAccessToken = [accessTokenDictionary objectForKey:@"oauth_token"];
            self.oauthAccessTokenSecret = [accessTokenDictionary objectForKey:@"oauth_token_secret"];
            self.userID = [accessTokenDictionary objectForKey:@"user_nsid"];
            self.username = [accessTokenDictionary objectForKey:@"username"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil, YES, accessTokenError);
            });
            
        }];
    
    };
}



-(NSString*)stringFromParameters:(NSDictionary*)parameters{
    NSString * _parameters;
    NSArray *params = [NSArray array];
    NSArray *keys = [parameters allKeys];
    for (id key in keys)
    {
        params = [params arrayByAddingObject:[NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [[parameters valueForKey:key] URLEncodedString]]];
    }
    
    //sort paramaters lexicographically
    params = [params sortedArrayUsingSelector:@selector(compare:)];
    _parameters = [params componentsJoinedByString:@"&"];
    return _parameters;
}

- (void)_generateTimestamp
{
    self.timestamp = [NSString stringWithFormat:@"%ld", time(NULL)];
}

- (void)_generateNonce
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    
    self.nonce = (__bridge NSString *)string;
}

#pragma mark Interesting Photos



-(void)requestInterestingPhotosWithPageNumber:(NSNumber*)pageNumber CompletionHandler:(void(^)(NSMutableArray *photos, NSError *error))completionBlock {
    
    NSDictionary *parameters = @{ @"oauth_consumer_key": consumerKey,
                                  @"oauth_nonce": self.nonce,
                                  @"oauth_verifier":self.verifier,
                                  @"oauth_token":self.oauthAccessToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.timestamp,
                                  @"oauth_version": @"1.0",
                                  @"nojsoncallback":@"1",
                                  @"format":@"json",
                                  @"page":[pageNumber stringValue],
                                  @"method":@"flickr.interestingness.getList"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",secretKey,self.oauthAccessTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:restURL methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [self stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",restURL,stringParameters];

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

-(void)requestInfoForPhoto:(NSString*)photoID secret:(NSString*)photoSecret completionHandler:(void (^)(BOOL isFavorite))completionBlock{
    NSDictionary *parameters = @{ @"oauth_consumer_key": consumerKey,
                                  @"oauth_nonce": self.nonce,
                                  @"oauth_verifier":self.verifier,
                                  @"oauth_token":self.oauthAccessToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.timestamp,
                                  @"oauth_version": @"1.0",
                                  @"nojsoncallback":@"1",
                                  @"format":@"json",
                                  @"photo_id": photoID,
                                  @"secret":photoSecret,
                                  @"method":@"flickr.photos.getInfo"
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",secretKey,self.oauthAccessTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:restURL methog:@"GET" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [self stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",restURL,stringParameters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data,NSURLResponse *response, NSError *error) {
        NSError *jsonError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        //NSLog(@"json %@",json[@"photo"][@"isfavorite"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([json[@"photo"][@"isfavorite"] isEqual:@0])
                completionBlock(YES);
            else
                completionBlock(NO);
        });
        
    }] resume];
}

-(void)requestToFavorite:(BOOL)favorite Photo:(NSString *)photoID completionHandler:(void (^)(BOOL ok))completionBlock{
    NSString *method;
    if (favorite)
        method = [NSString stringWithFormat:@"flickr.favorites.add"];
    else
        method = [NSString stringWithFormat:@"flickr.favorites.remove"];
        
    NSDictionary *parameters = @{ @"oauth_consumer_key": consumerKey,
                                  @"oauth_nonce": self.nonce,
                                  @"oauth_verifier":self.verifier,
                                  @"oauth_token":self.oauthAccessToken,
                                  @"oauth_signature_method": @"HMAC-SHA1",
                                  @"oauth_timestamp": self.timestamp,
                                  @"oauth_version": @"1.0",
                                  @"nojsoncallback":@"1",
                                  @"format":@"json",
                                  @"photo_id": photoID,
                                  @"method": method
                                  };
    
    NSString *secret = [NSString stringWithFormat:@"%@&%@",secretKey,self.oauthAccessTokenSecret];
    NSString *oauth_signature = [FlickrSignatureProvider signatureFromURL:restURL methog:@"POST" params:parameters secret:secret];
    NSMutableDictionary *requestParameters = [parameters mutableCopy];
    [requestParameters addEntriesFromDictionary:@{@"oauth_signature":oauth_signature}];
    NSString *stringParameters = [self stringFromParameters:requestParameters];
    NSString *url = [NSString stringWithFormat:@"%@?%@",restURL,stringParameters];
    
    NSOperationQueue *favoriteQueue = [[NSOperationQueue alloc] init];
    [favoriteQueue addOperationWithBlock:^{
        NSError *error = nil;
        NSString *favoriteResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"favoritesresults:%@",favoriteResult);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([favoriteResult containsString:@"ok"])
                completionBlock(YES);
            else
                completionBlock(NO);
        });
    }];
}

@end
