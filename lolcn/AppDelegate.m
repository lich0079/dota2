//
//  AppDelegate.m
//  lolcn
//
//  Created by Frank Zhang on 11-12-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "WebVC.h"
#import "MainScreenVC.h"
#import "XANThumbsViewController.h"
#import "BlogVC.h"
#import "UpdateVC.h"
#import "iRate.h"


void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"Uncaught" message:@"Crash!" exception:exception];
}


@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc {
    CLogc;
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

+ (void)initialize
{
    CLogc;
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].appStoreID = 623373024;
#ifdef FREE_VERSION
    [iRate sharedInstance].appStoreID = 652150073;
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UINavigationController *news = [[[UINavigationController alloc] initWithRootViewController:
                              [[[BlogVC alloc]init] autorelease]]autorelease];
    news.title = NSLocalizedString(@"News", nil);
    news.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    
    
    UINavigationController *updates = [[[UINavigationController alloc] initWithRootViewController:
                                     [[[UpdateVC alloc]init] autorelease]]autorelease];
    updates.title = NSLocalizedString(@"Updates", nil);
    updates.tabBarItem.image = [UIImage imageNamed:@"new.png"];
    
    WebVC *champions = [[[WebVC alloc] init] autorelease];
    champions.title = NSLocalizedString(@"Heroes", nil);
    champions.htmlName = @"Heroes";
    champions.tabBarItem.image = [UIImage imageNamed:@"tabbar_profile.png"];
    
    WebVC *items = [[[WebVC alloc] init] autorelease];
    items.title = NSLocalizedString(@"Items", nil);
    items.htmlName = @"Items";
    items.tabBarItem.image = [UIImage imageNamed:@"tabbar_items.png"];
    
    
    XANThumbsViewController *tvc = [[XANThumbsViewController alloc] initWithImagePaths:[[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"blouses"]category:@"blouses"];
    tvc.title = NSLocalizedString(@"Gallery",nil);
    UINavigationController *photos = [[[UINavigationController alloc] initWithRootViewController:
                                      tvc]autorelease];
    photos.title = NSLocalizedString(@"Gallery", nil);
    photos.tabBarItem.image = [UIImage imageNamed:@"photos.png"];
    [tvc release];
    
    
    self.tabBarController = [[[MyTabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects: news, updates, champions, items, photos, nil];

    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
#ifndef DEBUG
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAnalytics setAppVersion:@"1.70"];
    [FlurryAnalytics startSession:@"42X2M9RKFH6RP6VF7SVW"];
    [FlurryAnalytics logAllPageViews:self.tabBarController];
#endif
    return YES;
}



@end
