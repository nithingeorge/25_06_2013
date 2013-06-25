//
//  MaintenanceLogView.m
//  GreenVolts
//
//  Created by Shinu Mohan on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenanceLogView.h"
#import "MaintenanceLog.h"
#import "MaintenanceLogDetailView.h"
#import "MaintenanceLogDetailPickerView.h"
#import "MaintenanceLogDetailNotesView.h"
#import "MaintenanceTask.h"
#import "MaintenanceComponent.h"

@interface MaintenanceLogView()
{
    NSMutableArray *maintenanceTaskArray,*maintenanceComponentArray;
    float height,finalheight;
     NSString *text;

}
- (void)logDetailViewButtonTouched;
- (void)loadMaintenanceViewBarcodeView:(BOOL)value;
-(void)loadMaintenanceViewTableview:(int)rowIndex;
-(void)loadMaintenanceViewPickerview;
-(void)loadMaintenanceViewUpdateNotesview;
- (void)animateView:(UIView*)currentView;
-(NSString*)setLogDetailLabelForRow:(int)rowIndex;
-(void)getMaintenanceTask;
-(void)getMaintenanceComponent;
- (void)showLogDetails:(int)result;


@end


MaintenanceLogDetailView *maintenanceLogDetailView;
MaintenanceLogBarCodeView *maintenanceLogBarCodeView;
MaintenanceLogDetailPickerView *maintenanceLogDetailPickerView;
MaintenanceLogDetailNotesView *maintenanceLogDetailNotesView;

@implementation MaintenanceLogView

@synthesize maintenanceLogArray;
@synthesize maintenanceLogCell;
@synthesize iD,location,maintenanceAction,componentType,notes,time;
@synthesize selectedRow;
@synthesize OLDBarcodeValue;
@synthesize NEWBarcodevalue;

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
    
    NSLog(@"log loading");
    [self getMaintenanceTask];
    maintenacelogTable = [[UITableView alloc] initWithFrame: CGRectMake(0,0,320,330) style:UITableViewStylePlain];
     //maintenacelogTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    maintenacelogTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [maintenacelogTable setSeparatorColor:[UIColor colorWithRed:40/255.0f green:48/255.0f blue:64/255.0f alpha:1]];
    // maintenacelogTable.sepe = [UIColor grayColor];
    maintenacelogTable.backgroundColor=[UIColor colorWithRed:31/255.0f green:41/255.0f blue:58/255.0f alpha:1];
	maintenacelogTable.delegate = self;
	maintenacelogTable.dataSource = self;
	[self addSubview:maintenacelogTable]; 
    
    maintenanceLogArray = [[NSMutableArray alloc]init];
    
}

#pragma tableviewdelegate methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Array Count ::: %d",[maintenanceLogArray count]);
    return 8;    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
     static NSString *CellIdentifier = @"Cell";
    
    
    MaintenanceLogCell *maintenanceCell = (MaintenanceLogCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (maintenanceCell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"MaintenanceLogCell" owner:self options:nil];
        maintenanceCell = maintenanceLogCell;
        self.maintenanceLogCell = nil;
    }

    maintenanceCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [maintenanceCell displayDetails:nil rowValue:indexPath.row :[self setLogDetailLabelForRow:indexPath.row]]; 
    
    if((indexPath.row==8)||(indexPath.row==9))
    {
        maintenanceCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return maintenanceCell;

   
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    //UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //return cell.frame.size.height;
    
    if(indexPath.row==7)
    {
        
        text = self.notes;
        int calculatedHeight = [self textViewHeight:text andWidth:235];
        int numberOfLines = (calculatedHeight / 25)+2;
        if (calculatedHeight > 25)
        {
            finalheight=25 * numberOfLines;
            return finalheight;
            
        }
        else 
            return 44;
    }
    else 
        return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    self.selectedRow = indexPath.row;
    
    [self showLogDetails:indexPath.row];
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"navpopover_cell_backround (2)"]];
    cell.backgroundColor=[UIColor clearColor];
    //cell.backgroundView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navpopover_cell_backround (2)"]];
    cell.textLabel.textColor=[UIColor whiteColor];
}
#pragma mark - Helper Methods

