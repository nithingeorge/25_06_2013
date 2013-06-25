//
//  ArrayViewController.m
//  GreenVolts
//
//  Created by YML on 8/27/11.
//  Copyright 2011 YML. All rights reserved.
//

#import "ArrayViewController.h"
#import "TopTileView.h"
#import "StringViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "String.h"
#import "EntityDetails.h"
#import "Inverter.h"
#import "LoginManager.h"
#import "SBJson.h"
#import "DateTimeConverter.h"
#import "SliderManager.h"
#import "GreenVoltsAppDelegate.h"

@interface ArrayViewController(PVT)<AllTilesListViewDelegate,TotalEnergyViewDelegate,CameraViewDelegate,InverterViewDelegate,LoginManagerDelegate,ConnectionDelegate,WindScrollViewDelegate,TrackerViewDelegate>
-(void)loadNextView;
-(void)loadPreviousView;
-(void)ClickedTileWithIndex:(int)index;
-(void)foundSwipeLeft;
-(void)foundSwipeRight;
-(void)addTopTileView;
-(void)jsonParser_ParseStringList:(NSData*)responseData;
-(void)jsonParser_parseArrayDetails:(NSData*)responseData;
-(void)jsonParser_parseToatlEnergy:(NSData*)responseData;
-(void)jsonParser_parseTopViewData:(NSData*)responseData;
-(void)handleSlider:(id)sender;
- (void)updateSlider;
- (void)updateGraphValuesFromServer;
-(BOOL)isViewPresent:(UIView*)view inSuperView:(UIView*)superView;
@end


@implementation ArrayViewController
-(id)initWithArray:(Array *)pArray
{
  if((self = [super init]))
  {
    isGoingToNextLevel=NO;
    m_Array=pArray;
    
    m_TopTileView=nil;
    m_AllTilesListView=nil;
    m_PowerVsDNIView=nil;
    m_TotalEnergyView=nil;
    m_WindView=nil;
    m_CameraScrollView=nil;
    m_TrackerView=nil;
    m_InverterView=nil;   
    m_TitleLabel=nil;
    
    m_Slider=nil;
    m_InverterImageView=nil;
    m_InverterListViewDCWest=nil;
    m_InverterListViewDCEast=nil;
    m_InverterListViewAC=nil;
    
    m_BackgroundImageView=nil;
    
    mConnection=[[Connection alloc]init];
    
    m_ActivityIndicatorView=nil;   
    
    isDateChanged = NO;
    
    m_webserviceProcessor = nil;
    m_parseStringListURL = nil;
    m_parseArrayDetailsURL = nil;
    m_parseTotalEnergyURL = nil;
    m_parseTopViewDataURL = nil;
    
    m_bTapped = NO;
    
    //printf("\nArrayVC init with Array:\n%s\n",[[pArray description]UTF8String]);
    [[NSUserDefaults standardUserDefaults]setObject:m_Array.m_ArrayId forKey:@"ID"];
    [[NSUserDefaults standardUserDefaults]setObject:@"4" forKey:@"ENTITY_TYPE"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloaddata) name:@"RELOAD_DATA" object:nil];
    lastSelectedDay=-1;
    
    isServerConnectionActive=NO;
  }
  return self;
}

- (void)dealloc 
{
  if(mConnection){mConnection.m_delegate=nil;mConnection=nil;}
  
  if(m_webserviceProcessor)
  {
    [m_webserviceProcessor cancel];
    m_webserviceProcessor = nil;
  }
  
  if(m_parseStringListURL)
  {
    m_parseStringListURL = nil;
  }
  if(m_parseArrayDetailsURL)
  {
    m_parseArrayDetailsURL = nil;
  }
  if(m_parseTotalEnergyURL)
  {
    m_parseTotalEnergyURL = nil;
  }
  if(m_parseTopViewDataURL)
  {
    m_parseTopViewDataURL = nil;
  }
  
  if(m_ActivityIndicatorView){m_ActivityIndicatorView=nil;}  
  if(m_Array){m_Array=nil;}
  
  if(m_TopTileView){m_TopTileView=nil;}
  if(m_AllTilesListView){m_AllTilesListView.m_deleagte=nil;m_AllTilesListView=nil;}
  if(m_PowerVsDNIView){m_PowerVsDNIView=nil;}
  if(m_TotalEnergyView){m_TotalEnergyView.m_delegate=nil;m_TotalEnergyView=nil;}
  if(m_WindView){m_WindView.m_delegate=nil;m_WindView=nil;}
  if(m_CameraScrollView)
  {
    m_CameraScrollView.m_CameraView.m_deleagte=nil;
    m_CameraScrollView=nil;
  }
  if(m_TrackerView){m_TrackerView.m_delegate=nil;m_TrackerView=nil;}
  if(m_InverterView){m_InverterView.m_delegate=nil;m_InverterView=nil;}

  if(m_InverterListViewDCWest){m_InverterListViewDCWest=nil;}
  if(m_InverterListViewDCEast){m_InverterListViewDCEast=nil;}
  if(m_InverterListViewAC){m_InverterListViewAC=nil;}
  if(m_InverterImageView){m_InverterImageView=nil;}
  
  if(m_Slider){m_Slider=nil;}
  if(m_TitleLabel){m_TitleLabel=nil;}
  if(m_BackgroundImageView){m_BackgroundImageView=nil;}
  
  if(m_Backbutton){[m_Backbutton removeFromSuperview];}
  
}


