//
//  BlogVC.h
//  dota2
//
//  Created by lich0079 on 12-10-30.
//
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"


@interface UpdateVC : UITableViewController  <EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource> {
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}


@property (retain , nonatomic) NSMutableArray *posts;

@end