- (float)textViewHeight:(NSString *)textString andWidth:(float)width
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGSize stringSize = [textString sizeWithFont:font constrainedToSize:size];
    
    return stringSize.height;
}

#pragma mark-show results method

-(NSString*)setLogDetailLabelForRow:(int)rowIndex
{
    NSString *result;
    
    switch (rowIndex) 
    {
        case 0:
        {
            if(self.iD)
                result =  [NSString stringWithFormat:@"%d",[self.iD intValue]];
            else 
                result =@" ";
        }
            break;
        case 1:
            result =  self.location;
            break;
        case 2:
            result =  self.maintenanceAction;
            break;
        case 3:
            result =  self.componentType;
            break;
        case 4:
            result =  OLDBarcodeValue;
            break;
        case 5:
            result =  NEWBarcodevalue;
            break;
        case 6:
            result =  self.time;
            break;
        case 7:
            result =  self.notes;
            break;
        default:
            break;
    }
    return result;
    
}



- (void)showLogDetails:(int)result
{
    NSLog(@"BUTTON ID %d",result);
    switch (result)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            [self loadMaintenanceViewTableview:result];
            break;
        case 3:
            [self loadMaintenanceViewTableview:result];
            break;
        case 4:
            [self loadMaintenanceViewBarcodeView:YES];
            break;
        case 5:
            [self loadMaintenanceViewBarcodeView:NO];
            break;
        case 6:   
            [self loadMaintenanceViewPickerview];
            break;
        case 7:
            [self loadMaintenanceViewUpdateNotesview];
            break;
            
        default:
            break;
            
    }
}

#pragma mark- table load view methods

-(void)loadMaintenanceViewTableview:(int)rowIndex
{
    NSString *title = (rowIndex == 2 ?@" Select Task" :@"Select Component" );
    
    maintenanceLogDetailView=[[MaintenanceLogDetailView alloc]initWithFrame:CGRectMake(0, 0, 320, 460) titleString:title];
    maintenanceLogDetailView.delegate = self;
    
    if(rowIndex==2)
    {
    maintenanceLogDetailView.contentArray=maintenanceTaskArray;
        maintenanceLogDetailView.componentid=Task;
    }
    else if(rowIndex==3)
    {
    maintenanceLogDetailView.contentArray=maintenanceComponentArray;
    maintenanceLogDetailView.componentid=Component;
    }
    
    [self animateView:maintenanceLogDetailView];
}

- (void)loadMaintenanceViewBarcodeView:(BOOL)value
{
    NSString *barcodeNumber;
    if (selectedRow == 4)
        barcodeNumber = OLDBarcodeValue;
    else
        barcodeNumber = NEWBarcodevalue;
            
    maintenanceLogBarCodeView=[[MaintenanceLogBarCodeView alloc]init];
    maintenanceLogBarCodeView.isOLDBarCodeReader = value;
    maintenanceLogBarCodeView.barcodeNumber = barcodeNumber;
    maintenanceLogBarCodeView.delegate = self;
    maintenanceLogBarCodeView.view.frame = CGRectMake(0, 0, 320, 460);
    [self animateView:maintenanceLogBarCodeView.view];
}

-(void)loadMaintenanceViewPickerview;
{
    maintenanceLogDetailPickerView=[[MaintenanceLogDetailPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 460) andTime:self.time];
    maintenanceLogDetailPickerView.delegate=self;
   // maintenanceLogDetailPickerView.frame = CGRectMake(0, 0, 320, 460);
   // maintenanceLogDetailPickerView.frame = self.frame;
    [self animateView:maintenanceLogDetailPickerView];
}


-(void)loadMaintenanceViewUpdateNotesview;
{
    
    maintenanceLogDetailNotesView=[[MaintenanceLogDetailNotesView alloc]initWithFrame:CGRectMake(0, 0, 320, 460) andNotes:self.notes];
    maintenanceLogDetailNotesView.delegate = self;
    [self animateView:maintenanceLogDetailNotesView];
}