-(void)loadView
{
  self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
  self.view.backgroundColor=[UIColor colorWithRed:(10.2/100.0) green:(13.3/100.0) blue:(13.7/100.0) alpha:1.0];
  
  if([self.navigationController.viewControllers objectAtIndex:0]!=self)
  {
    m_Backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    m_Backbutton.frame=CGRectMake(5, 8, 72, 30);
    [m_Backbutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[[NSUserDefaults standardUserDefaults]objectForKey:@"BACK_BUTTON"] ofType:@"png"]] forState:UIControlStateNormal];
    [m_Backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
  }
  
  [self addTopTileView];
  
  [self.navigationItem setHidesBackButton:YES animated:NO];
  
  m_InverterImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 96)];
  m_InverterImageView.image=[UIImage imageNamed:@"InverterTopList.png"];
  [self.view addSubview:m_InverterImageView];
  m_InverterImageView.hidden=YES;
  
  m_InverterListViewDCWest=[[InverterListView alloc]initWithFrame:CGRectMake(160, 22, 50, 60)];
  [m_InverterListViewDCWest showDCLabels];
  [self.view addSubview:m_InverterListViewDCWest];
  m_InverterListViewDCWest.hidden=YES;
  
  m_InverterListViewDCEast=[[InverterListView alloc]initWithFrame:CGRectMake(260, 22, 50, 60)];
  [m_InverterListViewDCEast showDCLabels];
  [self.view addSubview:m_InverterListViewDCEast];
  m_InverterListViewDCEast.hidden=YES;
  
  m_InverterListViewAC=[[InverterListView alloc]initWithFrame:CGRectMake(60, 22, 50, 70)];
  [m_InverterListViewAC showACLabels];
  [self.view addSubview:m_InverterListViewAC];
  m_InverterListViewAC.hidden=YES;
  
  m_BackgroundImageView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 110, 304, 247)];
  m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBG.png"];
  [self.view addSubview:m_BackgroundImageView];
    
  
  m_AllTilesListView=[[AllTilesListView alloc]initWithFrame:CGRectMake(0, 0,304, 250)];
  m_AllTilesListView.m_deleagte=self;
  
  m_PowerVsDNIView=[[PowerVsDNIScrollView alloc]initWithFrame:CGRectMake(2,2,298,250)];
  
  m_TotalEnergyView=[[TotalEnergyView alloc]initWithFrame:CGRectMake(0,0,304,250)];
  
  m_WindView=[[WindScrollView alloc]initWithFrame:CGRectMake(2,2,298,250)];
  m_WindView.m_delegate=self;
  
  m_TrackerView=[[TrackerView alloc]initWithFrame:CGRectMake(0, 0,304, 247)];
  m_TrackerView.m_delegate=self;
  
  m_InverterView=[[InverterView alloc]initWithFrame:CGRectMake(0, 0,304, 247)];
  m_InverterView.m_delegate=self;
  
  mPagingView=[[PagingView alloc]initWithFrame:CGRectMake(8,110,304,255)];
  mPagingView.delegate=self;
  mPagingView.dataSource=self;
  mPagingView.isEnabled=NO;
  [self.view addSubview:mPagingView];
    
  m_CameraScrollView=[[CameraScrollView alloc]initWithFrame:CGRectMake(0, 0,304, 250) CameraID:m_Array.CameraID PagingView:mPagingView canScrollRight:YES];
  m_CameraScrollView.m_CameraView.m_deleagte=self;
    
  UIImageView *pTitleImageView=[[UIImageView alloc]initWithFrame:CGRectMake(114.5, 98, 91, 22)];
  pTitleImageView.image=[UIImage imageNamed:@"TitleBox.png"];
  [self.view addSubview:pTitleImageView];
  
  m_TitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,0, 91, 22)];
  [m_TitleLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
  m_TitleLabel.textColor=[UIColor colorWithRed:(87.1/100.0) green:(89.0/100.0) blue:(0.0/100.0) alpha:1.0];
  m_TitleLabel.backgroundColor=[UIColor clearColor];
  m_TitleLabel.textAlignment=UITextAlignmentCenter;
  m_TitleLabel.text=@"Power vs. DNI";
  [pTitleImageView addSubview:m_TitleLabel];
     
  m_Slider=[[UISlider alloc]initWithFrame:CGRectMake(12, 332, 296, 20)];
  m_Slider.continuous=NO;
  UIImage *maxImage=[UIImage imageNamed:@"Bar.png"];
  UIImage *minImage=[UIImage imageNamed:@"Bar.png"];
  UIImage *tumbImage= [UIImage imageNamed:@"Thumb.png"];
  
  minImage=[minImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
  maxImage=[maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
  
  [m_Slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
  [m_Slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
  [m_Slider setThumbImage:tumbImage forState:UIControlStateNormal];
  
  UITapGestureRecognizer *m_TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
  [m_Slider addGestureRecognizer:m_TapGestureRecognizer];
  
  [m_Slider addTarget:self action:@selector(handleSlider:) forControlEvents:UIControlEventValueChanged];      
  [self.view addSubview:m_Slider];
    
  isReloading=NO;
  [self updateSlider];
  [self updateGraphValuesFromServer];
}
-(void)didReceiveMemoryWarning
{
}

- (NSString*)getFormatedStringForDate:(NSDate*)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormatter setDateFormat:@"MM-dd-yyyy"];
  
  NSString *dateString = [dateFormatter stringFromDate:date];
  
  return dateString;
}
- (void)updateSlider
{
  /// Find current date is weekly or daily
  BOOL bGraphTypeDaily = ([m_TitleLabel.text compare:totalEnergyTitle] == NSOrderedSame) ? NO : YES;
  [[SliderManager SharedSliderManager] updateSlider:m_Slider andIsDailyGraph:bGraphTypeDaily];
  mPreviousValue=m_Slider.value;
}

- (void)updateGraphValuesFromServer
{
  /// Get current selected Date
  NSDate* currentSelectedDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentSelectedDateKey];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"dd"];
  NSString *dayInMonthStr = [dateFormatter stringFromDate:currentSelectedDate];
  int currentDay = [dayInMonthStr intValue];
  if(lastSelectedDay==-1)
    isReloading=YES;
  if(lastSelectedDay!=-1)
  {
    if(lastSelectedDay==currentDay&&!isReloading)
      return;
    else
      lastSelectedDay=currentDay;
  }
  else
  {
    lastSelectedDay=currentDay;
  }
  mPagingView.isEnabled=NO;
  NSDate* dailyGraphStartDate = currentSelectedDate;
  NSDate* dailyGraphEndDate = [currentSelectedDate dateByAddingTimeInterval:(24*60*60)*1];
  
  NSDate* weeklyGraphStartDate = [currentSelectedDate dateByAddingTimeInterval:-(24*60*60)*6];
  NSDate* weeklyGraphEndDate = currentSelectedDate;
  
  /// Call webservice api to get new values.
  if(m_webserviceProcessor)
  {
    [m_webserviceProcessor cancel];
    m_webserviceProcessor = nil;
  }
  
  if(m_parseStringListURL)
  {
    m_parseStringListURL = nil;
  }
  if(m_parseArrayDetailsURL)
  {
    m_parseArrayDetailsURL = nil;
  }
  if(m_parseTotalEnergyURL)
  {
    m_parseTotalEnergyURL = nil;
  }
  if(m_parseTopViewDataURL)
  {
    m_parseTopViewDataURL = nil;
  }
  
  [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ERROR"];
  
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
  
  [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"CONNECTION"];
  
  m_ActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(145, 200, 30, 30)];
  [m_ActivityIndicatorView startAnimating];
  m_ActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
  [self.view addSubview:m_ActivityIndicatorView];  
  
  NSString *pSessionToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"SESSION_TOKEN"];
  
  NSMutableArray* urls = [[NSMutableArray alloc] init];
  
  if(isReloading)
  {
    m_parseStringListURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetStringListforArray?sessionToken=%@&arrayID=%@",kserverAddress,pSessionToken,m_Array.m_ArrayId];
    
    [urls addObject:m_parseStringListURL];
  }
  
  m_parseArrayDetailsURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetDetailedArrayInfo?sessionToken=%@&arrayID=%@&startDate=%@&endDate=%@",kserverAddress,pSessionToken,m_Array.m_ArrayId, [self getFormatedStringForDate:dailyGraphStartDate], [self getFormatedStringForDate:dailyGraphEndDate]];
  [urls addObject:m_parseArrayDetailsURL];
  
  m_parseTotalEnergyURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetDailyArrayInfo?sessionToken=%@&arrayID=%@&startDate=%@&endDate=%@",kserverAddress,pSessionToken,m_Array.m_ArrayId, [self getFormatedStringForDate:weeklyGraphStartDate], [self getFormatedStringForDate:weeklyGraphEndDate]];
  [urls addObject:m_parseTotalEnergyURL];
  
  m_parseTopViewDataURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetCurrentArrayInfo?sessionToken=%@&arrayID=%@",kserverAddress,pSessionToken,m_Array.m_ArrayId];
  [urls addObject:m_parseTopViewDataURL];
  
