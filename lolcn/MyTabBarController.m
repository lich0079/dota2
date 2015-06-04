//
//  MyTabBarController.m
//  lol
//
//  Created by lich0079 on 12-9-21.
//
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    CLogc;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations{
//    CLogc;
    return UIInterfaceOrientationMaskPortrait;
}


@end
