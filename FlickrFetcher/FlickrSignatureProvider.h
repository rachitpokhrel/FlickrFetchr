//
//  FlickrSignatureProvider.h
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrSignatureProvider : NSObject
+(NSString*)signatureFromURL:(NSString*)url methog:(NSString*)method params:(NSDictionary*)params secret:(NSString*)secret;
@end
