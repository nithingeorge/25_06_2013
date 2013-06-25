//
//  GreenVoltsAppDelegate.h
//  GreenVolts
//
//  Created by YML on 8/26/11.
//  Copyright 2011 YML. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccelerometerObserver.h"
#import "PortfolioViewController.h"
#import "ControlViewController.h"
#import "AlertViewController.h"
#import "LoginManager.h"
#import "RootViewController.h"
#import "CommonClasses/NSData+GVBlowfish.h"


@interface GreenVoltsAppDelegate : NSObject <UIApplicationDelegate,UINavigationControllerDelegate,UITabBarControllerDelegate,LoginManagerDelegate> 
{
  UIWindow *window;
 
  RootViewController* m_rootViewController;
  
  NSURLConnection *mURLConnection;
  NSMutableData *mResponseData;  
  UIActivityIndicatorView *m_ActivityIndicatorView;  
  AccelerometerObserver *mAccelerometerObserver;
  NSTimer *mTimer;
  BOOL isShekeAllowed;
  NSMutableArray *pnavigArray;

  UINavigationController *m_NavigationController;
  UITabBarController *m_TabBarController;
  UINavigationController * dashboardNavController;
  UINavigationController * controlNavController;
  UINavigationController * alertsNavController;
  PortfolioViewController *m_PortfolioViewController;
  ControlViewController *m_ControlViewController;
  AlertViewController *m_AlertViewController;
    
     
  UIButton *pDashboardButton;
  UIButton *pControlButton;
  UIButton *pAlertButton;
}
@property(strong,nonatomic,readonly)UIViewController *RootViewController;
@property(nonatomic,strong)UIWindow *window;

;
-(void)creatingThreeTabBarControllers;
- (void)creatingTwoTabBarControllers;
-(void) disableTabbarControlAtBottomFully;
-(void) enableTabbarControlAtBottomAsPerEntity;
- (void)setTabTabBarBadge:(int)badgeValue;
-(void)pushservicebackbutton;
-(void)popservicebackbutton;
-(void)popdashboardbackbutton;

@end

