//
//  XANThumbsViewController.m
//  XANPhotoBrowser
//
//  Created by Chen Xian'an on 12/17/10.
//  Copyright 2010 lazyapps.com. All rights reserved.
//

#import "XANThumbsViewController.h"
#import "config.h"

#define ROW_HEIGHT (kThumbSize.height + kSpacing)
#define kStatusBarHeight 20

@interface XANThumbsViewController()
- (void)updateTableLayout;
- (NSUInteger)numberOfThumbsForRow:(NSUInteger)row;
@end

@implementation XANThumbsViewController
@synthesize showsDoneButton,category;
@synthesize dataSource, delegate;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithImagePaths:(NSArray *)_imagePath category:(NSString *)_category
{
    if (self = [super initWithStyle:UITableViewStylePlain]){
        self.dataSource = self;
        self.delegate = self;
        self.wantsFullScreenLayout = YES;
        
        fromStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        self.category = _category;
        imagePaths = _imagePath;
        [imagePaths retain];

        
//        NSString *appDocDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] relativePath];
//        [imagePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//            
//            UIImage *image = [[UIImage alloc] initWithContentsOfFile:obj];
//            CGSize size = kThumbSize;
//            
//            if (image.size.width > image.size.height)
//                size.width = size.height * (image.size.width/image.size.height);
//            else 
//                size.height = size.width * (image.size.height/image.size.width);
//            
//            CGRect rect = CGRectZero;
//            rect.origin = CGPointZero;
//            rect.size = size;
//            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//            [image drawInRect:rect];
//            UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            NSString *filename = [[obj lastPathComponent ]stringByDeletingPathExtension];
//            NSString *device = isIPad?@"ipad":@"iphone";
//
//            NSString *path = [NSString stringWithFormat:@"%@/%@%@%@.PNG", appDocDir,device,self.category,filename ];
//            
//           [UIImagePNGRepresentation(thumbImage) writeToFile:path atomically:YES];
//            
//            [image release];
//        }];
    }
    
    return self;
}


- (void)reloadData
{
  numberOfThumbs = [dataSource numberOfThumbs];
  numberOfColumns = [dataSource numberOfColumnsForPortrait];
  
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
      [dataSource respondsToSelector:@selector(numberOfColumnsForLandscape)])
     numberOfColumns = [dataSource numberOfColumnsForLandscape];                
  
  numberOfRows = numberOfThumbs / numberOfColumns;
 
 if (numberOfThumbs % numberOfColumns)
   numberOfRows += 1;
 
 [self.tableView reloadData];
}

- (NSUInteger)thumbIndexForColumn:(NSUInteger)column
                            inRow:(NSUInteger)row
{
  return numberOfColumns*row + column;
}

- (void)loadView
{
  [super loadView];

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.rowHeight = ROW_HEIGHT;

  if (self.title) self.navigationItem.title = self.title;
  self.navigationController.navigationBar.barStyle
    = self.navigationController.toolbar.barStyle
    = UIBarStyleBlack;
  self.navigationController.navigationBar.translucent
    = self.navigationController.toolbar.translucent
    = YES;
    
//    [self backButton];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introbg.png"]];
    [[self tableView] setBackgroundView:background];
    [background autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:YES];
  self.navigationController.toolbarHidden = YES;
  
  if (!ISPAD)
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
  
  [self updateTableLayout];
  [self reloadData];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration {
  [self updateTableLayout];
  [self reloadData];
}

- (void)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return numberOfRows;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  XANThumbsCell *cell = (XANThumbsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[XANThumbsCell alloc] initWithReuseIdentifier:CellIdentifier thumbDelegate:self] autorelease];
  }
  
  cell.capacityOfThumbs = numberOfColumns;
  cell.numberOfThumbs = [self numberOfThumbsForRow:indexPath.row];
  cell.rowIndex = indexPath.row;

//    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
  for (int i=0; i<cell.numberOfThumbs; i++){
//    dispatch_async(aQueue, ^{
        NSUInteger realIndex = [self thumbIndexForColumn:i inRow:cell.rowIndex];
        UIImage *img = [dataSource thumbImageForIndex:realIndex];
//        dispatch_async(dispatch_get_main_queue(),^{
            [cell updateImage:img forColumn:i];
//        });
//    });
  }
  
  return cell;
}

