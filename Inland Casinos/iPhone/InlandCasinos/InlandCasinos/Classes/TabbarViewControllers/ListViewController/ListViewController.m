//
//  ListViewController.m
//  PE
//
//  Created by Nithin George on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListViewController.h"
#import "ListCell.h"
#import "List.h"
#import "DBHandler.h"
#import "XMLParser.h"
#import "DetailViewController.h"
#import "DownloadManager.h"
#import "SettingViewController.h"


@implementation ListViewController

@synthesize homeSelectionID;
@synthesize selectedButtonID;

@synthesize selectedCasinosName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableData = [[NSMutableArray alloc]init];
    [self createCustomNavigationLeftButton];
    selectedIndex = self.tabBarController.selectedIndex;
    //selectedAminityName = [[DBHandler sharedManager] readSubItemName:selectedButtonID];   
    
    [[NSNotificationCenter defaultCenter]addObserver:self 
                                            selector:@selector(refreshView:)
                                                name:kReloadNotification 
                                              object:nil];
    
    
}

- (void)addNoSearchResultLabel {
    
    emptySearchResult = [[UILabel alloc] initWithFrame:CGRectMake(100, 150, 150, 20)];
    emptySearchResult.text = @"No Result Found";
    [emptySearchResult setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
	[emptySearchResult setBackgroundColor:[UIColor clearColor]];
	[emptySearchResult setTextColor:[UIColor grayColor]];
    [self.view addSubview:emptySearchResult];
    [emptySearchResult release];
}

-(void)startSync {
    
        [[DownloadManager sharedManager] setIdentifier:selectedButtonID];
        [[DownloadManager sharedManager] startContentSyncing:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    
    //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationPortrait];
    //selectedIndex = self.tabBarController.selectedIndex;
    [self getSearchBArDisplayText];
    [self addNoSearchResultLabel];
    [self showTabBarView];
    [self addSearchBar];
    [self loadDisplayContentArray];


}

- (void)getSearchBArDisplayText
{
    //list for favorites
    selectedAminityName = @"";
    switch (selectedIndex)
    {
        case 1:
             selectedAminityName = @"Dining";
            break;
        case 2:
            selectedAminityName = @"Events";
            break;
        case 4:
                selectedAminityName = TEXT_FAVORITES; 
            break;
        default:
            selectedAminityName = [[DBHandler sharedManager] readSubItemName:selectedButtonID]; 
            break;
    }
    
}


-(void)playAdmob{
    
    bannerView_ = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0,
                                            320,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];//320
    bannerView_.adUnitID = @"a14e4502603c2f3";
    bannerView_.rootViewController = self;
    bannerView_.delegate = self;
    //bannerView_.backgroundColor = [UIColor redColor];
    // Initiate a generic request to load it with an ad.
     [bannerView_ loadRequest:[GADRequest request]];
    [self.view addSubview:bannerView_];
    [bannerView_ release];
}

#pragma mark- GADBannerView Delegates

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    listView.frame = CGRectMake(0, 0, 320, 318);
}
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    
}
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
        listView .frame = CGRectMake(0, 0, 320, 367);
}
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
        listView.frame = CGRectMake(0, 0, 320, 367);
}

#pragma mark -

- (void)addSearchBar {
    
    //search bar
    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,320,40)];
    searchBar.delegate = self;
    searchBar.placeholder = [NSString stringWithFormat:@"Search %@",selectedAminityName];
    //table view
    listView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 367)];
    listView.delegate = self;
    listView.dataSource = self;
    listView.tableHeaderView = searchBar;
    listView.autoresizesSubviews=NO;
    listView.autoresizingMask=UIViewAutoresizingNone;
//    [self.tabBarController.tabBar setTransform:CGAffineTransformMakeRotation(degreesToRadian(90))];
    
    [self.view addSubview:listView];
    [searchBar release];
    [listView release];
}

- (void)loadDisplayContentArray {
    
    //list view
    if (selectedIndex == 1) {
        
        selectedAminityName =  TABBAR_DINING;
        listItems = [[[DBHandler sharedManager]readTabBarlistItems:TABBAR_DINING] retain];
    }
    //from tab bar
    else if (selectedIndex == 2) {
        
        selectedAminityName =  TABBAR_EVENTS;
        listItems = [[[DBHandler sharedManager]readTabBarlistItems:TABBAR_EVENTS] retain];
    }
    //from favorite(through more)
    else if (selectedIndex == 4) {
        
        selectedAminityName =  TABBAR_FAVORITES;
        listItems = [[[DBHandler sharedManager]getFavoriteListItems] retain];
    }
    
    else {
        
        [self startSync];
        listItems = [[[DBHandler sharedManager]readlistItems:selectedButtonID] retain];
    }
    
    self.navigationItem.title =selectedAminityName;
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:listItems];

    if (0 == [tableData count] && selectedIndex == 4) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:@"No Favorite list"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        alert.delegate = self;
        [alert show];
        [alert release];

    }
    else
    {
        if (listView)
        {   
            [listView reloadData];
            [self playAdmob];
        } 
    }
}

#pragma mark AlertView Delegated
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        
        [[self navigationController] popViewControllerAnimated:YES];
    }
}



- (void)showTabBarView {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    for (UIView *view in self.tabBarController.view.subviews) {
        if (view.tag==TABBAR_TAG) {
            view.hidden=NO;
        }
    }
    [UIView commitAnimations];
}