//  NSLog(@"m_parseStringListURL = %@", m_parseStringListURL);
//  NSLog(@"m_parseArrayDetailsURL = %@", m_parseArrayDetailsURL);
//  NSLog(@"m_parseTotalEnergyURL = %@", m_parseTotalEnergyURL);
//  NSLog(@"m_parseTopViewDataURL = %@", m_parseTopViewDataURL);
  
  m_webserviceProcessor = [[WebserviceProcessor alloc] initWithURLs:urls delegate:self];
  mPreviousValue=m_Slider.value;
  
  [m_InverterView reloadInverter];
  [m_TrackerView reloadTracker];
  
  if(isReloading)
    isReloading=NO;
  
  isServerConnectionActive=YES;
}

- (void)onWebserviceProcessorSuccess:(WebserviceProcessor*)processor
{
  isServerConnectionActive=NO;
  mPreviousValue=m_Slider.value;
  if(m_parseStringListURL)
    [self jsonParser_ParseStringList:[processor dataForURL:m_parseStringListURL]];  
  if(m_parseArrayDetailsURL)
    [self jsonParser_parseArrayDetails:[processor dataForURL:m_parseArrayDetailsURL]];
  if(m_parseTotalEnergyURL)
    [self jsonParser_parseToatlEnergy:[processor dataForURL:m_parseTotalEnergyURL]];
  if(m_parseTopViewDataURL)
    [self jsonParser_parseTopViewData:[processor dataForURL:m_parseTopViewDataURL]];
  
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"CONNECTION"];
  mPagingView.isEnabled=YES;
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
}

- (void)onWebserviceProcessorError:(WebserviceProcessor*)processor
{
  isServerConnectionActive=NO;
  mPagingView.isEnabled=YES;
  //  Error Codes: 
  //  10001 – cannot connect to backend systems
  //  10002 – invalid username or password (displays an error message on top of the screen)
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
  
  UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Make sure your device has an active network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
  [pAlert show];
  pAlert=nil;        
}

- (void) sliderTapped: (UITapGestureRecognizer*) g 
{
  //printf("************************************************** sliderTapped\n");
  UISlider* s = (UISlider*)g.view;
  if(s.isTracking)
  {
    m_bTapped=NO;
    [self handleSlider:s];
    return;
  }
  if (s.highlighted)
  {
    if(mPreviousValue != s.value)
    {
      m_bTapped = YES;
      [self handleSlider:s];
    }
    else 
      return;
  }
  CGPoint pt = [g locationInView: s];
  CGFloat percentage = pt.x / s.bounds.size.width;
  CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
  CGFloat value = s.minimumValue + delta;
  if(value<s.value)
  {
    m_bTapped = YES;
    if([m_TitleLabel.text compare:totalEnergyTitle] == NSOrderedSame)
      [s setValue:s.value-7 animated:YES];
    else
      [s setValue:s.value-1 animated:YES];
    [self handleSlider:s];
    return;
  }
  if(value>s.value)
  {
    m_bTapped = YES;
    if([m_TitleLabel.text compare:totalEnergyTitle] == NSOrderedSame)
      [s setValue:s.value+7 animated:YES];
    else
      [s setValue:s.value+1 animated:YES];
    [self handleSlider:s];  
    return;
  }
}

-(void)viewWillAppear:(BOOL)animated
{  
    GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate creatingThreeTabBarControllers];
    
  for(int i=0;i<[self.navigationController.navigationBar.subviews count];i++)
  {
    UIView *pView=[[self.navigationController.navigationBar subviews]objectAtIndex:i];
    if([pView isKindOfClass:[UILabel class]])
    {
      UILabel *pLabel=(UILabel *)pView;
      [pLabel setFrame:CGRectMake(80, 8, 237, 30)];
      [pLabel setText:m_Array.m_Name];  
    }
  }
  //  self.navigationItem.title=m_Array.m_Name;
  
  [self.navigationController.navigationBar addSubview:m_Backbutton];
  
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ControlEnabled"];
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AlertEnabled"];
  
  [[NSUserDefaults standardUserDefaults]setObject:@"4" forKey:@"ENTITY_TYPE"];
  [[NSUserDefaults standardUserDefaults]setObject:m_Array.m_ArrayId forKey:@"ID"];
  [[NSUserDefaults standardUserDefaults]setObject:m_Array.m_Name forKey:@"ENTITY_NAME"];
  
  [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ERROR"];
  
  if(isGoingToNextLevel)
  {
    isReloading=YES;
    [self updateGraphValuesFromServer];
    isGoingToNextLevel=NO;
  }
}

-(void)fetchSessionToken
{
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
  m_ActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(145, 200, 30, 30)];
  [m_ActivityIndicatorView startAnimating];
  m_ActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
  [self.view addSubview:m_ActivityIndicatorView];  
  if(!mConnection)
  {
    mConnection=[[Connection alloc]init];
  }
  mConnection.m_delegate=self;
  
  [mConnection connectToServer];
  mPagingView.isEnabled=NO;
}

#pragma mark ConnectionDelegate Methods

-(void)ConnectionFailed
{
  mPagingView.isEnabled=YES;
    UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Make sure your device has an active network connection and try again"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
  [pAlert show];
  pAlert=nil;          
}