#pragma mark Table view delegate

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
  // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
  // For example: self.myOutlet = nil;
}


- (void)dealloc {
    CLogc;
    
    [category release];
    [imagePaths release];
  self.dataSource = nil;
  self.delegate = nil;
  
  [super dealloc];
}

#pragma mark privates

- (void)updateTableLayout
{
  CGFloat barsHeight = 0;
  if (self.wantsFullScreenLayout && self.navigationController.modalPresentationStyle == UIModalPresentationFullScreen) barsHeight += kStatusBarHeight;
  if (self.navigationController.navigationBar.translucent) barsHeight += self.navigationController.navigationBar.bounds.size.height;
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
  barsHeight += kSpacing;
  self.tableView.contentInset = UIEdgeInsetsMake(barsHeight, 0, 0, 0);
}

- (NSUInteger)numberOfThumbsForRow:(NSUInteger)row
{  
  if (row == numberOfRows-1){
    NSUInteger remainder = numberOfThumbs % numberOfColumns;
    
    return remainder == 0 ? numberOfColumns : remainder;
  }

  return numberOfColumns;
}

- (void)done
{
  [self.navigationController dismissModalViewControllerAnimated:YES];
  [UIApplication sharedApplication].statusBarStyle = fromStatusBarStyle;
  if ([delegate respondsToSelector:@selector(doneWithThumbsViewController:)])
    [delegate doneWithThumbsViewController:self];
}

#pragma mark XANThumbsCellDelegate
- (void)cell:(XANThumbsCell *)cell
didSelectThumbAtColumn:(NSUInteger)column
       inRow:(NSUInteger)rowIndex {
    if ([delegate respondsToSelector:@selector(thumbsViewController:didSelectThumbAtIndex:)]){
        NSUInteger realIndex = cell.capacityOfThumbs * rowIndex + column;
        [delegate thumbsViewController:self
                 didSelectThumbAtIndex:realIndex];
    }
}

#pragma mark - 
#pragma mark XANThumbsViewControllerDataSource
- (UIImage *)thumbImageForIndex:(NSUInteger)index {
    
    NSString *filename = [[[imagePaths objectAtIndex:index] lastPathComponent ]stringByDeletingPathExtension];
    NSString *device = isIPad?@"ipad":@"iphone"; 
    NSString *name = [NSString stringWithFormat:@"thumbs/%@%@%@",device,self.category,filename ];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"PNG"];
    UIImage *image = [[[UIImage alloc] initWithContentsOfFile:imagePath]autorelease];
    
    return image;
}

- (NSUInteger)numberOfThumbs {
    return [imagePaths count];
}

- (NSUInteger)numberOfColumnsForPortrait
{
    return kCapacityOfThumbsInARowPortrait;
}

- (NSUInteger)numberOfColumnsForLandscape
{
    return kCapacityOfThumbsInARowLandscape;
}

#pragma mark -
#pragma mark XANThumbsViewControllerDelegate
- (void)thumbsViewController:(XANThumbsViewController *)thumbsViewController
       didSelectThumbAtIndex:(NSUInteger)index {
    
    XANImageViewController *ivc = [[XANImageViewController alloc] initWithInitialImageIndex:index dataSource:self delegate:nil];
    
    [self.navigationController pushViewController:ivc animated:YES];

    [ivc release];
}

#pragma mark -
#pragma mark XANImageViewControllerDataSource
- (NSUInteger)numberOfImages
{
    return [imagePaths count];
}

- (UIImage *)imageForIndex:(NSUInteger)index
{
    return [UIImage imageWithContentsOfFile:[imagePaths objectAtIndex:index]];
}
- (NSString *)pathForIndex:(NSUInteger)index{
    return [imagePaths objectAtIndex:index];
}
- (NSString *)titleForIndex:(NSUInteger)index{
    return [[imagePaths objectAtIndex:index]lastPathComponent];
}

@end

