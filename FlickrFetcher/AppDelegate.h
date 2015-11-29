//
//  AppDelegate.h
//  FlickrFetcher
//
//  Created by Rachit on 11/25/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^verifierBlock) (NSString *query);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) verifierBlock verifierCompletionBlock;

@end

