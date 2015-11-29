//
//  Photo.h
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Photo : NSObject
@property (nonatomic, strong) NSString *farm;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSString *largeImageURL;

@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, getter = isFailed) BOOL failed;
@property (nonatomic, strong) UIImage *image;

@end