-(void)InvalidUserNameError:(int)errorIndex
{
  if(errorIndex==0)
  {
    UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Cannot connect to backend systems" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
    [pAlert show];
    pAlert=nil;              
  }
  else if(errorIndex==1)
  {
    [[LoginManager sharedLoginManagerWithDelegate:self] ShowLoginPage];
  }
  mPagingView.isEnabled=YES;
}

-(void)Success
{
  isReloading=YES;
  mPagingView.isEnabled=YES;
  [self updateGraphValuesFromServer];
}

-(void)backAction
{
     GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSArray *pushControllers = [self.navigationController viewControllers];
//    NSLog(@"Push... Arry...Count :::: %d",[pushControllers count]);
//    if ([pushControllers count] == 2) {
//        
//        GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
//        [appDelegate creatingTwoTabBarControllers];
//    }

  if(mConnection){mConnection.m_delegate=nil;mConnection=nil;}
  if(m_webserviceProcessor){[m_webserviceProcessor cancel];m_webserviceProcessor=nil;}
  if(m_Backbutton){[m_Backbutton removeFromSuperview];}
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"DATECHANGED"];
  
  mPagingView.delegate=nil;
  mPagingView.dataSource=nil;
  
  m_InverterView.m_delegate=nil;
  m_CameraScrollView.m_CameraView.m_deleagte=nil;
  m_TrackerView.m_delegate=nil;
  m_WindView.m_delegate=nil;
  m_TotalEnergyView.m_delegate=nil;
  
  [m_InverterView cleanUp];
  [m_CameraScrollView.m_CameraView cleanUp];
  
  [m_TopTileView removeFromSuperview];
  [m_AllTilesListView removeFromSuperview];
  [m_PowerVsDNIView removeFromSuperview];
  [m_TotalEnergyView removeFromSuperview];
  [m_WindView removeFromSuperview];
  [m_CameraScrollView removeFromSuperview];
  [m_TrackerView removeFromSuperview];
  [m_InverterView removeFromSuperview];
  [m_InverterListViewDCWest removeFromSuperview];
  [m_InverterListViewDCEast removeFromSuperview];
  [m_InverterListViewAC removeFromSuperview];
  [mPagingView removeFromSuperview];
  mPagingView=nil;
  
  m_TopTileView=nil;
  m_AllTilesListView=nil;
  m_PowerVsDNIView=nil;
  m_TotalEnergyView=nil;
  m_WindView=nil;
  m_CameraScrollView=nil;
  m_TrackerView=nil;
  m_InverterView=nil;
  m_InverterListViewDCWest=nil;
  m_InverterListViewDCEast=nil;
  m_InverterListViewAC=nil;

  [self.navigationController popViewControllerAnimated:YES];
    [appDelegate popservicebackbutton];
}

-(void)addTopTileView
{
  if(!m_TopTileView)
  {
    m_TopTileView=[[TopTileView alloc]initWithFrame:CGRectMake(8, 10, 304, 120)];
    [self.view addSubview:m_TopTileView];
  }
  
  if(m_Array.AlarmCount==0)
    [m_TopTileView setTopTileAlertImageName:@"Alert-Green.png"];
  else 
    [m_TopTileView setTopTileAlertImageName:@"Alert-red.png"];
  
  NSNumberFormatter *frmtr = [[NSNumberFormatter alloc] init];
  [frmtr setGroupingSize:3];
  [frmtr setGroupingSeparator:@","];
  [frmtr setUsesGroupingSeparator:YES];
  
  [m_TopTileView setTopTileDNI:[frmtr stringFromNumber:m_Array.m_CurrentDNI]];
  [m_TopTileView setTopTileTodayKWH:[frmtr stringFromNumber:m_Array.m_TodayEnergy]];
  [m_TopTileView setCurrentKWValue:m_Array.m_CurrentPower];
  
  NSString *temp;
  if(m_Array.m_Temperature != NULL)
  {
    float tempVal=[m_Array.m_Temperature floatValue];
    temp=[NSString stringWithFormat:@"%2.0f°C",tempVal];
  }
  else 
    temp=@"";
  
  if(m_Array.m_WeatherStatus != NULL)
  {
    NSString *pIconName=[NSString stringWithFormat:@"%@.png",m_Array.m_WeatherIcon];
    [m_TopTileView setTopTileWeatherImageName:pIconName];
    
    [m_TopTileView setTopTileWeatherDescription:[NSString stringWithFormat:@"   %@ %@",m_Array.m_WeatherStatus,temp]];
  }
  else 
    [m_TopTileView setTopTileWeatherDescription:@""];
  
  if(m_Array.m_WindDirection == NULL && m_Array.m_WindSpeed == NULL)
    [m_TopTileView setTopTileWindInfo:@""];
  else 
  {
    float windspeed=[m_Array.m_WindSpeed floatValue];
    [m_TopTileView setTopTileWindInfo:[NSString stringWithFormat:@"   %@ %2.1f m/s",m_Array.m_WindDirection,windspeed]];
  }
  
  [m_TopTileView setTopTileTime:[NSString stringWithFormat:@"%@",[DateTimeConverter getActualTimeStringFrom:m_Array.m_LocalDateTime]]];
  
  
  float scale=1*16;
  int range=ceil(scale/4.0);
  
  [m_TopTileView setTopTileValue1:[NSString stringWithFormat:@"%d",range*0]];
  [m_TopTileView setTopTileValue2:[NSString stringWithFormat:@"%d",range*1]];
  [m_TopTileView setTopTileValue3:[NSString stringWithFormat:@"%d",range*2]];
  [m_TopTileView setTopTileValue4:[NSString stringWithFormat:@"%d",range*3]];
  [m_TopTileView setTopTileValue5:[NSString stringWithFormat:@"%d",range*4]];
  
  if([m_Array.m_CurrentPower floatValue]<=scale/2)
  {
    float angle=((110.0)*([m_Array.m_CurrentPower floatValue]))/(scale/2);
    float rotationAngle=250.0+angle;
    [m_TopTileView setTopTilePowerProductionNeedleRotationAngle:((rotationAngle*0.0174532925))];     
  }
  else 
  {
    float angle=((110.0)*([m_Array.m_CurrentPower floatValue]-(scale/2)))/(scale/2);
    [m_TopTileView setTopTilePowerProductionNeedleRotationAngle:((angle*0.0174532925))];            
  }
  
  if([m_Array.m_CurrentDNI floatValue]<=600)
  {
    float angle=((110.0)*([m_Array.m_CurrentDNI floatValue]))/600.0;
    float rotationAngle=250.0+angle;
    [m_TopTileView setTopTilePowerVsDNINeedleRotationAngle:(rotationAngle*0.0174532925)];      
  }
  else 
  {
    float angle=((110.0)*([m_Array.m_CurrentDNI floatValue]-600.0))/600.0;
    [m_TopTileView setTopTilePowerVsDNINeedleRotationAngle:(angle*0.0174532925)];            
  }
    
  //If CurrentView is Inverter View
  if(mPagingView.currentPage==6)
  {
    [self pagingView:mPagingView didDisplayPage:6];
  }
    
  [m_TopTileView setOperationalMode:m_Array.m_TrackingMode];
  [m_TopTileView hideOperationMode:!m_Array.m_TrackingMode];
}

