//
//  Flickr.m
//  FlickrFetcher
//
//  Created by Rachit on 11/25/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "Flickr.h"
#import "AppDelegate.h"
#import "FlickrOAuthTokenRequest.h"
#import "FlickrAccessTokenRequest.h"
#import "FlickrInterestingPhotosRequest.h"
#import "FlickrGetInfoForPhotoRequest.h"
#import "FlickrFavoriteRequest.h"

static NSString *consumerKey = @"ca0869ee37e969ec014805907785cfc0";
static NSString *secretKey = @"062776ab5a5cad27";

NSString * const accessTokenURL = @"https://www.flickr.com/services/oauth/access_token";
NSString * const authorizationURL = @"https://www.flickr.com/services/oauth/authorize";
NSString * const tokenURL = @"https://www.flickr.com/services/oauth/request_token";
NSString * const callbackURL = @"iosflickr://";

NSString * const restURL = @"https://api.flickr.com/services/rest";

NSString * const oauthAccessTokenKey = @"oauthAccessTokenKey";
NSString * const oauthAccesTokenSecretKey = @"oauthAccessTokenSecretKey";
NSString * const oauthVerifierKey = @"oauthVerifierKey";
NSString * const oauthAccessTokenDateKey = @"oauthAccessTokenDateKey";

NSString * const OAuthAccessTokenExpiredNotification = @"oauthAccessTokenExpiredNotification";


@interface Flickr()
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;
@property (nonatomic, strong) NSString *verifier;

@property (nonatomic, strong) NSString *oauthAccessToken;
@property (nonatomic, strong) NSString *oauthAccessTokenSecret;
@property (nonatomic, assign) BOOL oauthAccessTokenExpired;

@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSString *timestamp;

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation Flickr

@synthesize oauthAccessToken = _oauthAccessToken;
@synthesize oauthAccessTokenSecret = _oauthAccessTokenSecret;
@synthesize verifier = _verifier;

+(Flickr *)sharedFlickr{
    static Flickr *flickr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flickr = [[self alloc] init];
    });
    return flickr;
}


#pragma mark getters/setters

-(NSUserDefaults *)defaults{
    if (!_defaults){
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return _defaults;
}

-(BOOL)oauthAccessTokenExpired{
    NSDate *date = [self.defaults objectForKey:oauthAccessTokenDateKey];
    if (date){
        int seconds = -(int)[date timeIntervalSinceNow];
        int hours = seconds/3600;
        if (hours > 24){
            [self.defaults removeObjectForKey:oauthAccessTokenKey];
            [self.defaults removeObjectForKey:oauthAccessTokenDateKey];
            [self.defaults removeObjectForKey:oauthAccesTokenSecretKey];
            [self.defaults removeObjectForKey:oauthVerifierKey];
            [[NSNotificationCenter defaultCenter] postNotificationName:OAuthAccessTokenExpiredNotification object:nil];
            return YES;
        }
        else
            return NO;
    }else
        return NO;
    
}

-(void)setOauthAccessToken:(NSString *)oauthAccessToken{
    [self.defaults setObject:[NSDate date] forKey:oauthAccessTokenDateKey];
    [self.defaults setObject:oauthAccessToken forKey:oauthAccessTokenKey];
}

-(NSString *)oauthAccessToken{
    _oauthAccessToken = [self.defaults objectForKey:oauthAccessTokenKey];
    return _oauthAccessToken;
}

-(void)setOauthAccessTokenSecret:(NSString *)oauthAccessTokenSecret{
    [self.defaults setObject:oauthAccessTokenSecret forKey:oauthAccesTokenSecretKey];
}

-(NSString *)oauthAccessTokenSecret{
    _oauthAccessTokenSecret = [self.defaults objectForKey:oauthAccesTokenSecretKey];
    return _oauthAccessTokenSecret;
}

-(void)setVerifier:(NSString *)verifier{
    [self.defaults setObject:verifier forKey:oauthVerifierKey];
}

-(NSString *)verifier{
    _verifier = [self.defaults objectForKey:oauthVerifierKey];
    return _verifier;
}

#pragma mark request token

- (void)requestTokenWithCompletionHandler:(void(^)(NSString *authorizationURL,BOOL hasAccessToken, NSError *error))completionBlock
{
    if (self.oauthAccessToken){
        completionBlock(nil, YES, nil);
        return;
    }
    
    [self _generateNonce];
    [self _generateTimestamp];
    FlickrOAuthTokenRequest *tokenRequest = [[FlickrOAuthTokenRequest alloc] init];
    tokenRequest.oauthConsumerKey = consumerKey;
    tokenRequest.oauthSecretKey = secretKey;
    tokenRequest.oauthNonce = self.nonce;
    tokenRequest.oauthTimestamp = self.timestamp;
    tokenRequest.oauthCallBack = callbackURL;
    [tokenRequest requestWithCompletionHandler:^(FlickrOAuthTokenResponse *response, NSError *error) {
        self.oauthToken = response.oauthToken;
        self.oauthTokenSecret = response.oauthTokenSecret;
        NSString *authURL = [NSString stringWithFormat:@"%@?oauth_token=%@",authorizationURL,response.oauthToken];
        completionBlock(authURL,NO, error);
    }];
    
    //exchanging oauthRequestToken for access Token
    ((AppDelegate*)([UIApplication sharedApplication].delegate)).verifierCompletionBlock = ^(NSString *query){
        
        __block NSMutableDictionary *verifierResponse = [NSMutableDictionary dictionary];
        NSArray *verifierArray = [query componentsSeparatedByString:@"&"];
        [verifierArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *_ = [obj componentsSeparatedByString:@"="];
            [verifierResponse addEntriesFromDictionary:@{_[0]:_[1]}];
        }];
        
        self.verifier = [verifierResponse valueForKey:@"oauth_verifier"];
        
        [self _generateNonce];
        [self _generateTimestamp];
        FlickrAccessTokenRequest *accessRequest = [[FlickrAccessTokenRequest alloc] init];
        accessRequest.oauthConsumerKey = consumerKey;
        accessRequest.oauthSecretKey = secretKey;
        accessRequest.oauthToken = self.oauthToken;
        accessRequest.oauthTokenSecret = self.oauthTokenSecret;
        accessRequest.oauthNonce = self.nonce;
        accessRequest.oauthTimestamp = self.timestamp;
        accessRequest.oauthVerifier = self.verifier;
        [accessRequest requestWithCompletionHandler:^(FlickrAccessTokenResponse *response, NSError *error) {
            self.oauthAccessToken = response.accessToken;
            self.oauthAccessTokenSecret = response.accessTokenSecret;
            completionBlock(nil, YES, error);
        }];
    };
}

