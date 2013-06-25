//
//  MaintenancePlanView.m
//  GreenVolts
//
//  Created by Shinu Mohan on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancePlanView.h"
#import "MaintenancePlan.h"


@interface MaintenancePlanView()

-(void)connectToServer:(NSString *)pURLString;
-(void)jsonParser;
-(void)getMaintenancePlan;
-(void)handleException:(int)errorCode andAdditionalMessage:(NSString*)message;
-(void)fetchSessionToken;
- (void)showPlanDetailView:(int)value;
@end

MaintenancePlanDetailView *maintenancePlanDetailView;

@implementation MaintenancePlanView

@synthesize maintenancePlanArray;
@synthesize maintenancePlanCell;
@synthesize delegate;

#pragma mark-initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        [self loadview];
        // Initialization code
    }
    return self;
}

#pragma mark-load views

-(void) loadview
{
    maintenaceTable = [[UITableView alloc] initWithFrame: CGRectMake(0,0,320,330) style:UITableViewStylePlain];
	maintenaceTable.delegate = self;
	maintenaceTable.dataSource = self;
    maintenaceTable.backgroundColor=[UIColor colorWithRed:31/255.0f green:41/255.0f blue:58/255.0f alpha:1];
   // maintenaceTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    maintenaceTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [maintenaceTable setSeparatorColor:[UIColor colorWithRed:40/255.0f green:48/255.0f blue:64/255.0f alpha:1]];
	[self addSubview:maintenaceTable]; 
    
    [self getMaintenancePlan];
    
}

#pragma  mark- Tableview DataSource/Delegate Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Array Count ::: %d",[maintenancePlanArray count]);
    
    int rowCount = maintenancePlanArray? [maintenancePlanArray count]:0;
    
    if(rowCount < 8)
        rowCount = 8;
    
    return rowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    MaintenancePlanCell *maintenanceCell = (MaintenancePlanCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (maintenanceCell == nil) 
    {
      [[NSBundle mainBundle] loadNibNamed:@"MaintenancePlanCell" owner:self options:nil];
        maintenanceCell = maintenancePlanCell;
        self.maintenancePlanCell = nil;
    }
    
    if (maintenancePlanArray && [maintenancePlanArray count] > indexPath.row) 
    {
        [maintenanceCell displayDetails:[maintenancePlanArray objectAtIndex:indexPath.row] rowValue:indexPath.row];  
        [maintenanceCell unHideAllUIElements];
    }
    else 
    {
        [maintenanceCell hideAllUIElements];
    }
    
    maintenancePlanCell.selectionStyle = UITableViewCellSelectionStyleNone; 
    maintenanceCell.accessoryView.backgroundColor=[UIColor clearColor];
    return maintenanceCell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    [self showPlanDetailView:indexPath.row];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"navpopover_cell_backround (2)"]];
    cell.textLabel.textColor=[UIColor whiteColor];
}

- (void)showPlanDetailView:(int)value
{
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"islog_button_pressed"]; 
    if(value < maintenancePlanArray.count)
    {
        //if (!maintenancePlanDetailView) 
        //{
        maintenancePlanDetailView=[[MaintenancePlanDetailView alloc]initWithFrame:CGRectMake(0, 0, 310, 460)]; 
        maintenancePlanDetailView.backgroundColor = [UIColor lightGrayColor];
        maintenancePlanDetailView.delegate = self;
        maintenancePlanDetailView.maintenancePlan=[self.maintenancePlanArray objectAtIndex:value];
        //}
        //CGRect newRect = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height);
        maintenancePlanDetailView.frame = self.frame;
        
        //maintenancePlanDetailView.center = CGPointMake(self.center.x + CGRectGetWidth(self.frame), 20);
        NSLog(@"FRAME %@",NSStringFromCGRect(maintenancePlanDetailView.frame));
        [self addSubview: maintenancePlanDetailView];
        [self animateview];
        
    }
}

#pragma mark-animations