-(void)reloaddata
{
  if(self.navigationController.topViewController==self)
  {
    isDateChanged=YES;
    isReloading=YES;
    [self updateGraphValuesFromServer];
  }
}

#pragma mark URLConnectionManager Methods

-(void)jsonParser_ParseStringList:(NSData*)reponseData
{
  NSString *responseString=[[NSString alloc]initWithData:reponseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse String for GetStringListforArrayResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetStringListforArrayResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *rootResultDict=[rootResult objectAtIndex:0];
    
    NSObject *error=[rootResultDict objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {
      m_Array.totalCount=[[userResult objectForKey:@"TotalCount"] intValue];
      NSMutableArray *stringArray=[NSMutableArray array];
      for(int i=0;i<[rootResult count];i++)
      {
        NSDictionary *siteDictinary=[rootResult objectAtIndex:i];
        String *pString=[[String alloc]init];
        
        NSObject *pAlarmCount=[siteDictinary objectForKey:@"AlarmCount"];
        if(![pAlarmCount isKindOfClass:[NSNull class]])
          pString.AlarmCount=[[siteDictinary objectForKey:@"AlarmCount"] intValue];
        
        NSObject *pArrayCount=[siteDictinary objectForKey:@"ArrayCount"];
        if(![pArrayCount isKindOfClass:[NSNull class]])
          pString.ArrayCount=[[siteDictinary objectForKey:@"ArrayCount"] intValue];
        
        NSObject *pSiteId=[siteDictinary objectForKey:@"ID"];
        if(![pSiteId isKindOfClass:[NSNull class]])
          pString.m_StringId=[siteDictinary objectForKey:@"ID"];      
        
        NSObject *pCurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
        if(![pCurrentDNI isKindOfClass:[NSNull class]])
          pString.m_CurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
        
        NSObject *pCurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
        if(![pCurrentPower isKindOfClass:[NSNull class]])
          pString.m_CurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
        
        NSObject *pLocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
        if(![pLocalDateTime isKindOfClass:[NSNull class]])
          pString.m_LocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
        
        NSObject *pLocation=[siteDictinary objectForKey:@"Location"];
        if(![pLocation isKindOfClass:[NSNull class]])
          pString.m_Location=[siteDictinary objectForKey:@"Location"];
        
        NSObject *pName=[siteDictinary objectForKey:@"Name"];
        if(![pName isKindOfClass:[NSNull class]])
          pString.m_Name=[siteDictinary objectForKey:@"Name"];
        
        NSObject *pTemperature=[siteDictinary objectForKey:@"Temperature"];
        if(![pTemperature isKindOfClass:[NSNull class]])
          pString.m_Temperature=[[siteDictinary objectForKey:@"Temperature"] stringValue];
        
        NSString *pWindDirection=(NSString *)[siteDictinary objectForKey:@"WindDirection"];
        if(![pWindDirection isEqualToString:@""])
          pString.m_WindDirection=[siteDictinary objectForKey:@"WindDirection"];
        
        NSObject *pWindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        if(![pWindSpeed isKindOfClass:[NSNull class]])
          pString.m_WindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        
        NSObject *pTodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
        if(![pTodayEnergy isKindOfClass:[NSNull class]])
          pString.m_TodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
        
        NSObject *pUTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
        if(![pUTCDateTime isKindOfClass:[NSNull class]])
          pString.m_UTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
        
        NSObject *pUTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
        if(![pUTCOffset isKindOfClass:[NSNull class]])
          pString.m_UTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
        
        NSObject *pWeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
        if(![pWeatherStatus isKindOfClass:[NSNull class]])
          pString.m_WeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
        
        NSObject *pWeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];
        if(![pWeatherIcon isKindOfClass:[NSNull class]])
          pString.m_WeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];                        
        
        NSObject *pYTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
        if(![pYTDEnergy isKindOfClass:[NSNull class]])
          pString.m_YTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
        
          pString.StringCount = [rootResult count];
          
        [stringArray addObject:pString];

        pString=nil;
      }
      m_Array.m_StringArray=[NSArray arrayWithArray:stringArray];
      stringArray=nil;
      [[NSUserDefaults standardUserDefaults]setObject:@"array" forKey:@"BACK_BUTTON"];
      [m_AllTilesListView fillScrollViewWithArray:m_Array.m_StringArray];
    }
    else 
    {
      NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
      if([errorId intValue]==10002 || [errorId intValue]==10026 || [errorId intValue]==10028 || [errorId intValue]==10029)
        [[LoginManager sharedLoginManagerWithDelegate:self] ShowLoginPage];
      if(![[NSUserDefaults standardUserDefaults]boolForKey:@"ERROR"])
      {
        if([errorId intValue]!=10003)
        {
          UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:[rootResultDict objectForKey:@"Err"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
          [pAlert show];
          pAlert=nil;    
        }
      }
      if([errorId intValue]==10003)
      {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ERROR"];
        
        [self fetchSessionToken];
      }
      if([errorId intValue]==10002 || [errorId intValue]==10026 || [errorId intValue]==10028 || [errorId intValue]==10029)
      {
        [[LoginManager sharedLoginManagerWithDelegate:self]ShowLoginPage];
      }
    }
  }
}