#pragma mark Interesting Photos
-(void)requestInterestingPhotosWithPageNumber:(NSNumber*)pageNumber CompletionHandler:(void(^)(NSMutableArray *photos, NSError *error))completionBlock {
    if (self.oauthAccessTokenExpired) return;
    [self _generateNonce];
    [self _generateTimestamp];
    FlickrInterestingPhotosRequest *interestingRequest = [[FlickrInterestingPhotosRequest alloc] init];
    interestingRequest.oauthConsumerKey = consumerKey;
    interestingRequest.oauthSecretKey = secretKey;
    interestingRequest.accessToken = self.oauthAccessToken;
    interestingRequest.accessTokenSecret = self.oauthAccessTokenSecret;
    interestingRequest.oauthNonce = self.nonce;
    interestingRequest.oauthVerifier = self.verifier;
    interestingRequest.oauthTimestamp = self.timestamp;
    interestingRequest.url = restURL;
    [interestingRequest requestWithPageNumber:pageNumber withCompletionHandler:^(NSMutableArray *photos, NSError *error) {
        completionBlock(photos,error);
    }];
}

-(void)requestInfoForPhoto:(NSString*)photoID secret:(NSString*)photoSecret completionHandler:(void (^)(BOOL isFavorite, NSError *error))completionBlock{
    if (self.oauthAccessTokenExpired) return;
    [self _generateNonce];
    [self _generateTimestamp];
    FlickrGetInfoForPhotoRequest *infoRequest = [[FlickrGetInfoForPhotoRequest alloc] init];
    infoRequest.oauthConsumerKey = consumerKey;
    infoRequest.oauthSecretKey = secretKey;
    infoRequest.accessToken = self.oauthAccessToken;
    infoRequest.accessTokenSecret = self.oauthAccessTokenSecret;
    infoRequest.oauthNonce = self.nonce;
    infoRequest.oauthTimestamp = self.timestamp;
    infoRequest.oauthVerifier = self.verifier;
    infoRequest.url = restURL;
    [infoRequest requestForPhoto:photoID secret:photoSecret withCompletionHandler:^(FlickrGetInfoForPhotoResponse *infoResponse, NSError *error) {
        if ([infoResponse.isFavorite isEqual:@0])
            completionBlock(YES, error);
        else
            completionBlock(NO, error);
    }];
}

-(void)requestToFavorite:(BOOL)favorite Photo:(NSString *)photoID completionHandler:(void (^)(BOOL ok, NSError *error))completionBlock{
    if (self.oauthAccessTokenExpired) return;
    [self _generateNonce];
    [self _generateTimestamp];
    FlickrFavoriteRequest *favoriteRequest = [[FlickrFavoriteRequest alloc] init];
    favoriteRequest.oauthConsumerKey = consumerKey;
    favoriteRequest.oauthSecretKey = secretKey;
    favoriteRequest.accessToken = self.oauthAccessToken;
    favoriteRequest.accessTokenSecret = self.oauthAccessTokenSecret;
    favoriteRequest.oauthNonce = self.nonce;
    favoriteRequest.oauthTimestamp = self.timestamp;
    favoriteRequest.oauthVerifier = self.verifier;
    favoriteRequest.url = restURL;
    [favoriteRequest requestToFavorite:favorite photo:photoID withCompletionHandler:^(FlickrFavoriteResponse *response, NSError *error) {
        if ([response.status isEqualToString:@"ok"])
            completionBlock(YES, error);
        else
            completionBlock(NO, error);
    }];
}


#pragma mark timestamp and nonce

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

@end
