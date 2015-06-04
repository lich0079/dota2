//
//  BlogVC.m
//  dota2
//
//  Created by lich0079 on 12-10-30.
//
//

#import "BlogVC.h"
#import "ASIHTTPRequest.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "Post.h"
#import "MBProgressHUD.h"
#import "WebVC.h"

@interface BlogVC ()

@end

@implementation BlogVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _posts = [[NSMutableArray alloc]init];
    
    //change navi pic
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        CLog(@"ios5");
        if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
            //        CLog(@"111");
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi.png"] forBarMetrics:UIBarMetricsDefault];
        }
    }else {
        CLog(@"ios4");
    }
    
    //change backgound pic
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [[self tableView] setBackgroundView:background];
    [background autorelease];
    
    self.tableView.rowHeight = 64;
    
    //refresh
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
    
    //help button
    UIButton *help = [UIButton buttonWithType:UIButtonTypeInfoLight];
    UIBarButtonItem *helpBtn = [[UIBarButtonItem alloc] initWithCustomView:help];
    [help addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = helpBtn;
    [helpBtn release];
    _reloading = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        self.navigationItem.leftBarButtonItem = [self shareButton];
    }else {
    }
    
    [self loadPosts];
}

-(void) help:(id)sender {
    [FlurryAnalytics logEvent:a_help];
    WebVC *Combat = [[WebVC alloc]init];
#ifdef FREE_VERSION
    Combat.htmlName = @"Helpf";
#else
    Combat.htmlName = @"Help";
#endif
    [self.navigationController pushViewController:Combat animated:YES];
    [Combat release];
}

-(void) loadPosts{
    NSURL *url = [NSURL URLWithString:NSLocalizedString(@"newsurl",nil)];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    __block NSMutableArray *tmpPosts = _posts;
    __block UITableView *tmpTableView  = self.tableView;
    __block UIView *tmpView = self.view;
    [request setCompletionBlock:^{
        
        [tmpPosts removeAllObjects];
        
        NSData *responseData = [request responseData];
        XMLDocument *xmlDoc = [[XMLDocument alloc] initWithHTMLData:responseData];
        NSArray *titles = [xmlDoc elementsMatchingPath:@"//body/div/div/div/div[5]/div/h2[@class='entry-title']/a"];
        NSArray *times = [xmlDoc elementsMatchingPath:@"//body/div/div/div/div[5]/div/div[@class='entry-meta']"];
        for (int i=0; i< [titles count]; i++) {
            Post *p = [[Post alloc]init];
            XMLElement *title = titles[i];
            p.title = [title content];
            p.link = [title attributeWithName:@"href"];
            XMLElement *time = times[i];
            p.time = [[time content]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [tmpPosts addObject:p];
            [p release];
            
        }
        [xmlDoc release];
        
        [tmpTableView reloadData];
        
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        
        [MBProgressHUD hideHUDForView:tmpView animated:YES];
        
    }];
    [request setFailedBlock:^{
        
        _reloading = NO;
        [MBProgressHUD hideHUDForView:tmpView animated:YES];

        NSError *error = [request error];
        UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil message:[error localizedDescription] delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"ok",@"OK") otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }];
    [request startAsynchronous];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES label:NSLocalizedString(@"Loading...",nil) details:NSLocalizedString(@"updating news",nil)];
    _reloading = YES;
 
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    Post *p = _posts[indexPath.row];
    cell.textLabel.text = p.title;
    cell.detailTextLabel.text = p.time;
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebVC *webView = [[WebVC alloc]init];
    Post *p = _posts[indexPath.row];
    webView.htmlName = p.link;
    webView.isRemote = YES;
    [self.navigationController pushViewController:webView animated:YES];
    [webView release];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CLogc;
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    CLogc;
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
//    CLogc;
	[self loadPosts];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
//	CLogc;
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (void)dealloc {
    CLogc;
    _posts = nil;
    [_posts release];
    [super dealloc];
}
@end
