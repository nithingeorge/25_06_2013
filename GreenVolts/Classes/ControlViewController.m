    //
//  ControlViewController.m
//  GreenVolts
//
//  Created by YML on 8/26/11.
//  Copyright 2011 YML. All rights reserved.
//

#import "ControlViewController.h"
#import "UITabBarItem+AFECustom.h"
#import "ControlView.h"
#import "MaintenanceLogView.h"
#import "GreenVoltsAppDelegate.h"

#define ARRAY_FOR_TAB_BUTTONS [NSArray arrayWithObjects:@"Control", @"Maintenance Plan",@"Maintenance Log",nil]

@interface ControlViewController()
{
    NSNumber *maintenancePlanId;
    NSString *maintenancePlanLocation,*maintenancePlanAction,*maintenancePlanComponentType,*maintenancePlannotes;
    
}

@property(nonatomic, strong) NSString *operationPerformed;
@property (nonatomic,strong)NSMutableArray *tabPageButtonsCollection;

- (void)valueChanged:(id)sender;

- (void) createPageTabsWithArray:(NSMutableArray *)tabButtonArray;

@end
//UIView *controlview;
UISegmentedControl *segmentedControl;
ControlView *controlview;
MaintenancePlanView *maintenanceplanview;
MaintenanceLogView *maintenancelogview;

@implementation ControlViewController

@synthesize operationPerformed;
@synthesize tabPageButtonsCollection;

-(id)init 
{
  if((self = [super init]))
  {
      self.title=[[NSUserDefaults standardUserDefaults]objectForKey:@"ENTITY_NAME"];
      m_Backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
      m_Backbutton.frame=CGRectMake(5, 8, 72, 30);
      [m_Backbutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[[NSUserDefaults standardUserDefaults]objectForKey:@"BACK_BUTTON"] ofType:@"png"]] forState:UIControlStateNormal];
      [m_Backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
      // [self.navigationController.navigationBar addSubview:m_Backbutton];
      self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:m_Backbutton];
    //  pTitleLabel=nil;
      self.tabBarItem.title = @"Service";
      self.tabBarItem.selectedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Control" ofType:@"png"]];
      self.tabBarItem.unselectedImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ControlDull" ofType:@"png"]];
      
      
  }
  return self;
}

- (void)dealloc 
{
  if(pTitleLabel)
  {
      //pTitleLabel=nil;
  }
}


-(void)loadView
{
    self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view.backgroundColor=[UIColor colorWithRed:(10.6/100.0) green:(13.3/100.0) blue:(13.7/100.0) alpha:1.0];
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    NSString *backbutton=[[NSUserDefaults standardUserDefaults]objectForKey:@"BACK_BUTTON"];
    NSLog(@"btn title:%@",backbutton);

    [self createPageTabsWithArray:ARRAY_FOR_TAB_BUTTONS];
    
}


