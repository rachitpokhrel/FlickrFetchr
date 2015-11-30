//
//  InterestingPhotosTableViewController.m
//  FlickrFetcher
//
//  Created by Rachit on 11/28/15.
//  Copyright © 2015 Rachit. All rights reserved.
//

#import "InterestingPhotosTableViewController.h"
#import "DetailPhotoViewController.h"
#import "MBProgressHUD.h"
#import "Flickr.h"
#import "Photo.h"


@interface InterestingPhotosTableViewController ()
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@property (nonatomic, assign, getter=isPagingRequestSent) BOOL pagingRequestSent;
@property (nonatomic, strong) NSNumber *pageNumber;
@end

@implementation InterestingPhotosTableViewController

-(NSMutableArray *)photos
{
    if (!_photos){
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

-(NSNumber *)pageNumber
{
    if (!_pageNumber){
        _pageNumber = @1;
    }
    return _pageNumber;
}

- (NSMutableDictionary *)downloadsInProgress {
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Interesting Photos";
    [self requestInterestingPhotos:self];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(requestInterestingPhotos:) forControlEvents:UIControlEventValueChanged];
}

-(void)requestInterestingPhotos:(id)sender{
    if ([sender isKindOfClass:[UIRefreshControl class]]){
        self.pageNumber = @1;
        [self requestInterestingPhotosForPageNumber:self.pageNumber sender:sender];
    }else
        [self requestInterestingPhotosForPageNumber:self.pageNumber sender:sender];
}

-(void)requestInterestingPhotosForPageNumber:(NSNumber*)pageNumber sender:(id)sender{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"pagenumber:%@",pageNumber);
    [[Flickr sharedFlickr] requestInterestingPhotosWithPageNumber:pageNumber CompletionHandler:^(NSMutableArray *photos, NSError *error) {
        [self updatePhotos:photos sender:sender];
    }];
}

-(void)updatePhotos:(NSMutableArray*)photos sender:(id)sender{
    if ([sender isKindOfClass:[UIRefreshControl class]]){
        if (photos)
            [self.photos removeAllObjects];
    }
    [self.photos addObjectsFromArray:photos];
    NSLog(@"photos:%@",self.photos);
    [self reloadData];
    self.pagingRequestSent = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.downloadQueue cancelAllOperations];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    [self.tableView reloadData];
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuseIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    cell.textLabel.numberOfLines = 0;
    Photo *photo = [self.photos objectAtIndex:indexPath.row];
    if (photo.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = photo.image;
        cell.textLabel.text = photo.title;
    }else if (photo.isFailed) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
    }else {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        [self startImageDownloadingForPhoto:photo atIndexPath:indexPath];
    }
    
    cell.textLabel.text = ((Photo*)self.photos[indexPath.row]).title;
    if (indexPath.row == [self.photos count] - 1 && !self.pagingRequestSent)
        [self lastCellReached];

    return cell;
}

- (void)startImageDownloadingForPhoto:(Photo *)photo atIndexPath:(NSIndexPath *)indexPath {
    if (![self.downloadsInProgress.allKeys containsObject:indexPath]) {
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhoto:photo atIndexPath:indexPath delegate:self];
        [self.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.downloadQueue addOperation:imageDownloader];
    }
}

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader {
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (downloader.photo.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = downloader.photo.image;
        cell.textLabel.text = downloader.photo.title;
    }else if (downloader.photo.isFailed) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
    }
    [self.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.downloadQueue setSuspended:YES];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self loadImagesForOnscreenCells];
        [self.downloadQueue setSuspended:NO];
    }
}

-(void)lastCellReached
{
    NSUInteger _number = [self.pageNumber integerValue];_number++;
    self.pageNumber = [NSNumber numberWithInteger:_number];
    [self requestInterestingPhotosForPageNumber:self.pageNumber sender:self];
    self.pagingRequestSent = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenCells];
    [self.downloadQueue setSuspended:NO];
}

- (void)loadImagesForOnscreenCells {
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.downloadsInProgress allKeys]];
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    [toBeStarted minusSet:pendingOperations];
    [toBeCancelled minusSet:visibleRows];
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        ImageDownloader *pendingDownload = [self.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.downloadsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    for (NSIndexPath *anIndexPath in toBeStarted) {
        Photo *photoToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startImageDownloadingForPhoto:photoToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetailSegue"]){
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
        DetailPhotoViewController *dpvc = [segue destinationViewController];
        dpvc.imageURL = ((Photo*)self.photos[indexPath.row]).largeImageURL;
        dpvc.photoID = ((Photo*)self.photos[indexPath.row]).ID;
        dpvc.secret = ((Photo*)self.photos[indexPath.row]).secret;
        dpvc.title = ((Photo*)self.photos[indexPath.row]).title;
    }
}


@end
