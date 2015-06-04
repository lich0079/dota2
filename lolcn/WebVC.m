//
//  WebVC.m
//  diablo3guide
//
//  Created by zhang yang on 11-12-5.
//  Copyright (c) 2011年 ibm. All rights reserved.
//

#import "WebVC.h"
#import "MBProgressHUD.h"

@implementation WebVC

@synthesize web,htmlName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        hasAddWeb = NO;
    }
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (!hasAddWeb) {
        CLogc;
        [self.view addSubview:self.web];
        hasAddWeb = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    NSURL *url = [webView.request URL];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[url lastPathComponent], @"url", nil];
    [FlurryAnalytics logEvent:a_url withParameters:dictionary];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    CLog(@"%@", [error description]);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect webSize = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height - 20);
    self.web = [[UIWebView alloc ] initWithFrame:webSize];
    [self.web release];
    
    NSURL *url;
    if(_isRemote){
        url = [NSURL URLWithString:htmlName];
        web.scalesPageToFit = YES;
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.html",htmlName] ofType:nil];
        url = [NSURL fileURLWithPath:path];
        
#ifdef FREE_VERSION
        if ([htmlName isEqualToString:@"Intro1"] ||
            [htmlName isEqualToString:@"Intro2"] ||
            [htmlName isEqualToString:@"Intro3"] ||
            [htmlName isEqualToString:@"Helpf"] ||
            [htmlName isEqualToString:@"Help"]) {
        }else{
            [self createAdmobGADBannerView];
        }
#endif
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
    web.delegate =self;
    web.dataDetectorTypes = UIDataDetectorTypeLink;
    UIScrollView *scroller = [web.subviews objectAtIndex:0];
    if (scroller){
        scroller.bounces = NO;
        scroller.alwaysBounceVertical = NO;
        scroller.alwaysBounceHorizontal = NO;
    }
    //turn page
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goForward)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];
    
    [self backButton];
    
    if (!hasAddWeb) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)goBack{
    [web goBack];
}

-(void)goForward{
    NSURL *url;
    if(_isRemote){
        url = [NSURL URLWithString:htmlName];
        web.scalesPageToFit = YES;
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.html",htmlName] ofType:nil];
        url = [NSURL fileURLWithPath:path];

    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
}

- (void)viewDidUnload {
#ifdef FREE_VERSION
    if(self.admobView){
        self.admobView.delegate=nil;
        [self.admobView release];
    }
#endif
    web.delegate = nil;
    [self setWeb:nil];
    hasAddWeb = NO;
    [super viewDidUnload];
}

- (void)dealloc {
    CLogc;
#ifdef FREE_VERSION
    if(self.admobView){
        self.admobView.delegate=nil;
        [self.admobView release];
    }
#endif
    web.delegate = nil;
    [web release];
    [super dealloc];
}


#pragma mark admob methods
#ifdef FREE_VERSION
-(void)createAdmobGADBannerView{
    self.admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.admobView.frame = CGRectMake(0.0,
                                      self.view.frame.size.height,
                                      GAD_SIZE_320x50.width,
                                      GAD_SIZE_320x50.height);
    self.admobView.adUnitID = @"a150b196682efe5";
    self.admobView.rootViewController = self;
    self.admobView.delegate = self;
    [self.view addSubview:self.admobView];
    GADRequest *request = [GADRequest request];
    
#ifdef DEBUG
    request.testing = YES;
#endif
    [self.admobView loadRequest:request];
    [self.admobView release];
    
}

// make room for show iAd or admob
-(void)layoutForCurrentOrientation:(BOOL)animated isLoadSuccess:(BOOL)isLoadSuccess
{
    CGFloat animationDuration = animated ? 0.2f : 0.0f;
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect viewSize = self.view.bounds;
    
    CGRect contentFrame = web.frame;
	
    CGPoint bannerOrigin ;
    if(self.admobView && isLoadSuccess){
//        contentFrame.size.height = viewSize.size.height - GAD_SIZE_320x50.height;
//        bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
        
        contentFrame.size.height = viewSize.size.height - GAD_SIZE_320x50.height;
        contentFrame.origin.y = GAD_SIZE_320x50.height;
        bannerOrigin = CGPointMake(0, 0);
    }else{
        CGRect webSize = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height - 20);
        contentFrame = webSize;
        bannerOrigin = CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds));
    }
    
    __block WebVC *tmp = self;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         tmp.web.frame = contentFrame;
                         tmp.admobView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, tmp.admobView.frame.size.width, tmp.admobView.frame.size.height);
                         [tmp.view setNeedsDisplay];
                     }];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    CLogc;
    [self layoutForCurrentOrientation:YES isLoadSuccess:YES];
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    CLogc;
    [self layoutForCurrentOrientation:YES isLoadSuccess:NO];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
}
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
}
#endif




#pragma mark share
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([[request.URL lastPathComponent] isEqualToString:@"share.html"]) {
        [self share];
        return NO;
    }
    return YES;
}

-(void) share {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        UIGraphicsBeginImageContext(self.view.window.frame.size);
        [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSArray *activityItems = [NSArray arrayWithObjects:NSLocalizedString(@"sharetitle", nil), iTunesLink,viewImage, nil];
        UIActivityViewController *activityVC = [[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil]autorelease];;
        [self presentViewController:activityVC animated:YES completion:nil];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"savetophoto",@"savetophoto"),NSLocalizedString(@"cancel",@"cancel"), nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet autorelease];
    }
    
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIGraphicsBeginImageContext(self.view.window.frame.size);
        [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(viewImage,  self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
    } else{
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    
}

- (void)errorAlert:(NSString *) message {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil message:message delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"ok",@"ok") otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (error != NULL){
        [self errorAlert:[error localizedDescription]];
    } else {
        [self errorAlert:NSLocalizedString(@"savedone",@"savedone")];
    }
}
@end