#pragma mark-animations

- (void)animateView:(UIView*)currentView
{
    NSLog(@"FRAME %@",NSStringFromCGRect(currentView.frame));
    [self addSubview: currentView];
    // Animate the push
    CGRect oldRect = currentView.frame;
    oldRect.origin.x = oldRect.origin.x + currentView.frame.size.width;
    oldRect.origin.y = maintenacelogTable.frame.origin.y;
    currentView.frame = oldRect;
    
    [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
     ^{
         CGRect newRect = currentView.frame;
         newRect.origin.x = newRect.origin.x - currentView.frame.size.width;
         currentView.frame = newRect;
         
     } completion:^(BOOL finished) {
         
     }];
}

#pragma mark- button action

- (IBAction)saveButtonTouched:(id)sender
{
 
    NSString *pSessionToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"SESSION_TOKEN"];
    NSString *pEntityId=[[NSUserDefaults standardUserDefaults]objectForKey:@"ID"];
    NSString *pSiteId=[[NSUserDefaults standardUserDefaults] objectForKey:@"SITE_ID"];
    NSString *pEntityScope=[[NSUserDefaults standardUserDefaults]objectForKey:@"ENTITY_TYPE"];
    NSString *pOwnerId=@"9";
    NSString *pMaintenanceLogTypeID=@"2";
    NSString *pDescription=self.notes;
    NSString *pLocation=self.location;
    NSString *pDuration=self.time;
    NSString *pComponentTypeId=@"2";
    NSString *pOldComponent=@"null";
    NSString *pNewComponent=@"null";
    NSString *pMaintenancePlanId=@"null";
    
    urlString=[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/InsertMaintenanceLog?sessionToken=%@&siteID=%@&entityScope=%@&entityID=%@&maintenanceLogTypeID=%@&ownerID=%@&description=%@&location=%@&duration=%@&componentTypeID=%@&oldComponent=%@&newComponent=%@&maintenancePlanID=%@",kserverAddress,pSessionToken,pSiteId,pEntityScope,pEntityId,pMaintenanceLogTypeID,pOwnerId,pDescription,pLocation,pDuration,pComponentTypeId,pOldComponent,pNewComponent,pMaintenancePlanId];
    
    NSLog(@"URL Request: %@",[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/InsertMaintenanceLog?sessionToken=%@&siteID=%@&entityScope=%@&entityID=%@&maintenanceLogTypeID=%@&ownerID=%@&description=%@&location=%@&duration=%@&componentTypeID=%@&oldComponent=%@&newComponent=%@&maintenancePlanID=%@",kserverAddress,pSessionToken,pSiteId,pEntityScope,pEntityId,pMaintenanceLogTypeID,pOwnerId,pDescription,pLocation,pDuration,pComponentTypeId,pOldComponent,pNewComponent,pMaintenancePlanId]); 
    
    [self connectToServer:urlString]; 
}

- (IBAction)accessoryButtonTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [self showLogDetails:button.tag];
}
#pragma mark-connection methods
-(void)getMaintenanceTask
{
    NSString *pSessionToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"SESSION_TOKEN"];
    urlString=[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetMaintenanceTask?sessionToken=%@",kserverAddress,pSessionToken];
    [self connectToServer:urlString];
}


-(void)getMaintenanceComponent
{
     
    NSString *pSessionToken=[[NSUserDefaults standardUserDefaults]objectForKey:@"SESSION_TOKEN"];
     urlString=[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetMaintenanceComponent?sessionToken=%@",kserverAddress,pSessionToken];
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
    
    // NSLog(@"URL Request: %@",[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetMaintenancePlans?sessionToken=%@&siteID=%@&entity scope=%@&entityID=%@&maintenancePlanTypeID=%@&ownerID=%@&completed=%@&componentTypeID=%@&",kserverAddress,sessionToken,siteID,entityscope,entityID,maintenancePlanTypeID,ownerID,completed,componentTypeID]);  
    
	mURLConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pURLString]] delegate:self];
    
    //NSLog(@"URL Request: %@",[NSString stringWithFormat:@"%@/GreenVolts-ISIS-BL-Web-Models-iPhone-iPhone_DS.svc/JSON/GetMaintenancePlans?sessionToken=%@&siteID=%@&entity scope=%@&entityID=%@&maintenancePlanTypeID=%@&ownerID=%@&completed=%@&componentTypeID=%@&",kserverAddress,sessionToken,siteID,entityscope,entityID,maintenancePlanTypeID,ownerID,completed,componentTypeID]);
    
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
    //if(m_ActivityIndicatorView){[m_ActivityIndicatorView removeFromSuperview];m_ActivityIndicatorView=nil;}
    
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
    NSString *apiName;
    NSString *responseString=[[NSString alloc]initWithData:mResponseData encoding:NSUTF8StringEncoding];
    mResponseData=nil;
    
    NSDictionary *data=[responseString JSONValue];
    NSArray *keyArray=[data allKeys];
    if(keyArray)
    {
        if([keyArray count]>0)
        {
            apiName=[keyArray lastObject];
        }
    }
    
    if([apiName isEqualToString:@"GetMaintenanceTaskResult"])
    {
        [self getMaintenanceComponent];
        maintenanceTaskArray=[[NSMutableArray alloc] init];
        NSDictionary *maintenancePlanResult=[data objectForKey:@"GetMaintenanceTaskResult"];
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
                        MaintenanceTask *maintenanceTask=[[MaintenanceTask alloc]init];
                        maintenanceTask.displayOrder=[rootResultDict objectForKey:@"DisplayOrder"];
                        maintenanceTask.name=[rootResultDict objectForKey:@"Name"];
                        [maintenanceTaskArray addObject:maintenanceTask];
                        
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

    }
