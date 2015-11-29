//
//  FlickrSignatureProvider.m
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "FlickrSignatureProvider.h"
#import "NSString+URLEncoding.h"
#import <CommonCrypto/CommonHMAC.h>
#include "Base64Transcoder.h"

@implementation FlickrSignatureProvider
+(NSString*)signatureFromURL:(NSString*)url methog:(NSString*)method params:(NSDictionary*)params secret:(NSString*)secret
{
    NSString *baseString = [self baseStringWithURL:url method:method parameters:params];
    return [self signatureWithBaseString:baseString secrect:secret];
}

+(NSString*)baseStringWithURL:(NSString*)url method:(NSString*)method parameters:(NSDictionary*)parameters
{
    NSString * _url = [url URLEncodedString];
    NSString * _parameters;
    NSArray *params = [NSArray array];
    NSArray *keys = [parameters allKeys];
    for (id key in keys)
    {
        params = [params arrayByAddingObject:[[NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [[parameters valueForKey:key] URLEncodedString]] URLEncodedString]];
    }
    
    //sort paramaters lexicographically
    params = [params sortedArrayUsingSelector:@selector(compare:)];
    _parameters = [params componentsJoinedByString:@"%26"];
    
    NSArray * baseComponents = [NSArray arrayWithObjects:
                                @"GET",
                                _url,    //The URL you're requesting, *not* including any GET parameters
                                _parameters,
                                nil];
    NSString * baseString = [baseComponents componentsJoinedByString:@"&"];
    return baseString;
}

+(NSString*)signatureWithBaseString:(NSString*)baseString secrect:(NSString*)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData * baseData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [baseData bytes], [baseData length], result);
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return base64EncodedResult;
}

@end
