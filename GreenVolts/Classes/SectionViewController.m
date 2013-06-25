//
//  SectionViewController.m
//  GreenVolts
//
//  Created by YML on 8/27/11.
//  Copyright 2011 YML. All rights reserved.
//

#import "SectionViewController.h"
#import "TopTileView.h"
#import "ArrayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "EntityDetails.h"
#import "LoginManager.h"
#import "SBJson.h"
#import "DataPrefetcher.h"
#import "String.h"
#import "StringViewController.h"
#import "DateTimeConverter.h"
#import "SliderManager.h"
#import "AllMiniTilesListView.h"
#import "GreenVoltsAppDelegate.h"

@interface SectionViewController(PVT)<AllTilesListViewDelegate,LoginManagerDelegate,ConnectionDelegate,WindScrollViewDelegate,DataPrefetcherDelegate,CameraViewDelegate>
-(void)ClickedTileWithIndex:(int)index;
-(void)addTopTileView;
-(void)updateGraphValuesFromServer;
-(void)jsonParser_ParseArrayList:(NSData*)responseData;
-(void)jsonParser_parseSectionDetails:(NSData*)responseData;
-(void)jsonParser_parseToatlEnergy:(NSData*)responseData;
-(void)jsonParser_parseTopViewData:(NSData*)responseData;
-(void)handleSlider:(id)sender;
- (void)updateSlider;
@end

