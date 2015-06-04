//
//  WebVC.h
//  diablo3guide
//
//  Created by zhang yang on 11-12-5.
//  Copyright (c) 2011年 ibm. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef FREE_VERSION
#import "GADBannerView.h"
#endif

@interface WebVC : UIViewController<UIWebViewDelegate,UIActionSheetDelegate
#ifdef FREE_VERSION
,GADBannerViewDelegate
#endif
>{
    BOOL hasAddWeb;
    
}

@property (assign , nonatomic) NSString *htmlName;
@property (retain, nonatomic) IBOutlet UIWebView *web;

@property (assign , nonatomic) BOOL isRemote;

#ifdef FREE_VERSION
@property (retain, nonatomic)  GADBannerView *admobView;
#endif
@end