-(void)animateview
{
    // Animate the push
    CGRect oldRect = maintenancePlanDetailView.frame;
    oldRect.origin.x = oldRect.origin.x + maintenancePlanDetailView.frame.size.width;
    oldRect.origin.y = maintenaceTable.frame.origin.y;
    maintenancePlanDetailView.frame = oldRect;
    
    [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
     ^{
         CGRect newRect = maintenancePlanDetailView.frame;
         newRect.origin.x = newRect.origin.x - maintenancePlanDetailView.frame.size.width;
         maintenancePlanDetailView.frame = newRect;
         
     } completion:^(BOOL finished) {
         
     }];
  
}


#pragma mark-  Button Touch Methods
-(void)planDetailViewlogbuttontouchedWithLocation:(NSString *)location maintenancePlanID:(NSNumber *)iD task:(NSString *)task component:(NSString *)component notes:(NSString*)notes
{
    
    if (maintenancePlanDetailView)
    {
        [maintenancePlanDetailView removeFromSuperview];
    }
   
    maintenancePlanDetailView=nil;
    if(self.delegate && [self.delegate respondsToSelector:@selector(planViewlogbuttontouchedWithLocation:maintenancePlanID:task:component:notes:)])
        [delegate planViewlogbuttontouchedWithLocation:location maintenancePlanID:iD task:task component:component notes:notes];

}

- (IBAction)accessoryButtonTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    [self showPlanDetailView:button.tag];
}
#pragma mark-connection methods

-(void)getMaintenancePlan
{
    NSString *pSessionToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"SESSION_TOKEN"];
    NSString *pEntityId=[[NSUserDefaults standardUserDefaults]objectForKey:@"ID"];
    NSString *pSiteId=[[NSUserDefaults standardUserDefaults] objectForKey:@"SITE_ID"];
    NSString *pEntityScope=[[NSUserDefaults standardUserDefaults]objectForKey:@"ENTITY_TYPE"];
    NSString *pOwnerId=@"null";
    NSString *completed=@"true";
    NSString *pComponentTypeId=@"null";
    NSString *pMaintenancePlanTypeID=@"null";

    urlString=[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetMaintenancePlans?sessionToken=%@&siteID=%@&entityScope=%@&entityID=%@&maintenancePlanTypeID=%@&ownerID=%@&completed=%@&componentTypeID=%@",kserverAddress,pSessionToken,pSiteId,pEntityScope,pEntityId,pMaintenancePlanTypeID,pOwnerId,completed,pComponentTypeId];
    [self connectToServer:urlString];

}