-(void)jsonParser_parseArrayDetails:(NSData*)responseData
{  
  NSMutableArray *arrayDetailArray=[[NSMutableArray alloc]init];
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse String for GetDetailedArrayInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetDetailedArrayInfoResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *rootResultDict=[rootResult objectAtIndex:0];
    
    NSObject *error=[rootResultDict objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {      
      for(int i=0;i<[rootResult count];i++)
      {
        NSDictionary *siteDictinary=[rootResult objectAtIndex:i];
        EntityDetails *pEntityDetails=[[EntityDetails alloc]init];
        
        NSObject *pDNI=[siteDictinary objectForKey:@"DNI"];
        if(![pDNI isKindOfClass:[NSNull class]])
          pEntityDetails.m_DNI=[siteDictinary objectForKey:@"DNI"];
        
        NSObject *pLocalDateTime=[siteDictinary objectForKey:@"DateTimeLocal"];
        if(![pLocalDateTime isKindOfClass:[NSNull class]])
          pEntityDetails.m_DateTimeLocal=[siteDictinary objectForKey:@"DateTimeLocal"];
        
        NSObject *pEnergy=[siteDictinary objectForKey:@"Energy"];
        if(![pEnergy isKindOfClass:[NSNull class]])
          pEntityDetails.m_Energy=[siteDictinary objectForKey:@"Energy"];
        
        NSObject *pPower=[siteDictinary objectForKey:@"Power"];
        if(![pPower isKindOfClass:[NSNull class]])
          pEntityDetails.m_Power=[siteDictinary objectForKey:@"Power"];
        
        NSObject *pWindDirection=[siteDictinary objectForKey:@"WindDirection"];
        if(![pWindDirection isKindOfClass:[NSNull class]])
          pEntityDetails.m_WindDirection=[siteDictinary objectForKey:@"WindDirection"];
        
        NSObject *pWindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        if(![pWindSpeed isKindOfClass:[NSNull class]])
          pEntityDetails.m_WindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        
        [arrayDetailArray addObject:pEntityDetails];
        pEntityDetails=nil;
      }

      [m_PowerVsDNIView fillValuesFrom:arrayDetailArray andArrayCount:m_Array.ArrayCount];
      [m_WindView fillValuesFrom:arrayDetailArray];
    }
    else 
    {
      NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
      if([errorId intValue]==10002 || [errorId intValue]==10026 || [errorId intValue]==10028 || [errorId intValue]==10029)
        [[LoginManager sharedLoginManagerWithDelegate:self] ShowLoginPage];
      if(![[NSUserDefaults standardUserDefaults]boolForKey:@"ERROR"])
      {
        if([errorId intValue]!=10003)
        {
          UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:[rootResultDict objectForKey:@"Err"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
          [pAlert show];
          pAlert=nil;    
        }
      } 
      if([errorId intValue]==10003)
      {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ERROR"];
        
        {
          [self fetchSessionToken];
        }
      }            
    }
  }
  else 
  {
    if([rootResult count]==0)
    {
      [m_WindView fillValuesFrom:arrayDetailArray];
    }
  }  
}

-(void)jsonParser_parseToatlEnergy:(NSData*)responseData
{
  NSMutableArray *energyInfoArray=[[NSMutableArray alloc]init];
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse String for GetDailyArrayInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetDailyArrayInfoResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *rootResultDict=[rootResult objectAtIndex:0];
    
    NSObject *error=[rootResultDict objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {      
      for(int i=0;i<[rootResult count];i++)
      {
        NSDictionary *siteDictinary=[rootResult objectAtIndex:i];
        EntityDetails *pEntityDetails=[[EntityDetails alloc]init];
        
        NSObject *pDNI=[siteDictinary objectForKey:@"DNI"];
        if(![pDNI isKindOfClass:[NSNull class]])
          pEntityDetails.m_DNI=[siteDictinary objectForKey:@"DNI"];
        
        NSObject *pLocalDateTime=[siteDictinary objectForKey:@"DateTimeLocal"];
        if(![pLocalDateTime isKindOfClass:[NSNull class]])
          pEntityDetails.m_DateTimeLocal=[siteDictinary objectForKey:@"DateTimeLocal"];
        
        NSObject *pEnergy=[siteDictinary objectForKey:@"Energy"];
        if(![pEnergy isKindOfClass:[NSNull class]])
          pEntityDetails.m_Energy=[siteDictinary objectForKey:@"Energy"];
        
        NSObject *pPower=[siteDictinary objectForKey:@"Power"];
        if(![pPower isKindOfClass:[NSNull class]])
          pEntityDetails.m_Power=[siteDictinary objectForKey:@"Power"];
        
        NSObject *pWindDirection=[siteDictinary objectForKey:@"WindDirection"];
        if(![pWindDirection isKindOfClass:[NSNull class]])
          pEntityDetails.m_WindDirection=[siteDictinary objectForKey:@"WindDirection"];
        
        NSObject *pWindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        if(![pWindSpeed isKindOfClass:[NSNull class]])
          pEntityDetails.m_WindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        
        [energyInfoArray addObject:pEntityDetails];

        pEntityDetails=nil;
      }
      [m_TotalEnergyView drawGraphFromValues:energyInfoArray];
    }
    else 
    {
      NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
      if([errorId intValue]==10002 || [errorId intValue]==10026 || [errorId intValue]==10028 || [errorId intValue]==10029)
        [[LoginManager sharedLoginManagerWithDelegate:self] ShowLoginPage];
      if(![[NSUserDefaults standardUserDefaults]boolForKey:@"ERROR"])
      {
        if([errorId intValue]!=10003)
        {
          UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:[rootResultDict objectForKey:@"Err"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
          [pAlert show];
          pAlert=nil;    
        }
      }    
      if([errorId intValue]==10003)
      {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ERROR"];
        
        {
          [self fetchSessionToken];
        }
      }            
    }
  }
}

-(void)jsonParser_parseTopViewData:(NSData*)responseData
{  
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse String for GetCurrentArrayInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetCurrentArrayInfoResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *rootResultDict=[rootResult objectAtIndex:0];
    
    NSObject *error=[rootResultDict objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {      
      NSObject *pAlarmCount=[rootResultDict objectForKey:@"AlarmCount"];
      if(![pAlarmCount isKindOfClass:[NSNull class]])
        m_Array.AlarmCount=[[rootResultDict objectForKey:@"AlarmCount"] intValue];
      
      NSObject *pArrayCount=[rootResultDict objectForKey:@"ArrayCount"];
      if(![pArrayCount isKindOfClass:[NSNull class]])
        m_Array.ArrayCount=[[rootResultDict objectForKey:@"ArrayCount"] intValue];
      
      NSObject *pCameraID=[rootResultDict objectForKey:@"CameraID"];
      if(![pCameraID isKindOfClass:[NSNull class]])
        m_Array.CameraID=[[rootResultDict objectForKey:@"CameraID"] intValue];
      
      NSObject *pSiteId=[rootResultDict objectForKey:@"ID"];
      if(![pSiteId isKindOfClass:[NSNull class]])
        m_Array.m_ArrayId=[rootResultDict objectForKey:@"ID"];      
      
      NSObject *pCurrentDNI=[rootResultDict objectForKey:@"CurrentDNI"];
      if(![pCurrentDNI isKindOfClass:[NSNull class]])
        m_Array.m_CurrentDNI=[rootResultDict objectForKey:@"CurrentDNI"];
      
      NSObject *pCurrentPower=[rootResultDict objectForKey:@"CurrentPower"];
      if(![pCurrentPower isKindOfClass:[NSNull class]])
        m_Array.m_CurrentPower=[rootResultDict objectForKey:@"CurrentPower"];
      
      NSObject *pLocalDateTime=[rootResultDict objectForKey:@"LocalDateTime"];
      if(![pLocalDateTime isKindOfClass:[NSNull class]])
        m_Array.m_LocalDateTime=[rootResultDict objectForKey:@"LocalDateTime"];
      
      NSObject *pLocation=[rootResultDict objectForKey:@"Location"];
      if(![pLocation isKindOfClass:[NSNull class]])
        m_Array.m_Location=[rootResultDict objectForKey:@"Location"];
      
      NSObject *pName=[rootResultDict objectForKey:@"Name"];
      if(![pName isKindOfClass:[NSNull class]])
        m_Array.m_Name=[rootResultDict objectForKey:@"Name"];
      
      NSObject *pTemperature=[rootResultDict objectForKey:@"Temperature"];
      if(![pTemperature isKindOfClass:[NSNull class]])
        m_Array.m_Temperature=[[rootResultDict objectForKey:@"Temperature"] stringValue];
      
      NSString *pWindDirection=(NSString *)[rootResultDict objectForKey:@"WindDirection"];
      if(![pWindDirection isEqualToString:@""])
        m_Array.m_WindDirection=[rootResultDict objectForKey:@"WindDirection"];
      
      NSObject *pWindSpeed=[rootResultDict objectForKey:@"WindSpeed"];
      if(![pWindSpeed isKindOfClass:[NSNull class]])
        m_Array.m_WindSpeed=[rootResultDict objectForKey:@"WindSpeed"];
      
      NSObject *pTodayEnergy=[rootResultDict objectForKey:@"TodayEnergy"];
      if(![pTodayEnergy isKindOfClass:[NSNull class]])
        m_Array.m_TodayEnergy=[rootResultDict objectForKey:@"TodayEnergy"];
      
      NSObject *pUTCDateTime=[rootResultDict objectForKey:@"UTCDateTime"];
      if(![pUTCDateTime isKindOfClass:[NSNull class]])
        m_Array.m_UTCDateTime=[rootResultDict objectForKey:@"UTCDateTime"];
      
      NSObject *pUTCOffset=[rootResultDict objectForKey:@"UTCOffset"];
      if(![pUTCOffset isKindOfClass:[NSNull class]])
        m_Array.m_UTCOffset=[rootResultDict objectForKey:@"UTCOffset"];
      
      NSObject *pWeatherStatus=[rootResultDict objectForKey:@"WeatherStatus"];
      if(![pWeatherStatus isKindOfClass:[NSNull class]])
        m_Array.m_WeatherStatus=[rootResultDict objectForKey:@"WeatherStatus"];
      
      NSObject *pWeatherIcon=[rootResultDict objectForKey:@"WeatherIcon"];
      if(![pWeatherIcon isKindOfClass:[NSNull class]])
        m_Array.m_WeatherIcon=[rootResultDict objectForKey:@"WeatherIcon"];
      
      NSObject *pYTDEnergy=[rootResultDict objectForKey:@"YTDEnergy"];
      if(![pYTDEnergy isKindOfClass:[NSNull class]])
        m_Array.m_YTDEnergy=[rootResultDict objectForKey:@"YTDEnergy"];
      
      NSObject *pOperationalMode=[rootResultDict objectForKey:@"OperationalMode"];
      if(![pOperationalMode isKindOfClass:[NSNull class]])
          m_Array.m_TrackingMode=[rootResultDict objectForKey:@"OperationalMode"];
      else
          m_Array.m_TrackingMode=@"";
        
      [self addTopTileView];
    }
    else 
    {
      NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
      if(![[NSUserDefaults standardUserDefaults]boolForKey:@"ERROR"])
      {
        if([errorId intValue]!=10003)
        {
          UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:[rootResultDict objectForKey:@"Err"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
          [pAlert show];
          pAlert=nil;    
        }
      }
      
      if([errorId intValue]==10003)
      {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ERROR"];
        
        {   
          [self fetchSessionToken];
        }
      }
    }
  }
}
#pragma mark  CameraViewDelegate methods
-(void)fetchSessionTokenforCamera
{
  [self fetchSessionToken];
}

#pragma mark WindScrollViewDelegate methods

-(void)fetchSessionTokenforWindScrollView
{
  [self fetchSessionToken];
}

#pragma mark TrackerViewDelegate methods

-(void)fetchSessionTokenforTracker
{
  [self fetchSessionToken];
}

#pragma mark LoginViewControllerDelegate methods

-(void)LoginSuccess:(NSString *)sessionToken
{
}

-(void)handleSlider:(id)sender
{  
  if(!m_bTapped)
  {
    if(m_bTapped)
      m_bTapped=NO;
    if((int)m_Slider.value==mPreviousValue)
    {
      return;
    }
  }
  /// Find current date is weekly or daily
  BOOL bGraphTypeDaily = ([m_TitleLabel.text compare:totalEnergyTitle] == NSOrderedSame) ? NO : YES;
  
  [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"DATECHANGED"];
  isDateChanged=YES;
  
  [[SliderManager SharedSliderManager] handleSlider:m_Slider andIsDailyGraph:bGraphTypeDaily withRespectToObject:m_Array];
  
  [self updateGraphValuesFromServer];
}


#pragma mark InverterViewDelegate methods

-(void)finishedDownloading:(NSArray *)pArray
{
  NSArray *InverterArray=pArray;
  Inverter *pInverter1=nil,*pInverter2=nil;
  
  if([InverterArray count])
  {
    if([[InverterArray objectAtIndex:0] mStringNumber]==1)
    {
      pInverter1=[InverterArray objectAtIndex:0];
      if([InverterArray count]>1)
        pInverter2=[InverterArray objectAtIndex:1];
    }
    else 
    {
      pInverter2=[InverterArray objectAtIndex:0];
      if([InverterArray count]>1)
        pInverter1=[InverterArray objectAtIndex:1];      
    }
    
    if(pInverter1 && pInverter2)
    {
      [m_InverterListViewAC setInverterPower:[NSString stringWithFormat:@"%.02f kW",pInverter1.mAC_Power+pInverter2.mAC_Power]];
      [m_InverterListViewAC setInverterPhase1:[NSString stringWithFormat:@"%.02f V",(pInverter1.mPhase1+pInverter2.mPhase1)/2]];
      [m_InverterListViewAC setInverterPhase2:[NSString stringWithFormat:@"%.02f V",(pInverter1.mPhase2+pInverter2.mPhase2)/2]];
      [m_InverterListViewAC setInverterPhase3:[NSString stringWithFormat:@"%.02f V",(pInverter1.mPhase3+pInverter2.mPhase3)/2]];
      [m_InverterListViewAC setInverterCurrent:[NSString stringWithFormat:@"%.02f A",pInverter1.mAC_Current+pInverter2.mAC_Current]];
      [m_InverterListViewAC setInverterPowerFactor:[NSString stringWithFormat:@"%.02f",(pInverter1.mpFactor+pInverter2.mpFactor)/2]];
      [m_InverterListViewAC setInverterFrequency:[NSString stringWithFormat:@"%.02f Hz",(pInverter1.mFrequency+pInverter2.mFrequency)/2]];
    }
    
    if(pInverter1)
    {
      [m_InverterListViewDCEast setInverterPower:[NSString stringWithFormat:@"%.02f kW",pInverter1.mDC_Power]];
      [m_InverterListViewDCEast setInverterVoltage:[NSString stringWithFormat:@"%.02f V",pInverter1.mDC_Voltage]];
      [m_InverterListViewDCEast setInverterCurrent:[NSString stringWithFormat:@"%.02f A",pInverter1.mDC_Current]];
      [m_InverterListViewDCEast setInverterGFVoltage:[NSString stringWithFormat:@"%.02f V",pInverter1.mGF_Voltage]];
      [m_InverterListViewDCEast setInverterGFCurrent:[NSString stringWithFormat:@"%.02f A",pInverter1.mGF_Current]];
      [m_InverterListViewDCEast setInverterGFIMP:[NSString stringWithFormat:@"%.02f Ω",pInverter1.mGF_Impedance]];
    }
    
    if(pInverter2)
    {
      [m_InverterListViewDCWest setInverterPower:[NSString stringWithFormat:@"%.02f kW",pInverter2.mDC_Power]];
      [m_InverterListViewDCWest setInverterVoltage:[NSString stringWithFormat:@"%.02f V",pInverter2.mDC_Voltage]];
      [m_InverterListViewDCWest setInverterCurrent:[NSString stringWithFormat:@"%.02f A",pInverter2.mDC_Current]];
      [m_InverterListViewDCWest setInverterGFVoltage:[NSString stringWithFormat:@"%.02f V",pInverter2.mGF_Voltage]];
      [m_InverterListViewDCWest setInverterGFCurrent:[NSString stringWithFormat:@"%.02f A",pInverter2.mGF_Current]];
      [m_InverterListViewDCWest setInverterGFIMP:[NSString stringWithFormat:@"%.02f Ω",pInverter2.mGF_Impedance]];
    }
  }
}

-(void)fetchSessionTokenforInverter
{
  [self fetchSessionToken];
}

#pragma mark AllTilesListViewDelegate methods

-(void)ClickedTileWithIndex:(int)index
{
  if(isServerConnectionActive)
    return;
  isGoingToNextLevel=YES;
  if(mConnection){mConnection.m_delegate=nil;mConnection=nil;}
  
  [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"DATECHANGED"];
  [[NSUserDefaults standardUserDefaults]setObject:@"array" forKey:@"BACK_BUTTON"];
  [m_Backbutton removeFromSuperview];
  String *pString=[m_Array.m_StringArray objectAtIndex:index];
  StringViewController *pStringViewController=[[StringViewController alloc]initWithString:pString];
  [self.navigationController pushViewController:pStringViewController animated:YES];
//   
//   //PUSHING IN CONTROL LEVEL
//    ControlViewController *stringViewController=[ControlViewController alloc];
//    [self.navigationController pushViewController:stringViewController animated:YES];

    
  m_Array.m_StringArray=nil;
}

#pragma mark -- LoginManagerDelegate
-(void)loginManager:(LoginManager*)manager loggedInSuccesfullyWithSessionToken:(NSString*)sessionToken
{
  [self.navigationController popToRootViewControllerAnimated:YES];  
}

#pragma mark -- PagingViewDataSource
-(NSInteger)pagingViewNoOfPages:(PagingView*)pagingView
{
  return 7;
}
-(UIView*)pagingView:(PagingView*)pagingView viewForPage:(NSInteger)page
{
  UIView *view=nil;
  switch (page)
  {
    case 0:
      //Power Vs DNI
      view=m_PowerVsDNIView;
      break;
    case 1:
      //String List
      view=m_AllTilesListView;
      break;
    case 2:
      //Total Energy
      view=m_TotalEnergyView;
      break;
    case 3:
      //Wind
      view=m_WindView;
      break;
    case 4:
      //Camera
      view=m_CameraScrollView;
      break;
    case 5:
      //Tracker
      view=m_TrackerView;
      break;
    case 6:
      //Inverter
      view=m_InverterView;
      break;
    default:
      break;
  }
  return view;
}
#pragma mark -- PagingViewDelegate
-(void)pagingView:(PagingView*)pagingView didDisplayPage:(NSInteger)page
{
  switch (page)
  {
    case 0:
      //Power Vs DNI
      m_Slider.hidden=NO;
      m_TitleLabel.text=@"Power Vs DNI";
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 1:
      //String List
      m_Slider.hidden=YES;
      m_TitleLabel.text=@"String View";
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 2:
      //Total Energy
      m_Slider.hidden=NO;
      m_TitleLabel.text=totalEnergyTitle;
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 3:
      //Wind
      m_Slider.hidden=NO;
      m_TitleLabel.text=@"Wind";
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 4:
      //Camera
      m_Slider.hidden=YES;
      m_TitleLabel.text=@"Camera";
      m_CameraScrollView.m_CameraView.isVisible=YES;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 5:
      //Tracker
      m_Slider.hidden=YES;
      m_TitleLabel.text=@"Tracker";
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=YES;
      m_InverterListViewDCEast.hidden=YES;
      m_InverterListViewAC.hidden=YES;
      m_TopTileView.hidden=NO;
      m_InverterImageView.hidden=YES;
      break;
    case 6:
      //Inverter
      m_Slider.hidden=YES;
      m_TitleLabel.text=@"Inverters";
      m_CameraScrollView.m_CameraView.isVisible=NO;
      m_InverterListViewDCWest.hidden=NO;
      m_InverterListViewDCEast.hidden=NO;
      m_InverterListViewAC.hidden=NO;
      m_TopTileView.hidden=YES;
      m_InverterImageView.hidden=NO;
      break;
    default:
      break;
  }
  if(page==1)
  {
    m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBGBlank.png"];
  }
  else 
  {
    m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBG.png"];
  }
  [self updateSlider];
}
@end