else if ([apiName isEqualToString:@"GetMaintenanceComponentResult"]) 
{
    maintenanceComponentArray=[[NSMutableArray alloc] init];
    NSDictionary *maintenancePlanResult=[data objectForKey:@"GetMaintenanceComponentResult"];
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
                    MaintenanceComponent *maintenanceComponent=[[MaintenanceComponent alloc]init];
                    maintenanceComponent.displayOrder=[rootResultDict objectForKey:@"DisplayOrder"];
                    maintenanceComponent.name=[rootResultDict objectForKey:@"Name"];
                    [maintenanceComponentArray addObject:maintenanceComponent];
                    
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

}
    
    
        
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

#pragma mark- Detail Selection Delegates
-(void)logdetailtaskselected:(NSString*)taskname:(MaintenanceLogFields)componentId;
{
    if(componentId==Task)
        self.maintenanceAction=taskname;
    else if(componentId==Component)
        self.componentType=taskname;
    
    [maintenacelogTable reloadData];  
}

#pragma mark- Notes Save Delegates
-(void)logDetailNoteSaved:(NSString*)savedString componentID:(MaintenanceLogFields)componentid
{
      
    self.notes=savedString;
    [maintenacelogTable reloadData];
    
           
}
#pragma  mark-Picker Update Delegates
-(void)pickerUpdateToLog:(NSString*)dateString
{
    self.time=dateString;
    [maintenacelogTable reloadData];
    
}

#pragma mark- BackButtonDelegates

- (void)backButtonTouched:(id)currentobject
{
    [currentobject removeFromSuperview];
    currentobject = nil;
}

#pragma mark- BarcodeDelegates

-(void)barcodeScanSuccessfull:(id)currentobject barcodeNumber:(NSString *)barcodeValue
{
    [currentobject removeFromSuperview];
    currentobject = nil;
    
    NSLog(@"BARCODE NUMBER :: %@",barcodeValue);
    
    if (self.selectedRow == 4) 
    {
      OLDBarcodeValue = @"";
      OLDBarcodeValue = barcodeValue;   
    }
        
    if (self.selectedRow == 5)
    {
        NEWBarcodevalue = @"";
        NEWBarcodevalue = barcodeValue;   
    }
    
    NSLog(@"Slected row :::: %d",selectedRow);
    [maintenacelogTable reloadData];
}

@end
