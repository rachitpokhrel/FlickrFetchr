//
//  ImageDownloader.h
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@protocol  ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) Photo *photo;

// 4
- (id)initWithPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>) theDelegate;
@end

@protocol ImageDownloaderDelegate <NSObject>
- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader;
@end