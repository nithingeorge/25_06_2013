//
//  AlertViewController.h
//  GreenVolts
//
//  Created by YML on 8/26/11.
//  Copyright 2011 YML. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Connection.h"

@interface AlertViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
  UITableView *m_TableView;
  UILabel *pTitleLabel;
  NSArray *m_AlertsArray;
  NSURLConnection *mURLConnection;
  NSURLConnection *mURLConnection_AlarmCount;

  NSMutableData *mResponseData;
  UIActivityIndicatorView *m_ActivityIndicatorView;
  Connection *m_Connection;
}

-(void)gotoSectionAlertView;
-(void)gotoArrayAlertView;
@end
