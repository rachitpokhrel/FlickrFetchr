//
//  DetailPhotoViewController.h
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPhotoViewController : UIViewController
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *title;
@end
