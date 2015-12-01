//
//  DetailPhotoViewController.m
//  FlickrFetcher
//
//  Created by Rachit on 11/29/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "DetailPhotoViewController.h"
#import "MBProgressHUD.h"
#import "Flickr.h"

@interface DetailPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *favorite;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation DetailPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.title = self.title;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [queue addOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:self.imageURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
            [[Flickr sharedFlickr] requestInfoForPhoto:self.photoID secret:self.secret completionHandler:^(BOOL isFavorite) {
                if (isFavorite)
                    self.favorite.title = @"Favorite";
                else
                    self.favorite.title = @"Remove Favorite";
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
        });
    }];
}
- (IBAction)makeFavorite:(UIBarButtonItem *)sender {

    if ([sender.title isEqualToString:@"Favorite"]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Adding Favorite";
        [[Flickr sharedFlickr] requestToFavorite:YES Photo:self.photoID completionHandler:^(BOOL ok) {
            if (ok)
                sender.title = @"Remove Favorite";
            [hud hide:YES];
        }];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Removing Favorite";
        [[Flickr sharedFlickr] requestToFavorite:NO Photo:self.photoID completionHandler:^(BOOL ok) {
            if (ok)
                sender.title = @"Favorite";
            [hud hide:YES];
        }];
    }
    
}

-(void)unwindToLogin:(NSNotification*)notification
{
    [self performSegueWithIdentifier:@"loginUserForExpiredAccesTokenSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unwindToLogin:) name:OAuthAccessTokenExpiredNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
