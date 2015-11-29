//
//  ImageDownloader.m
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) Photo *photo;
@end

@implementation ImageDownloader
- (id)initWithPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate {
    
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photo = photo;
    }
    return self;
}

#pragma mark -
#pragma mark - Downloading image

- (void)main {
    @autoreleasepool {
        
        if (self.isCancelled) return;
        NSURL *url = [NSURL URLWithString:self.photo.thumbnailURL];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photo.image = downloadedImage;
        }
        else {
            self.photo.failed = YES;
        }
        
        imageData = nil;
        if (self.isCancelled) return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}
@end
