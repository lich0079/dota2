//
//  XANImageViewController.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/18/PAGE_GAP/2.
//  Copyright 20PAGE_GAP/2 lazyapps.com. All rights reserved.
//

#import "XANImageViewController.h"
#import "XANThumbsViewController.h"
#import "XANThumbsCell.h"
#import "XANImageScrollView.h"
#import "config.h"
#import "MBProgressHUD.h"

@interface XANImageViewController()
- (void)updatePagingScrollViewLayout;
- (void)updatePagingScrollViewBounds;
- (void)updatePage:(XANImageScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (void)tilePages;
- (void)updateTitle;
- (XANImageScrollView *)dequeueRecycledPage;
@end

@implementation XANImageViewController
@synthesize showsDoneButton;
@synthesize dataSource, delegate;

- (UIImage *)currentImage
{
  for (XANImageScrollView *page in visiblePages)
    if (page.index == currentImageIndex)
      return page.image;
    
  return nil;
}

- (id)initWithInitialImageIndex:(NSUInteger)theInitialImageIndex 
                     dataSource:(id <XANImageViewControllerDataSource>)theDataSource
                       delegate:(id <XANImageViewControllerDelegate>)theDelegate
{
  if (self = [super initWithNibName:nil bundle:nil]){
    currentImageIndex = theInitialImageIndex;
    self.dataSource = theDataSource;
    self.delegate = theDelegate;
    visiblePages = [[NSMutableSet alloc] initWithCapacity:0];
    recycledPages = [[NSMutableSet alloc] initWithCapacity:0];
//    fromStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    self.wantsFullScreenLayout = YES;
  }
  
  return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
  pagingScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  pagingScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
  pagingScrollView.contentInset = UIEdgeInsetsZero;
  pagingScrollView.alwaysBounceVertical = NO;
  pagingScrollView.autoresizesSubviews = YES;
  pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |   UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  pagingScrollView.pagingEnabled = YES;
  pagingScrollView.delegate = self;
  pagingScrollView.showsHorizontalScrollIndicator = NO;
  pagingScrollView.showsVerticalScrollIndicator = NO;
  pagingScrollView.backgroundColor = [UIColor blackColor];

  UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
  view.autoresizingMask = YES;
  pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |   UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [view addSubview:pagingScrollView];
  [pagingScrollView release];
  self.view = view;
  [view release];

  prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left"] style:UIBarButtonItemStylePlain target:self action:@selector(prevImage:)];
  nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_right"] style:UIBarButtonItemStylePlain target:self action:@selector(nextImage:)];
  prevItem.enabled = currentImageIndex > 0;
  nextItem.enabled = currentImageIndex < [dataSource numberOfImages] - 1;
  UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  NSArray *items = [[NSArray alloc] initWithObjects:flexibleItem, prevItem, flexibleItem, nextItem, flexibleItem, nil];
  [prevItem release];
  [nextItem release];
  [flexibleItem release];

  self.toolbarItems = items;
  [items release];
  
  self.navigationController.navigationBar.barStyle
  = self.navigationController.toolbar.barStyle
  = UIBarStyleBlack;
  self.navigationController.navigationBar.translucent
  = self.navigationController.toolbar.translucent
  = YES;
//  if(!ISPAD) [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
  self.navigationController.toolbarHidden = NO;
    
    
    [self backButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        self.navigationItem.rightBarButtonItem = [self shareButton];
    }else {
        UIBarButtonItem *actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(action:)];
        self.navigationItem.rightBarButtonItem = actionBtn;
        [actionBtn release];
    }
}

- (void)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) share {
    NSArray *activityItems = [NSArray arrayWithObjects:NSLocalizedString(@"sharetitle", nil), iTunesLink,[self currentImage], nil];
    UIActivityViewController *activityVC = [[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil]autorelease];;
    [self presentViewController:activityVC animated:YES completion:nil];
}
- (void)action:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"savetophoto",@"savetophoto"),NSLocalizedString(@"cancel",@"cancel"), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    [actionSheet release];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum([self currentImage],  self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.dimBackground = YES;
    } else{
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

#pragma mark -
#pragma mark Workaround

- (void)errorAlert:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil message:message delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"ok",@"ok") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error != NULL){
        [self errorAlert:[error localizedDescription]];
    } else {
        [self errorAlert:NSLocalizedString(@"savedone",@"savedone")];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  [self updatePagingScrollViewLayout];
  [self tilePages];
  for (XANImageScrollView *page in visiblePages){
    [self updatePage:page forIndex:page.index];
  }

  [self updateTitle];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration {
  fromInterfaceOrientation = self.interfaceOrientation;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) == UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) return;
      
  [self updatePagingScrollViewLayout];
  [self tilePages];
  for (XANImageScrollView *page in visiblePages){
    [self updatePage:page forIndex:page.index];
  }
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [visiblePages removeAllObjects];
  [recycledPages removeAllObjects];
}


- (void)dealloc {
    CLogc;
    
  [visiblePages release];
  [recycledPages release];
  self.dataSource = nil;
  self.delegate = nil;
  
  [super dealloc];
}

