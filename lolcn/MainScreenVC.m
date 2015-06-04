//
//  MainScreenVC.m
//  diablo3guide
//
//  Created by zhang yang on 11-11-22.
//  Copyright (c) 2011年 ibm. All rights reserved.
//

#import "MainScreenVC.h"
#import "WebVC.h"
#import "XANThumbsViewController.h"
#import "MBProgressHUD.h"

@implementation MainScreenVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent
    = self.navigationController.toolbar.translucent
    = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *help = [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *BackBarBtn = [[UIBarButtonItem alloc] initWithCustomView:help];
    [help addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = BackBarBtn;
    [BackBarBtn release];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"version1.0helpchecked"]){
        [self help:nil];
        [defaults setValue:@"YES" forKey:@"version1.0helpchecked"];
        [defaults synchronize];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        CLog(@"ios5");
        if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
            //        CLog(@"111");
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }else {
        CLog(@"ios4");

    }
    
}

-(void) help:(id)sender {
    [FlurryAnalytics logEvent:a_help];
    WebVC *Combat = [[WebVC alloc]init];
    Combat.htmlName = @"Help";
    [self.navigationController pushViewController:Combat animated:YES];
    [Combat release];
}

- (IBAction)basicClick:(id)sender {
    WebVC *basic = [[WebVC alloc]init];
    basic.htmlName = @"Intro1";
    [self.navigationController pushViewController:basic animated:YES];
    [basic release];
}

- (IBAction)classesClick:(id)sender {
    NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Trailer.m4v" ofType:nil];
    NSURL *videoURL =  [NSURL fileURLWithPath:defaultStorePath];
    
    MPMoviePlayerViewController *moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    moviePlayer.moviePlayer.useApplicationAudioSession = NO;
    moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    moviePlayer.moviePlayer.scalingMode=MPMovieScalingModeAspectFit;
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    [moviePlayer release]; 

}

- (IBAction)followersClick:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        sleep(1);
		dispatch_async(dispatch_get_main_queue(), ^{
            
            XANThumbsViewController *tvc = [[XANThumbsViewController alloc] initWithImagePaths:[[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"blouses"]category:@"blouses"];
            tvc.title = NSLocalizedString(@"Gallery",nil);
            [self.navigationController pushViewController:tvc animated:YES];
            [tvc release];
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        });
	});
}

- (IBAction)spellsClick:(id)sender {
    WebVC *basic = [[WebVC alloc]init];
    basic.htmlName = @"Spells";
    [self.navigationController pushViewController:basic animated:YES];
    [basic release];
    
}


- (void)dealloc {

    [super dealloc];
}
- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
