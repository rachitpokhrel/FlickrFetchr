//
//  AuthorizationViewController.m
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "Flickr.h"

@interface AuthorizationViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Authorize With Flickr";
    [[Flickr sharedFlickr] requestTokenWithCompletionHandler:^(NSString *authorizationURL,BOOL hasAccessToken, NSError *error) {
        if (!hasAccessToken){
            NSURL* url = [NSURL URLWithString:authorizationURL];
            NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            [self.webView loadRequest:request];
        }else{
            [self performSegueWithIdentifier:@"interestingPhotosSegue" sender:self];
        }
        
    }];
}

-(IBAction)loginUserForExpiredAccesToken:(UIStoryboardSegue*)sender{
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