-(void)backAction
{
    
    GreenVoltsAppDelegate *appDelegate = (GreenVoltsAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[self  createControlViewControllers];
   // [m_Backbutton removeFromSuperview];
    NSLog(@"%d",[self.navigationController.viewControllers count]);
    if ([self.navigationController.viewControllers count]>2) 
    {
        [self.navigationController  popViewControllerAnimated:YES];
        [appDelegate popdashboardbackbutton];

    }
    else 
    {
       // self.tabBarController.selectedIndex=0;
        [appDelegate popdashboardbackbutton];
        [appDelegate creatingTwoTabBarControllers];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
   // [m_Backbutton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[[NSUserDefaults standardUserDefaults]objectForKey:@"BACK_BUTTON"] ofType:@"png"]] forState:UIControlStateNormal];
        
    }

#pragma mark-tabpagecreationmethods

- (void) createPageTabsWithArray:(NSMutableArray *)tabButtonArray

{
     
    UIImageView *tempTopPageTabsHolder = (UIImageView *)[self.view viewWithTag:5214];//adding an imageview with given tab image
   
   if (tempTopPageTabsHolder)
    {
        [tempTopPageTabsHolder removeFromSuperview];
        [tempTopPageTabsHolder.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
        tempTopPageTabsHolder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_nav_black_slice.png"]];

    tempTopPageTabsHolder.userInteractionEnabled = YES;
    tempTopPageTabsHolder.tag = 5214;
    tempTopPageTabsHolder.backgroundColor = [UIColor clearColor];
    [tempTopPageTabsHolder setFrame:CGRectMake(0, 0, 360, 38)];
    
    [self.view addSubview:tempTopPageTabsHolder];
     
    int tempX = 0;
    
    UIButton *tempPageButton;
    
    UIImageView *tempButtonSeperator;
    
     if(self.tabPageButtonsCollection) 
       {
           if ([self.tabPageButtonsCollection count]) 
               [self.tabPageButtonsCollection removeAllObjects];

       }
     else
     {
         self.tabPageButtonsCollection = [[NSMutableArray alloc] init]; 
     }

   for(int i =0; i <[tabButtonArray count]; i++)
      {
        tempPageButton = [[UIButton alloc] initWithFrame:CGRectMake(tempX, 0, 110, 38)];  //creating buttons from default array
        
        tempPageButton.tag = i;
        
          CGRect myButtonRect = tempPageButton.bounds;
          
          if (i == 0)
              myButtonRect.origin.x  = myButtonRect.origin.x + 30;
          else 
              myButtonRect.origin.x  = myButtonRect.origin.x + 5;
              
          UILabel *myLabel = [[UILabel alloc] initWithFrame: myButtonRect];   
          myLabel.text = [tabButtonArray objectAtIndex:i];
          myLabel.backgroundColor = [UIColor clearColor];
          myLabel.textColor = [UIColor whiteColor]; 
          myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];   
          myLabel.textAlignment = UITextAlignmentLeft;
          [tempPageButton addSubview:myLabel];
          
        tempPageButton.backgroundColor = [UIColor clearColor];
        
        [tempPageButton addTarget:self action:@selector(tabPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
       
        [self.tabPageButtonsCollection addObject:tempPageButton];
       
        [tempTopPageTabsHolder addSubview:tempPageButton];                  //adding buttons to the tab image view
        
        
        
        tempButtonSeperator = [[UIImageView alloc] initWithFrame:CGRectMake(tempX-2, 0,2,38)];
        
        [tempButtonSeperator setImage:[UIImage imageNamed:@"top_nav_segcntrl_vertical separator.png"]];  
                                                                           //adding seperator image between buttons
        [self.view addSubview:tempButtonSeperator];
        
        tempX += 110;
        
          if(i == [tabButtonArray count]-1)
            
            {
              tempButtonSeperator = [[UIImageView alloc] initWithFrame:CGRectMake(tempX-2, 0,2,38)];
            
              [tempButtonSeperator setImage:[UIImage imageNamed:@"top_nav_segcntrl_vertical separator.png"]];
            
              [self.view addSubview:tempButtonSeperator];
            }
     
      }
    //default selection will go here
    NSNumber *tabIndex=[[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedControlTab"];
    if (tabIndex==nil) 
        tabIndex = 0;
    [self tabPageButtonClicked:[self.tabPageButtonsCollection objectAtIndex:[tabIndex intValue]]];

}

#pragma mark- Button Action

- (void)loadcontrolview
{
    NSNumber *tabButtonTag=0;
    [[NSUserDefaults standardUserDefaults] setObject:tabButtonTag forKey:@"SelectedControlTab"];
    NSLog(@"control");
    [maintenanceplanview removeFromSuperview];
    [maintenancelogview removeFromSuperview]; 
    maintenanceplanview=nil;
    //maintenancelogview=nil;
    if(!controlview)
    {
        controlview=[[ControlView alloc]initWithFrame:CGRectMake(0, 30, 310, 460)]; //view for control level
    }   
    [self.view addSubview:controlview];
    
}

- (void)loadmaintenanceplanview
{
    NSNumber *tabButtonTag=[NSNumber numberWithInt:1];
    [[NSUserDefaults standardUserDefaults] setObject:tabButtonTag forKey:@"SelectedControlTab"];
    
    NSLog(@"plan");
    [controlview removeFromSuperview];
    [maintenancelogview removeFromSuperview];
    controlview=nil;
    maintenancelogview=nil;
    if(!maintenanceplanview)
    {
        maintenanceplanview=[[MaintenancePlanView alloc]initWithFrame:CGRectMake(0, 40, 310, 460)]; 
        maintenanceplanview.delegate = self;
    }
    [self.view addSubview:maintenanceplanview];
    
}

- (void)loadmaintenancelogview
{
    NSNumber *tabButtonTag=[NSNumber numberWithInt:2];
    [[NSUserDefaults standardUserDefaults] setObject:tabButtonTag forKey:@"SelectedControlTab"];
    NSLog(@"log");
    [maintenanceplanview removeFromSuperview];
    [controlview removeFromSuperview];
    //maintenanceplanview=nil;
    controlview=nil;
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"islog_button_pressed"])
    {
        maintenancePlanId=nil;
        maintenancePlanLocation=nil;
        maintenancePlanAction=nil;
        maintenancePlanComponentType=nil;
        maintenancePlannotes=nil;
    }
    
    if(!maintenancelogview)
    {
        maintenancelogview=[[MaintenanceLogView alloc]initWithFrame:CGRectMake(0, 40, 310, 460)];
        maintenancelogview.iD=maintenancePlanId;
        maintenancelogview.location=maintenancePlanLocation;
        maintenancelogview.maintenanceAction=maintenancePlanAction;
        maintenancelogview.componentType=maintenancePlanComponentType;
        maintenancelogview.notes=maintenancePlannotes;
    }
   
[self.view addSubview:maintenancelogview];
    
}

- (void)tabPageButtonClicked:(id)sender
{
  
    NSLog(@"control touch");
    
   UIButton *buttonClicked = (UIButton*) sender;                   //switching to different views on button click
    
        switch (buttonClicked.tag)
        {    
            case 0:
            {
                
                [self loadcontrolview];             
                buttonClicked.userInteractionEnabled = NO;
            }
            break;
                
            case 1:
            {    
               
                [self loadmaintenanceplanview]; 
                buttonClicked.userInteractionEnabled = YES;
            }
            break;
            case 2:
            {
                
                [self loadmaintenancelogview];
                buttonClicked.userInteractionEnabled = YES;
            }
            break;

            default:
                break;
                
        }
 
        //makes the selected button green
    
        for(int i =0 ; i<[self.tabPageButtonsCollection count]; i++)
        {
            UIButton *btnInArray = [tabPageButtonsCollection objectAtIndex:i];
            
            if(btnInArray == buttonClicked) 
            {
                [((UIButton*)[self.tabPageButtonsCollection objectAtIndex:i]) setBackgroundImage:[UIImage imageNamed: @"top_nav_segcntrl_green_slice.png"] forState:UIControlStateNormal];
                
                [((UIButton*)[self.tabPageButtonsCollection objectAtIndex:i]) setBackgroundImage:[UIImage imageNamed: 	@"top_nav_segcntrl_green_slice.png"] forState:UIControlStateHighlighted];
                
                [((UIButton*)[self.tabPageButtonsCollection objectAtIndex:i]) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btnInArray.userInteractionEnabled=NO;
                
            }
            else
            {
                [((UIButton*)[self.tabPageButtonsCollection objectAtIndex:i]) setBackgroundImage:nil  forState:UIControlStateNormal];
                
                
                [((UIButton*)[self.tabPageButtonsCollection objectAtIndex:i]) setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.698] forState:UIControlStateNormal];
                
                btnInArray.userInteractionEnabled=YES;
                
            } 
        }    
        
}


#pragma mark-initial methods

-(void)viewWillAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"islog_button_pressed"];   
    pTitleLabel.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"ENTITY_NAME"];
    [self loadView];
}

- (void)didReceiveMemoryWarning 
{
    
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - LogButton Delegates
 
//switching tab on log button click in plan view

- (void)planViewlogbuttontouchedWithLocation:(NSString *)location maintenancePlanID:(NSNumber *)iD task:(NSString *)task component:(NSString *)component notes:(NSString*)notes
{ 
    
    maintenancePlanId=iD;
    maintenancePlanLocation=location;
    maintenancePlanAction=task;
    maintenancePlanComponentType=component;
    maintenancePlannotes=notes;
    UIButton *tempButton=[self.tabPageButtonsCollection objectAtIndex:2];
    [self tabPageButtonClicked:tempButton];

}
@end
