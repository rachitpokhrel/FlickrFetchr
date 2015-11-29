//
//  Photo.m
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "Photo.h"

@implementation Photo
-(NSString *)description{
    return [NSString stringWithFormat:@"title:%@, thumbnailURL:%@, largeImageURL:%@",self.title, self.thumbnailURL, self.largeImageURL];
}

-(NSString *)thumbnailURL
{
    if (!_thumbnailURL){
        _thumbnailURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", self.farm, self.server, self.ID, self.secret, @"m"];
    }
    return _thumbnailURL;
}

-(NSString *)largeImageURL{
    if (!_largeImageURL){
        _largeImageURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg", self.farm, self.server, self.ID, self.secret, @"b"];
    }
    return _largeImageURL;
}

- (BOOL)hasImage {
    return _image != nil;
}

@end