#pragma mark - 
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  [self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  CGRect visibleBounds = pagingScrollView.bounds;
  currentImageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  currentImageIndex = MAX(currentImageIndex, 0);
  
  if (currentImageIndex == 0){
    prevItem.enabled = NO;
    nextItem.enabled = ([dataSource numberOfImages] > 1);
  } else if (currentImageIndex == [dataSource numberOfImages] - 1){
    nextItem.enabled = NO;
    prevItem.enabled = ([dataSource numberOfImages] > 1);
  } else {
    prevItem.enabled = YES;
    nextItem.enabled = YES;
  }
  [self updateTitle];
}

#pragma mark privates
- (void)updatePagingScrollViewLayout
{
  CGRect frame = self.view.bounds;
  frame.origin.x -= PAGE_GAP/2;
  frame.size.width += PAGE_GAP;
  pagingScrollView.frame = frame;
  pagingScrollView.contentSize = CGSizeMake(frame.size.width * [dataSource numberOfImages], frame.size.height);
  [self updatePagingScrollViewBounds];
}

- (void)updatePagingScrollViewBounds
{
  CGRect bounds = pagingScrollView.bounds;
  bounds.origin.x = pagingScrollView.frame.size.width * currentImageIndex;
  pagingScrollView.bounds = bounds;
}

- (void)updatePage:(XANImageScrollView *)page
          forIndex:(NSUInteger)index
{
  page.index = index;
  CGRect frame = self.view.bounds;
  frame.origin.x = (frame.size.width + PAGE_GAP) * page.index + PAGE_GAP/2;
  page.frame = frame;
  page.image = [dataSource imageForIndex:page.index];
  [page updateLayout];
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
  for (XANImageScrollView *page in visiblePages){
    if (page.index == index)
      return YES;
  }
  
  return NO;
}

- (void)tilePages
{
  CGRect visibleBounds = pagingScrollView.bounds;
  NSInteger firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
  NSInteger lastNeededPageIndex = floorf(CGRectGetMaxX(visibleBounds) / CGRectGetWidth(visibleBounds));
  
  firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
  lastNeededPageIndex = MIN(lastNeededPageIndex, [dataSource numberOfImages]-1);

  for (XANImageScrollView *page in visiblePages){
    if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex){
      [recycledPages addObject:page];
      [page removeFromSuperview];
      page.image = nil;
    }
  }

  [visiblePages minusSet:recycledPages];

  for (NSUInteger index=firstNeededPageIndex; index<=lastNeededPageIndex; index++){
    if (![self isDisplayingPageForIndex:index]){
      XANImageScrollView *page = [self dequeueRecycledPage];
      if (page == nil){
        page = [[[XANImageScrollView alloc] initWithFrame:CGRectZero] autorelease];
        
        UITapGestureRecognizer *doubleTap = nil;
        for (UIGestureRecognizer *gr in page.gestureRecognizers){
          if ([gr isKindOfClass:[UITapGestureRecognizer class]]){
            doubleTap = (UITapGestureRecognizer *)gr;
            break;
          }
        }
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [page addGestureRecognizer:singleTap];
        [singleTap release];
      }
      [visiblePages addObject:page];
      [pagingScrollView addSubview:page];
      [self updatePage:page forIndex:index];
    }
  }
}

- (void)updateTitle
{
  self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d", nil), currentImageIndex+1, [dataSource numberOfImages]];
}

- (XANImageScrollView *)dequeueRecycledPage
{
  XANImageScrollView *page = [recycledPages anyObject];
  if (page){
    [[page retain] autorelease];
    [recycledPages removeObject:page];
  }

  return page;
}

- (void)done
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
//  [UIApplication sharedApplication].statusBarStyle = fromStatusBarStyle;
  if ([delegate respondsToSelector:@selector(doneWithImageViewController:)])
      [delegate doneWithImageViewController:self];
}

#pragma mark UITapGestureRecognizer actions
- (void)handleSingleTap:(UITapGestureRecognizer *)tgr
{
  BOOL hidden = self.navigationController.navigationBarHidden;
//  [[UIApplication sharedApplication] setStatusBarHidden:!hidden withAnimation:UIStatusBarAnimationFade];
  [self.navigationController setNavigationBarHidden:!hidden animated:YES];
  [self.navigationController setToolbarHidden:!hidden animated:YES];  
}

#pragma mark UIBarButtonItem actions
- (void)prevImage:(UIBarButtonItem *)sender
{
  currentImageIndex--;
  if (currentImageIndex == 0) prevItem.enabled = NO;
  if ([dataSource numberOfImages] > 1) nextItem.enabled = YES;

  [self updatePagingScrollViewBounds];
  [self tilePages];
  [self updateTitle];
}

- (void)nextImage:(UIBarButtonItem *)sender
{
  currentImageIndex++;
  if (currentImageIndex == [dataSource numberOfImages] - 1) nextItem.enabled = NO;
  if ([dataSource numberOfImages] > 1) prevItem.enabled = YES;

  [self updatePagingScrollViewBounds];
  [self tilePages];
  [self updateTitle];
}

@end