- (void)createCustomNavigationLeftButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 25);
    [button setBackgroundImage:[UIImage imageNamed:SETTING_IMAGE] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(iconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
    item = nil;
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)tableSearchBar {
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)tableSearchBar {
    
    searchBar.showsCancelButton = NO;
    
}

- (void)searchBar:(UISearchBar *)tableSearchBar textDidChange:(NSString *)searchText {
    
    
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if([searchText isEqualToString:@""] || searchText==nil){
        
        [self.view bringSubviewToFront:listView];
        [tableData removeAllObjects];
        [tableData addObjectsFromArray:listItems];
        searchBar.showsCancelButton = NO;
        if (listView) {
            [listView reloadData];
        }
        return;
    }
    
    [tableData removeAllObjects];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@",searchText];

        
        NSArray *beginWithCharacter = [listItems filteredArrayUsingPredicate:predicate];
        
        if ([beginWithCharacter count]>0) {
            
        [tableData addObjectsFromArray:beginWithCharacter];
        }

    if ([tableData count] == 0) {
        
        [self.view bringSubviewToFront:emptySearchResult];
    }
    else {

        [self.view sendSubviewToBack:emptySearchResult];
    }

    if (listView) {
        [listView reloadData];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)tableSearchBar {
    
    //listView .frame = CGRectMake(0, 0, 320, 430);
    searchBar.text =@"";
    [tableData removeAllObjects];
    [tableData addObjectsFromArray:listItems];
    
    @try{
        
        if (listView) {
            [listView reloadData];
        }
        
    }
    
    @catch(NSException *e){
        
    }
    
    [searchBar resignFirstResponder];
    
}

//keyboard button
- (void)searchBarSearchButtonClicked:(UISearchBar *)tableSearchBar{
    
    [searchBar resignFirstResponder];
    
}



#pragma mark -
#pragma mark Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath	{

	return 62;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    if ([tableData count]%LISTVIEW_COL_COUNT==0) {
        
        return ([tableData count]/LISTVIEW_COL_COUNT);
    }
    
    else {
        
        return ([tableData count]/LISTVIEW_COL_COUNT)+1;
    }
  
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"Cell";
    ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[[ListCell alloc] init] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
   // if ([tableData count] > 0) {
       
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
        [cell displayCellItems:[self readListViewItems:indexPath.row*LISTVIEW_COL_COUNT]];//:homeSelectionID:selectedIndex];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    //}
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    //if ([tableData count] > 0) {
        
        [searchBar resignFirstResponder];
        //manual downloading
        [self manualDownload:indexPath.row];
        //detail display
        DetailViewController *detailViewController=[[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
        [detailViewController setHidesBottomBarWhenPushed:YES];
        detailViewController.aminityName    = self.navigationItem.title;
        detailViewController.listItems      = tableData;
        detailViewController.selectedListID = indexPath.row;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
        detailViewController=nil;
   // }
 
}

//for manual downloading
- (void)manualDownload:(int)index {
    
    List *list = [tableData objectAtIndex:index];
    NSMutableArray *image = [[DBHandler sharedManager]getImagePathForManualDownload:list.idlist];
    
    for(Image *img in image) {
        
        NSMutableArray *imageDetail =  [[DBHandler sharedManager] readImageDetails:img.idList];//its parentidmenu and idmenu 
        [[DownloadManager sharedManager] startImageDownloading:img items:imageDetail];
    }
    [[DownloadManager sharedManager]executeNetworkQueue];
    [[DownloadManager sharedManager]automaticImageDownloading];
}

#pragma mark -
#pragma mark List Section Items

- (NSMutableArray *)readListViewItems:(int)index {
    
    NSMutableArray *secions=[[[NSMutableArray alloc]init] autorelease];
    [secions addObject:[tableData  objectAtIndex:index]];
     return secions;
}

#pragma Download Manager Notification

-(void)refreshView:(NSNotification *)notification{
    
    NSString * a=[notification object];
    DebugLog(@"Path=%@",a);
  /*  if (listView) 
    {
        [self loadDisplayContentArray];
        [listView reloadData];
        
    }*/
    
}

#pragma mark Scrolling Overrides
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
     [searchBar resignFirstResponder];  
     [self.navigationController setNavigationBarHidden:NO animated:YES];
     bannerView_ .frame = CGRectMake(0.0,
                                    320,
                                    GAD_SIZE_320x50.width,
                                    GAD_SIZE_320x50.height);
}

#pragma mark -
#pragma mark Button Clicked

- (void)iconButtonClicked:(id)sender {
 
    SettingViewController *settingViewController=[[SettingViewController alloc]initWithNibName:SETTINGVIEWCONTROLLER_NIB_NAME bundle:nil];
    UINavigationController *settingNavigationController=[[UINavigationController alloc]initWithRootViewController:settingViewController];
    [self.navigationController presentModalViewController:settingNavigationController animated:YES];
    [settingViewController release];
    settingViewController=nil;
    [settingNavigationController release];
    settingNavigationController = nil;
}


#pragma mark - Orientations methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return YES;
       //return NO;
    return (interfaceOrientation==UIInterfaceOrientationPortrait);
    
}

#pragma mark - Memory Relese methods

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
  if(listItems)   {
        [listItems release];
        listItems = nil;
    }
    
    
    if (tableData) {
     
        [tableData release];
        tableData = nil;
        
    }

    
    self.selectedCasinosName = nil;
    
    if (bannerView_.delegate)
    {
        bannerView_.delegate = nil;
    }

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
