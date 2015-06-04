//
//  BaseTable.m
//  diablo3guide
//
//  Created by zhang yang on 11-8-22.
//  Copyright 2011年 ibm. All rights reserved.
//

#import "BaseTable.h"

@implementation UINavigationBar (UINavigationBarCategory)
- (void)drawRect:(CGRect)rect {    
    UIImage *navBarImage = [UIImage imageNamed:@"navi.png"];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);       
    
    CGPoint center=self.center;
    
    CGImageRef cgImage= CGImageCreateWithImageInRect(navBarImage.CGImage, CGRectMake(0, 0, 1, 44));
    CGContextDrawImage(context, CGRectMake(center.x-160-80, 0, 80, self.frame.size.height), cgImage);
    CGContextDrawImage(context, CGRectMake(center.x-160, 0, 320, self.frame.size.height), navBarImage.CGImage);
    CGContextDrawImage(context, CGRectMake(center.x+160, 0, 80, self.frame.size.height), cgImage);
    CGImageRelease(cgImage);
}
@end





@implementation UIViewController (backButton)
- (void)backButton {
    UIButton *BackBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 62.0, 40.0)];
    [BackBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [BackBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *BackBarBtn = [[UIBarButtonItem alloc] initWithCustomView:BackBtn];
    self.navigationItem.leftBarButtonItem = BackBarBtn;	
    [BackBtn release];
    [BackBarBtn release];
}

- (void)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIBarButtonItem *)shareButton {
    UIButton *BackBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 62.0, 40.0)]autorelease];
    [BackBtn setImage:[UIImage imageNamed:@"openin.png"] forState:UIControlStateNormal];
    [BackBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *BackBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:BackBtn]autorelease];
    return BackBarBtn;
}
-(void) share {
    UIGraphicsBeginImageContext(self.view.window.frame.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSArray *activityItems = [NSArray arrayWithObjects:NSLocalizedString(@"sharetitle", nil), iTunesLink,viewImage, nil];
    UIActivityViewController *activityVC = [[[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil]autorelease];;
    [self presentViewController:activityVC animated:YES completion:nil];
}
@end
