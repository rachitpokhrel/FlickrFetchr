//
//  Flickr.h
//  FlickrFetcher
//
//  Created by Rachit on 11/25/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flickr : NSObject

+(Flickr*)sharedFlickr;
- (void)requestTokenWithCompletionHandler:(void(^)(NSString *authorizationURL,BOOL hasAccessToken, NSError *error))completionBlock;
-(void)requestInterestingPhotosWithPageNumber:(NSNumber*)pageNumber CompletionHandler:(void(^)(NSMutableArray *photos, NSError *error))completionBlock;
-(void)requestInfoForPhoto:(NSString*)photoID secret:(NSString*)photoSecret completionHandler:(void (^)(BOOL isFavorite))completionBlock;
-(void)requestToFavorite:(BOOL)favorite Photo:(NSString *)photoID completionHandler:(void (^)(BOOL ok))completionBlock;


@end