@implementation SectionViewController
-(id)initWithSection:(Section *)pSection
{
  if((self = [super init]))
  {
    isGoingToNextLevel=NO;
    m_Section=pSection;
    
    m_TopTileView=nil;
    m_AllTilesListView=nil;
    m_PowerVsDNIView=nil;
    m_TotalEnergyView=nil;
    m_WindView=nil;
    m_CameraScrollView=nil;
    m_BackgroundImageView=nil;
    m_TitleLabel=nil;
    m_Slider=nil;
    
    isGoBack=NO;
    
    mConnection=[[Connection alloc]init];
    
    m_webserviceProcessor = nil;
    m_parseStringListURL = nil;
    m_parseArrayDetailsURL = nil;
    m_parseTotalEnergyURL = nil;
    m_parseTopViewDataURL = nil;
    
    m_ActivityIndicatorView=nil;    
    
    m_bTapped = NO;
    lastSelectedDay=-1;
    //printf("SectionVC init with Section:\n%s\n",[[pSection description]UTF8String]);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloaddata) name:@"RELOAD_DATA" object:nil];
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
  
  if(m_Section){m_Section=nil;}
  
  if(m_TopTileView){m_TopTileView=nil;}
  if(m_AllTilesListView){m_AllTilesListView=nil;}
  if(m_PowerVsDNIView){m_PowerVsDNIView=nil;}
  if(m_TotalEnergyView){m_TotalEnergyView=nil;}
  if(m_WindView){m_WindView.m_delegate=nil;m_WindView=nil;}
  if(m_CameraScrollView)
  {
    m_CameraScrollView.m_CameraView.m_deleagte=nil;
    m_CameraScrollView=nil;
  }
  if(m_Slider){m_Slider=nil;}
  if(m_TitleLabel){m_TitleLabel=nil;}
  if(m_BackgroundImageView){m_BackgroundImageView=nil;}
  
  if(m_Backbutton){[m_Backbutton removeFromSuperview];}
  if(mDataPrefetcher)
  {
    mDataPrefetcher.delegate=nil;
    [mDataPrefetcher CancelConnection];
    mDataPrefetcher=nil;
  }
  
}


-(void)loadView
{
  self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
  self.view.backgroundColor=[UIColor colorWithRed:(10.2/100.0) green:(13.3/100.0) blue:(13.7/100.0) alpha:1.0];
  
  [self addTopTileView];
  
  [self.navigationItem setHidesBackButton:YES animated:NO];
  
  if([self.navigationController.viewControllers objectAtIndex:0]!=self)
  {
    m_Backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    m_Backbutton.frame=CGRectMake(5, 8, 72, 30);
    [m_Backbutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[[NSUserDefaults standardUserDefaults]objectForKey:@"BACK_BUTTON"] ofType:@"png"]] forState:UIControlStateNormal];
    [m_Backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
  }
  
  m_BackgroundImageView=[[UIImageView alloc]initWithFrame:CGRectMake(8, 110, 304, 247)];
  m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBGBlank.png"];
  [self.view addSubview:m_BackgroundImageView];
  
  m_AllTilesListView=[[AllMiniTilesListView alloc]initWithFrame:CGRectMake(0, 0,304, 250)];
  m_AllTilesListView.m_deleagte=self;
  
  m_PowerVsDNIView=[[PowerVsDNIScrollView alloc]initWithFrame:CGRectMake(2,2,298,250)];
  
  m_TotalEnergyView=[[TotalEnergyView alloc]initWithFrame:CGRectMake(0,0,304,250)];
  
  m_WindView=[[WindScrollView alloc]initWithFrame:CGRectMake(2,2,298,250)];
  m_WindView.m_delegate=self;
    
  mPagingView=[[PagingView alloc]initWithFrame:CGRectMake(8,110,304,255)];
  mPagingView.delegate=self;
  mPagingView.dataSource=self;
  mPagingView.isEnabled=NO;
  [self.view addSubview:mPagingView];  
    
  m_CameraScrollView=[[CameraScrollView alloc]initWithFrame:CGRectMake(0, 0,304, 250) CameraID:m_Section.CameraID PagingView:mPagingView canScrollRight:NO];
  m_CameraScrollView.m_CameraView.m_deleagte=self;
  
 
  
  
  UIImageView *pTitleImageView=[[UIImageView alloc]initWithFrame:CGRectMake(114.5, 98, 91, 22)];
  pTitleImageView.image=[UIImage imageNamed:@"TitleBox.png"];
  [self.view addSubview:pTitleImageView];
  
  m_TitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 91, 22)];
  [m_TitleLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
  m_TitleLabel.textColor=[UIColor colorWithRed:(87.1/100.0) green:(89.0/100.0) blue:(0.0/100.0) alpha:1.0];
  m_TitleLabel.backgroundColor=[UIColor clearColor];
  m_TitleLabel.textAlignment=UITextAlignmentCenter;
  m_TitleLabel.text=@"Array View";
  [pTitleImageView addSubview:m_TitleLabel];
  
  m_Slider=[[UISlider alloc]initWithFrame:CGRectMake(12, 332, 296, 20)];
  m_Slider.continuous=NO;
  UIImage *maxImage=[UIImage imageNamed:@"Bar.png"];
  UIImage *minImage=[UIImage imageNamed:@"Bar.png"];
  UIImage *tumbImage= [UIImage imageNamed:@"Thumb.png"];
  
  minImage=[minImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
  maxImage=[maxImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
  
  // Setup the FX slider
  [m_Slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
  [m_Slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
  [m_Slider setThumbImage:tumbImage forState:UIControlStateNormal];
  
  
  [m_Slider addTarget:self action:@selector(handleSlider:) forControlEvents:UIControlEventValueChanged];    
  
  UITapGestureRecognizer *m_TapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
  [m_Slider addGestureRecognizer:m_TapGestureRecognizer];
  
  [self.view addSubview:m_Slider];
  m_Slider.hidden=YES;
  
  isReloading=NO;
  [self updateSlider];
  [self updateGraphValuesFromServer];
}
-(void)didReceiveMemoryWarning
{
}
- (void)updateSlider
{
  /// Find current date is weekly or daily
  BOOL bGraphTypeDaily = ([m_TitleLabel.text compare:totalEnergyTitle] == NSOrderedSame) ? NO : YES;
  [[SliderManager SharedSliderManager] updateSlider:m_Slider andIsDailyGraph:bGraphTypeDaily];
  mPreviousValue=m_Slider.value;
}

- (NSString*)getFormatedStringForDate:(NSDate*)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormatter setDateFormat:@"MM-dd-yyyy"];
  
  NSString *dateString = [dateFormatter stringFromDate:date];  
  return dateString;
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
    {
      return;
    }
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
    m_parseStringListURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetArrayListforSection?sessionToken=%@&sectionID=%@",kserverAddress,pSessionToken,m_Section.m_SectionId];
    [urls addObject:m_parseStringListURL];
  }
  
  m_parseArrayDetailsURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetDetailedSectionInfo?sessionToken=%@&sectionID=%@&startDate=%@&endDate=%@",kserverAddress,pSessionToken,m_Section.m_SectionId, [self getFormatedStringForDate:dailyGraphStartDate], [self getFormatedStringForDate:dailyGraphEndDate]];
  [urls addObject:m_parseArrayDetailsURL];
  
  m_parseTotalEnergyURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetDailySectionInfo?sessionToken=%@&sectionID=%@&startDate=%@&endDate=%@",kserverAddress,pSessionToken,m_Section.m_SectionId, [self getFormatedStringForDate:weeklyGraphStartDate], [self getFormatedStringForDate:weeklyGraphEndDate]];
  [urls addObject:m_parseTotalEnergyURL];
  
  m_parseTopViewDataURL = [NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetCurrentSectionInfo?sessionToken=%@&sectionID=%@",kserverAddress,pSessionToken,m_Section.m_SectionId];
  [urls addObject:m_parseTopViewDataURL];
  
  //NSLog(@"m_parseStringListURL = %@", m_parseStringListURL);
  //NSLog(@"m_parseArrayDetailsURL = %@", m_parseArrayDetailsURL);
  //NSLog(@"m_parseTotalEnergyURL = %@", m_parseTotalEnergyURL);
  //NSLog(@"m_parseTopViewDataURL = %@", m_parseTopViewDataURL);
  
  m_webserviceProcessor = [[WebserviceProcessor alloc] initWithURLs:urls delegate:self];
  mPreviousValue=m_Slider.value;
  if(isReloading)
    isReloading=NO;
}

- (void)onWebserviceProcessorSuccess:(WebserviceProcessor*)processor
{
  mPreviousValue=m_Slider.value;
  
  if(m_parseStringListURL)
    [self jsonParser_ParseArrayList:[processor dataForURL:m_parseStringListURL]];  
  if(m_parseArrayDetailsURL)
    [self jsonParser_parseSectionDetails:[processor dataForURL:m_parseArrayDetailsURL]];
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
    
  if([[NSUserDefaults standardUserDefaults]boolForKey:@"DATECHANGED"])
  {
    isDateChanged=YES;
    level=[[NSUserDefaults standardUserDefaults]integerForKey:@"LEVEL"];    
  }
  
  for(int i=0;i<[self.navigationController.navigationBar.subviews count];i++)
  {
    UIView *pView=[[self.navigationController.navigationBar subviews]objectAtIndex:i];
    if([pView isKindOfClass:[UILabel class]])
    {
      UILabel *pLabel=(UILabel *)pView;
      [pLabel setText:m_Section.m_Name];
      [pLabel setFrame:CGRectMake(80, 8, 237, 30)];
    }
  }
  //  self.navigationItem.title=m_Section.m_Name;
  [self.navigationController.navigationBar addSubview:m_Backbutton];
  
#ifdef DEMO_BUILD
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ControlEnabled"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AlertEnabled"];
#else 
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"ControlEnabled"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"AlertEnabled"];
#endif

  
  [[NSUserDefaults standardUserDefaults]setObject:@"3" forKey:@"ENTITY_TYPE"];
  [[NSUserDefaults standardUserDefaults]setObject:m_Section.m_SectionId forKey:@"ID"];
  [[NSUserDefaults standardUserDefaults]setObject:m_Section.m_Name forKey:@"ENTITY_NAME"];
  
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
  UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Make sure your device has an active network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
  [pAlert show];
  pAlert=nil;          
  mPagingView.isEnabled=YES;
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
  mPagingView.isEnabled=YES;
  isReloading=YES;
  [self updateGraphValuesFromServer];
}

