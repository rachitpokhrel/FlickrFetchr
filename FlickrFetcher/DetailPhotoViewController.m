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
            [self requestInfoForPhoto:self.photoID secret:self.secret];
        });
    }];
}

-(void)requestInfoForPhoto:(NSString*)photoID secret:(NSString*)secret
{
    [[Flickr sharedFlickr] requestInfoForPhoto:photoID secret:secret completionHandler:^(BOOL isFavorite, NSError *error) {
        if (error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {}];
            UIAlertAction* reloadAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self requestInfoForPhoto:photoID secret:secret];
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }];
            [alert addAction:reloadAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            if (isFavorite)
                self.favorite.title = @"Favorite";
            else
                self.favorite.title = @"Remove Favorite";
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (IBAction)makeFavorite:(UIBarButtonItem *)sender {

    if ([sender.title isEqualToString:@"Favorite"]){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Adding Favorite";
        [self requestTofavorite:YES photo:self.photoID hud:hud buttonTitle:@"Remove Favorite" sender:sender];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Removing Favorite";
        [self requestTofavorite:NO photo:self.photoID hud:hud buttonTitle:@"Favorite" sender:sender];
    }
    
}

-(void)requestTofavorite:(BOOL)favorite photo:(NSString*)photoID hud:(MBProgressHUD*)hud buttonTitle:(NSString*)title sender:(UIBarButtonItem *)sender
{
    [[Flickr sharedFlickr] requestToFavorite:favorite Photo:photoID completionHandler:^(BOOL ok, NSError *error) {
        
        if (error){
            [hud hide:YES];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {}];
            UIAlertAction* reloadAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self requestTofavorite:favorite photo:photoID hud:hud buttonTitle:title sender:sender];
                [hud show:YES];
            }];
            [alert addAction:reloadAction];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            if (ok)
                sender.title = title;
            [hud hide:YES];
        }
        
    }];
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
