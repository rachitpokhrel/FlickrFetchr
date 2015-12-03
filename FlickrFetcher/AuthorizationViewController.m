//
//  AuthorizationViewController.m
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "Flickr.h"
#import "MBProgressHUD.h"

@interface AuthorizationViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Authorize With Flickr";
    [[Flickr sharedFlickr] requestTokenWithCompletionHandler:^(NSString *authorizationURL,BOOL hasAccessToken, NSError *error) {
        
        if (error){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {}];
            UIAlertAction* reloadAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self viewDidLoad];
            }];
            [alert addAction:reloadAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            if (!hasAccessToken){
                NSURL* url = [NSURL URLWithString:authorizationURL];
                NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                [self.webView loadRequest:request];
            }else{
                [self performSegueWithIdentifier:@"interestingPhotosSegue" sender:self];
            }
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

#pragma mark webview delegates
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