-(void)backAction
{
    GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
   
//    NSArray *pushControllers = [self.navigationController viewControllers];
//    NSLog(@"Push... Arry...Count :::: %d",[pushControllers count]);
//    if ([pushControllers count] == 2) 
//    {
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
  
  m_CameraScrollView.m_CameraView.m_deleagte=nil;
  m_WindView.m_delegate=nil;
  m_TotalEnergyView.m_delegate=nil;
  
  [m_CameraScrollView.m_CameraView cleanUp];
  
  [m_TopTileView removeFromSuperview];
  [m_AllTilesListView removeFromSuperview];
  [m_PowerVsDNIView removeFromSuperview];
  [m_TotalEnergyView removeFromSuperview];
  [m_WindView removeFromSuperview];
  [m_CameraScrollView removeFromSuperview];
  [mPagingView removeFromSuperview];
  mPagingView=nil;
  
  m_TopTileView=nil;
  m_AllTilesListView=nil;
  m_PowerVsDNIView=nil;
  m_TotalEnergyView=nil;
  m_WindView=nil;
  m_CameraScrollView=nil;
  
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
  
  
  if(m_Section.AlarmCount==0)
    [m_TopTileView setTopTileAlertImageName:@"Alert-Green.png"];
  else 
    [m_TopTileView setTopTileAlertImageName:@"Alert-red.png"];
  
  NSNumberFormatter *frmtr = [[NSNumberFormatter alloc] init];
  [frmtr setGroupingSize:3];
  [frmtr setGroupingSeparator:@","];
  [frmtr setUsesGroupingSeparator:YES];
  
  [m_TopTileView setTopTileDNI:[frmtr stringFromNumber:m_Section.m_CurrentDNI]];
  [m_TopTileView setTopTileTodayKWH:[frmtr stringFromNumber:m_Section.m_TodayEnergy]];
  [m_TopTileView setCurrentKWValue:m_Section.m_CurrentPower];

  NSString *temp;
  if(m_Section.m_Temperature != NULL)
  {
    float tempVal=[m_Section.m_Temperature floatValue];
    temp=[NSString stringWithFormat:@"%2.0f°C",tempVal];
  }
  else 
    temp=@"";
  
  if(m_Section.m_WeatherStatus != NULL)
  {
    NSString *pIconName=[NSString stringWithFormat:@"%@.png",m_Section.m_WeatherIcon];
    [m_TopTileView setTopTileWeatherImageName:pIconName];
    
    [m_TopTileView setTopTileWeatherDescription:[NSString stringWithFormat:@"   %@ %@",m_Section.m_WeatherStatus,temp]];
  }
  else 
    [m_TopTileView setTopTileWeatherDescription:@""];
  
  if(m_Section.m_WindDirection == NULL && m_Section.m_WindSpeed == NULL)
    [m_TopTileView setTopTileWindInfo:@""];
  else 
  {
    float windspeed=[m_Section.m_WindSpeed floatValue];
    [m_TopTileView setTopTileWindInfo:[NSString stringWithFormat:@"   %@ %2.1f m/s",m_Section.m_WindDirection,windspeed]];
  }
  
  [m_TopTileView setTopTileTime:[NSString stringWithFormat:@"%@",[DateTimeConverter getActualTimeStringFrom:m_Section.m_LocalDateTime]]];
  
  float scale=m_Section.ArrayCount*16;
  int range=ceil(scale/4.0);
  
  [m_TopTileView setTopTileValue1:[NSString stringWithFormat:@"%d",range*0]];
  [m_TopTileView setTopTileValue2:[NSString stringWithFormat:@"%d",range*1]];
  [m_TopTileView setTopTileValue3:[NSString stringWithFormat:@"%d",range*2]];
  [m_TopTileView setTopTileValue4:[NSString stringWithFormat:@"%d",range*3]];
  [m_TopTileView setTopTileValue5:[NSString stringWithFormat:@"%d",range*4]];
    
  if([m_Section.m_CurrentPower floatValue]<=scale/2)
  {
    float angle=((110.0)*([m_Section.m_CurrentPower floatValue]))/(scale/2);
    float rotationAngle=250.0+angle;
    [m_TopTileView setTopTilePowerProductionNeedleRotationAngle:((rotationAngle*0.0174532925))];      
  }
  else 
  {
    float angle=((110.0)*([m_Section.m_CurrentPower floatValue]-(scale/2)))/(scale/2);
    [m_TopTileView setTopTilePowerProductionNeedleRotationAngle:((angle*0.0174532925))];            
  }
  
  if([m_Section.m_CurrentDNI floatValue]<=600)
  {
    float angle=((110.0)*([m_Section.m_CurrentDNI floatValue]))/600.0;
    float rotationAngle=250.0+angle;
    [m_TopTileView setTopTilePowerVsDNINeedleRotationAngle:(rotationAngle*0.0174532925)];      
  }
  else 
  {
    float angle=((110.0)*([m_Section.m_CurrentDNI floatValue]-600.0))/600.0;
    [m_TopTileView setTopTilePowerVsDNINeedleRotationAngle:(angle*0.0174532925)];            
  }
    
  [m_TopTileView hideOperationMode:YES];
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

-(void)jsonParser_ParseArrayList:(NSData*)responseData
{
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse for GetArrayListforSectionResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetArrayListforSectionResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *rootResultDict=[rootResult objectAtIndex:0];
    
    NSObject *error=[rootResultDict objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {
      m_Section.totalCount=[[userResult objectForKey:@"TotalCount"] intValue];
      NSMutableArray *arrayArray=[NSMutableArray array];
      for(int i=0;i<[rootResult count];i++)
      {
        NSDictionary *siteDictinary=[rootResult objectAtIndex:i];
        Array *pArray=[[Array alloc]init];
        
        NSObject *pAlarmCount=[siteDictinary objectForKey:@"AlarmCount"];
        if(![pAlarmCount isKindOfClass:[NSNull class]])
          pArray.AlarmCount=[[siteDictinary objectForKey:@"AlarmCount"] intValue];
        
        NSObject *pArrayCount=[siteDictinary objectForKey:@"ArrayCount"];
        if(![pArrayCount isKindOfClass:[NSNull class]])
          pArray.ArrayCount=[[siteDictinary objectForKey:@"ArrayCount"] intValue];
        
        NSObject *pCameraID=[siteDictinary objectForKey:@"CameraID"];
        if(![pCameraID isKindOfClass:[NSNull class]])
          pArray.CameraID=[[siteDictinary objectForKey:@"CameraID"] intValue];                
        
        NSObject *pSiteId=[siteDictinary objectForKey:@"ID"];
        if(![pSiteId isKindOfClass:[NSNull class]])
          pArray.m_ArrayId=[siteDictinary objectForKey:@"ID"];      
        
        NSObject *pCurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
        if(![pCurrentDNI isKindOfClass:[NSNull class]])
          pArray.m_CurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
        
        NSObject *pCurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
        if(![pCurrentPower isKindOfClass:[NSNull class]])
          pArray.m_CurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
        
        NSObject *pLocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
        if(![pLocalDateTime isKindOfClass:[NSNull class]])
          pArray.m_LocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
        
        NSObject *pLocation=[siteDictinary objectForKey:@"Location"];
        if(![pLocation isKindOfClass:[NSNull class]])
          pArray.m_Location=[siteDictinary objectForKey:@"Location"];
        
        NSObject *pName=[siteDictinary objectForKey:@"Name"];
        if(![pName isKindOfClass:[NSNull class]])
          pArray.m_Name=[siteDictinary objectForKey:@"Name"];
        
        NSObject *pTemperature=[siteDictinary objectForKey:@"Temperature"];
        if(![pTemperature isKindOfClass:[NSNull class]])
          pArray.m_Temperature=[[siteDictinary objectForKey:@"Temperature"] stringValue];
        
        NSString *pWindDirection=(NSString *)[siteDictinary objectForKey:@"WindDirection"];
        if(![pWindDirection isEqualToString:@""])
          pArray.m_WindDirection=[siteDictinary objectForKey:@"WindDirection"];
        
        NSObject *pWindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        if(![pWindSpeed isKindOfClass:[NSNull class]])
          pArray.m_WindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
        
        NSObject *pTodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
        if(![pTodayEnergy isKindOfClass:[NSNull class]])
          pArray.m_TodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
        
        NSObject *pUTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
        if(![pUTCDateTime isKindOfClass:[NSNull class]])
          pArray.m_UTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
        
        NSObject *pUTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
        if(![pUTCOffset isKindOfClass:[NSNull class]])
          pArray.m_UTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
        
        NSObject *pWeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
        if(![pWeatherStatus isKindOfClass:[NSNull class]])
          pArray.m_WeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
        
        NSObject *pWeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];
        if(![pWeatherIcon isKindOfClass:[NSNull class]])
          pArray.m_WeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];                
        
        NSObject *pYTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
        if(![pYTDEnergy isKindOfClass:[NSNull class]])
          pArray.m_YTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
        
        [arrayArray addObject:pArray];
        pArray=nil;
      }
      m_Section.m_arrayArray=[NSArray arrayWithArray:arrayArray];
      arrayArray=nil;
      [[NSUserDefaults standardUserDefaults]setObject:@"section" forKey:@"BACK_BUTTON"];
      [m_AllTilesListView fillScrollViewWithArray:m_Section.m_arrayArray];
    }
    else 
    {
      NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
      if([errorId intValue]==10002 || [errorId intValue]==10026 || [errorId intValue]==10028 || [errorId intValue]==10029)
      {
        [[LoginManager sharedLoginManagerWithDelegate:self] ShowLoginPage];
      }
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

-(void)jsonParser_parseSectionDetails:(NSData*)responseData
{  
  NSMutableArray *sectionDetailArray=[[NSMutableArray alloc]init];
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse for GetDetailedSectionInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetDetailedSectionInfoResult"]; 
  
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
        
        [sectionDetailArray addObject:pEntityDetails];

        pEntityDetails=nil;
      }
      
        [m_PowerVsDNIView fillValuesFrom:sectionDetailArray andArrayCount:m_Section.ArrayCount];
        [m_WindView fillValuesFrom:sectionDetailArray];
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
        [m_WindView fillValuesFrom:sectionDetailArray];
    }
  }  
}