-(void)connectToServer:(NSString *)pURLString
{
    urlString=nil;
    urlString=[pURLString copy];
    if(m_ActivityIndicatorView)
    {
        [m_ActivityIndicatorView removeFromSuperview];
        m_ActivityIndicatorView=nil;
    }
    m_ActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
    [m_ActivityIndicatorView startAnimating];
    m_ActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    [self addSubview:m_ActivityIndicatorView];  
    
	if(mURLConnection) 
	{
		[mURLConnection cancel];
		mURLConnection=nil;
	}
    if(mResponseData)
	{
		mResponseData=nil;
	}
    
    NSLog(@"URL REQ");
    
	mURLConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pURLString]] delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    if(!mResponseData)
        mResponseData=[NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [mResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
    
    UIAlertView *pAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"Make sure your device has an active network connection and try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:NULL];
    [pAlert show];
    pAlert=nil;        
    
    if(mURLConnection) 
	{
		[mURLConnection cancel];
		mURLConnection=nil;
	}
	if(mResponseData)
	{
		mResponseData=nil;
	}
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if(mURLConnection) 
	{
		[mURLConnection cancel];
		mURLConnection=nil;
	}
    if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
    [self jsonParser];
}	

-(void)jsonParser
{
    self.maintenancePlanArray=[[NSMutableArray alloc] init];
    NSString *responseString=[[NSString alloc]initWithData:mResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON Request::::::\n%@",urlString);
    NSLog(@"JSON Response:::::\n%@",responseString);
    mResponseData=nil;
    
    NSDictionary *data=[responseString JSONValue];
    NSDictionary *maintenancePlanResult=[data objectForKey:@"GetMaintenancePlansResult"];
    NSArray *rootResult=[maintenancePlanResult objectForKey:@"RootResults"];
    
    if (rootResult) 
    {
        if ([rootResult count])
        {
            for (int i=0; i<[rootResult count]; i++) 
            {
                NSDictionary *rootResultDict=[rootResult objectAtIndex:i]; 
                NSObject *error=[rootResultDict objectForKey:@"Err"];
                
                if([error isKindOfClass:[NSNull class]])
                {
                    MaintenancePlan *maintenancePlan=[[MaintenancePlan alloc] init];
                    maintenancePlan.iD=[rootResultDict objectForKey:@"ID"];
                    maintenancePlan.componentType=[rootResultDict objectForKey:@"ComponentType"];
                    maintenancePlan.dateTimeLocal=[rootResultDict objectForKey:@"DateTimeLocal"];
                    maintenancePlan.eventalertId=[rootResultDict objectForKey:@"EventAlertID"];
                    maintenancePlan.iD=[rootResultDict objectForKey:@"ID"];
                    maintenancePlan.location=[rootResultDict objectForKey:@"Location"];
                    maintenancePlan.maintenanceAction=[rootResultDict objectForKey:@"MaintenanceAction"];
                    maintenancePlan.notes=[rootResultDict objectForKey:@"Notes"];
                    maintenancePlan.owner=[rootResultDict objectForKey:@"Owner"];
                    [self.maintenancePlanArray addObject:maintenancePlan];
                }
                else 
                {
                    NSNumber *errorId=[rootResultDict objectForKey:@"ErrID"];
                    if ([errorId intValue]==10003)
                    {
                        [self handleException:10003 andAdditionalMessage:nil];
                    }
                    else if([errorId intValue]==10001)
                    {
                        [self handleException:10001 andAdditionalMessage:[rootResultDict objectForKey:@"Error"]];
                    }
                    else if([errorId intValue]==10014)
                    {
                        [self handleException:10014 andAdditionalMessage:nil];
                    }
                    else if([errorId intValue]==10015)
                    {
                        [self handleException:10015 andAdditionalMessage:[rootResultDict objectForKey:@"Error"]];
                    }
                    else if([errorId intValue]==10016)
                    {
                        [self handleException:10016 andAdditionalMessage:[rootResultDict objectForKey:@"Error"]];
                    }
 
                }
            }
        }

    }
    [maintenaceTable reloadData];
   }

-(void)handleException:(int)errorCode andAdditionalMessage:(NSString*)message
{
    switch (errorCode)
    {
        case 10001:
        {
            NSString *pMessage=@"";
            if(message)
                pMessage=message;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Exception" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10003:
        {
            [self fetchSessionToken];
        }
            break;
        case 10014:
        {
            NSString *pMessage=@"Cannot issue command to tracker.";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10015:
        {
            NSString *pMessage=@"Command failed with error: ";
            if(message)
                pMessage=[NSString stringWithFormat:@"%@%@",pMessage,message];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10016:
        {
            NSString *pMessage=@"";
            if(message)
                pMessage=message;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10017:
        {
            NSString *pMessage=@"Array already locked.";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10018:
        {
            NSString *pMessage=@"Array lock failed.";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10019:
        {
            NSString *pMessage=@"Array already unlocked.";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case 10020:
        {
            NSString *pMessage=@"Array unlock failed.";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:pMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

-(void)fetchSessionToken
{
    if(!m_Connection)
    {
        m_Connection=[[Connection alloc]init];
        m_Connection.m_delegate=self;
    }
    [m_Connection connectToServer];
    if(m_ActivityIndicatorView)
    {
        [m_ActivityIndicatorView removeFromSuperview];
        m_ActivityIndicatorView=nil;
    }
    m_ActivityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(150, 200, 30, 30)];
    [m_ActivityIndicatorView startAnimating];
    m_ActivityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    [self addSubview:m_ActivityIndicatorView];  
}

@end