-(void)jsonParser_parseToatlEnergy:(NSData*)responseData
{ 
  NSMutableArray *energyInfoArray=[[NSMutableArray alloc]init];
  NSString *responseString=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
  
  //printf("\nResponse for GetDailySectionInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetDailySectionInfoResult"]; 
  
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
  
  //printf("\nResponse for GetCurrentSectionInfoResult:\n%s\n",[responseString UTF8String]);
  
  NSDictionary *data=[responseString JSONValue];
  
  NSDictionary *userResult= [data objectForKey:@"GetCurrentSectionInfoResult"]; 
  
  NSArray *rootResult = [userResult objectForKey:@"RootResults"];
  
  if([rootResult count])
  {
    NSDictionary *siteDictinary=[rootResult objectAtIndex:0];
    
    NSObject *error=[siteDictinary objectForKey:@"Err"];
    
    if([error isKindOfClass:[NSNull class]])
    {      
      NSObject *pAlarmCount=[siteDictinary objectForKey:@"AlarmCount"];
      if(![pAlarmCount isKindOfClass:[NSNull class]])
        m_Section.AlarmCount=[[siteDictinary objectForKey:@"AlarmCount"] intValue];
      
      NSObject *pArrayCount=[siteDictinary objectForKey:@"ArrayCount"];
      if(![pArrayCount isKindOfClass:[NSNull class]])
        m_Section.ArrayCount=[[siteDictinary objectForKey:@"ArrayCount"] intValue];
      
      NSObject *pCameraID=[siteDictinary objectForKey:@"CameraID"];
      if(![pCameraID isKindOfClass:[NSNull class]])
        m_Section.CameraID=[[siteDictinary objectForKey:@"CameraID"] intValue];
      
      NSObject *pSiteId=[siteDictinary objectForKey:@"ID"];
      if(![pSiteId isKindOfClass:[NSNull class]])
        m_Section.m_SectionId=[siteDictinary objectForKey:@"ID"];      
      
      NSObject *pCurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
      if(![pCurrentDNI isKindOfClass:[NSNull class]])
        m_Section.m_CurrentDNI=[siteDictinary objectForKey:@"CurrentDNI"];
      
      NSObject *pCurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
      if(![pCurrentPower isKindOfClass:[NSNull class]])
        m_Section.m_CurrentPower=[siteDictinary objectForKey:@"CurrentPower"];
      
      NSObject *pLocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
      if(![pLocalDateTime isKindOfClass:[NSNull class]])
        m_Section.m_LocalDateTime=[siteDictinary objectForKey:@"LocalDateTime"];
      
      NSObject *pLocation=[siteDictinary objectForKey:@"Location"];
      if(![pLocation isKindOfClass:[NSNull class]])
        m_Section.m_Location=[siteDictinary objectForKey:@"Location"];
      
      NSObject *pName=[siteDictinary objectForKey:@"Name"];
      if(![pName isKindOfClass:[NSNull class]])
        m_Section.m_Name=[siteDictinary objectForKey:@"Name"];
      
      NSObject *pTemperature=[siteDictinary objectForKey:@"Temperature"];
      if(![pTemperature isKindOfClass:[NSNull class]])
        m_Section.m_Temperature=[[siteDictinary objectForKey:@"Temperature"] stringValue];
      
      NSString *pWindDirection=(NSString *)[siteDictinary objectForKey:@"WindDirection"];
      if(![pWindDirection isEqualToString:@""])
        m_Section.m_WindDirection=[siteDictinary objectForKey:@"WindDirection"];
      
      NSObject *pWindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
      if(![pWindSpeed isKindOfClass:[NSNull class]])
        m_Section.m_WindSpeed=[siteDictinary objectForKey:@"WindSpeed"];
      
      NSObject *pTodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
      if(![pTodayEnergy isKindOfClass:[NSNull class]])
        m_Section.m_TodayEnergy=[siteDictinary objectForKey:@"TodayEnergy"];
      
      NSObject *pUTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
      if(![pUTCDateTime isKindOfClass:[NSNull class]])
        m_Section.m_UTCDateTime=[siteDictinary objectForKey:@"UTCDateTime"];
      
      NSObject *pUTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
      if(![pUTCOffset isKindOfClass:[NSNull class]])
        m_Section.m_UTCOffset=[siteDictinary objectForKey:@"UTCOffset"];
      
      NSObject *pWeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
      if(![pWeatherStatus isKindOfClass:[NSNull class]])
        m_Section.m_WeatherStatus=[siteDictinary objectForKey:@"WeatherStatus"];
      
      NSObject *pWeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];
      if(![pWeatherIcon isKindOfClass:[NSNull class]])
        m_Section.m_WeatherIcon=[siteDictinary objectForKey:@"WeatherIcon"];
      
      NSObject *pYTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
      if(![pYTDEnergy isKindOfClass:[NSNull class]])
        m_Section.m_YTDEnergy=[siteDictinary objectForKey:@"YTDEnergy"];
      
      [self addTopTileView];
    }
    else 
    {
      NSNumber *errorId=[siteDictinary objectForKey:@"ErrID"];
      if(![[NSUserDefaults standardUserDefaults]boolForKey:@"ERROR"])
      {
        if([errorId intValue]!=10003)
        {
          UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:[siteDictinary objectForKey:@"Err"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
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

#pragma mark LoginManagerDelegate methods
-(void)loginManager:(LoginManager*)manager loggedInSuccesfullyWithSessionToken:(NSString*)sessionToken
{
  [self.navigationController popToRootViewControllerAnimated:YES];  
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
  
  [[SliderManager SharedSliderManager] handleSlider:m_Slider andIsDailyGraph:bGraphTypeDaily withRespectToObject:m_Section];
  
  [self updateGraphValuesFromServer];
}

#pragma mark AllTilesListViewDelegate methods

-(void)ClickedTileWithIndex:(int)index
{
  if(mConnection){mConnection.m_delegate=nil;mConnection=nil;}
  
  [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"DATECHANGED"];
  [[NSUserDefaults standardUserDefaults]setObject:@"section" forKey:@"BACK_BUTTON"];
  
  Array *pArray=[m_Section.m_arrayArray objectAtIndex:index];
  
  if(mDataPrefetcher)
  {
    mDataPrefetcher.delegate=nil;
    [mDataPrefetcher CancelConnection];
    mDataPrefetcher=nil;
  }
  mDataPrefetcher=[[DataPrefetcher alloc]init];
  mDataPrefetcher.delegate=self;
  [mDataPrefetcher GetClassToBeJumpedFrom:pArray];
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
  
  m_ActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(145, 180, 30, 30)];
  [m_ActivityIndicatorView startAnimating];
  m_ActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
  [self.view addSubview:m_ActivityIndicatorView]; 
}
-(void)dataPrefetcher:(DataPrefetcher*)dataPrefetcher decidedToJumpToObject:(NSObject*)object
{
     GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
  isGoingToNextLevel=YES;
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}


  if(mDataPrefetcher)
  {
    mDataPrefetcher.delegate=nil;
    [mDataPrefetcher CancelConnection];
    mDataPrefetcher=nil;
  }
  
  [m_Backbutton removeFromSuperview];
  if([object isKindOfClass:[Array class]])
  {
    ArrayViewController *mArrayViewController=[[ArrayViewController alloc]initWithArray:(Array*)object];
    [self.navigationController pushViewController:mArrayViewController animated:YES];
      [appDelegate pushservicebackbutton];
//      //pushing in control level
//      ControlViewController *arraytViewController=[ControlViewController alloc];
//      [self.navigationController pushViewController:arraytViewController animated:YES];
        
     
  }
  else if([object isKindOfClass:[String class]])
  {
    StringViewController *mStringViewController=[[StringViewController alloc]initWithString:(String*)object];
    [self.navigationController pushViewController:mStringViewController animated:YES];
      [appDelegate pushservicebackbutton];
//      //pushing in control level
//      ControlViewController *stringViewController=[ControlViewController alloc];
//      [self.navigationController pushViewController:stringViewController animated:YES];
  }
  m_Section.m_arrayArray=nil;
}
-(void)dataPrefetcherFoundMissingToken:(DataPrefetcher *)dataPrefetcher
{
  if(mDataPrefetcher)
  {
    mDataPrefetcher.delegate=nil;
    [mDataPrefetcher CancelConnection];
    mDataPrefetcher=nil;
  }
  
  [self fetchSessionToken];
}

-(void)dataPrefetcherFoundInternetError:(DataPrefetcher *)dataPrefetcher
{
  if(mDataPrefetcher)
  {
    mDataPrefetcher.delegate=nil;
    [mDataPrefetcher CancelConnection];
    mDataPrefetcher=nil;
  }
  
  if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
  
  UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Make sure your device has an active network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
  [pAlert show];
  pAlert=nil;        
  
  if(isReloading)
    isReloading=NO;
  
}

#pragma mark -- PagingViewDataSource
-(NSInteger)pagingViewNoOfPages:(PagingView*)pagingView
{
  return 5;
}
-(UIView*)pagingView:(PagingView*)pagingView viewForPage:(NSInteger)page
{
  UIView *view=nil;
  switch (page) {
    case 0:
      view=m_AllTilesListView;
      break;
    case 1:
      view=m_PowerVsDNIView;
      break;
    case 2:
      view=m_TotalEnergyView;
      break;
    case 3:
      view=m_WindView;
      break;
    case 4:
      view=m_CameraScrollView;
      break;
    default:
      break;
  }
  return view;
}
#pragma mark -- PagingViewDelegate
-(void)pagingView:(PagingView*)pagingView didDisplayPage:(NSInteger)page
{
  {
    switch (page) 
    {
      case 0:
      {
        m_Slider.hidden=YES;
        m_CameraScrollView.m_CameraView.isVisible=NO;
        m_TitleLabel.text=@"Array View";
      }
        break;
      case 1:
      {
        m_Slider.hidden=NO;
        m_CameraScrollView.m_CameraView.isVisible=NO;
        m_TitleLabel.text=@"Power vs. DNI";
      }
        break;
      case 2:
      {
        m_Slider.hidden=NO;
        m_CameraScrollView.m_CameraView.isVisible=NO;
        m_TitleLabel.text=totalEnergyTitle;
      }
        break;
      case 3:
      {
        m_Slider.hidden=NO;
        m_CameraScrollView.m_CameraView.isVisible=NO;
        m_TitleLabel.text=@"Wind";
      }
        break;
      case 4:
      {
        m_Slider.hidden=YES;
        m_CameraScrollView.m_CameraView.isVisible=YES;
        m_TitleLabel.text=@"Camera";
      }
        break;
      default:
        break;
    }
    if(page==0)
    {
      m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBGBlank.png"];
    }
    else 
    {
      m_BackgroundImageView.image=[UIImage imageNamed:@"SecondViewBG.png"];
    }
    
    [self updateSlider];
  }
}
@end