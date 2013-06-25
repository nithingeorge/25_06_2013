//
//  MaintenanceLogDetailView.m
//  GreenVolts
//
//  Created by Shinu Mohan on 23/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenanceLogDetailView.h"
#import "MaintenanceTask.h"
#import "MaintenanceComponent.h"


@interface MaintenanceLogDetailView() 

-(void)createCustomNavigationView;
- (IBAction)logbackButtonTouched:(id)sender;  
- (BOOL)isMaintenanceTaskTable;
- (UIImage *)accessoryImage;
@end
MaintenanceTask *maintenanceTask;
MaintenanceComponent *maintenanceComponent;
BOOL isMaintenanceTaskTable;
@implementation MaintenanceLogDetailView
@synthesize maintenanceLogDetailCell;
@synthesize contentArray;
@synthesize delegate;
@synthesize componentid;
@synthesize title;
@synthesize lastIndexPath;

#pragma mark-initialisation
- (id)initWithFrame:(CGRect)frame titleString:(NSString *)value
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = value;
        [self loadview];
        // Initialization code
    }
    return self;
}
#pragma mark- load views
-(void) loadview
{
    self.backgroundColor = [UIColor lightGrayColor];
    [self createCustomNavigationView];
    maintenacelogDetailTable = [[UITableView alloc] initWithFrame: CGRectMake(0,45,320,290) style:UITableViewStylePlain];
   // maintenacelogDetailTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    maintenacelogDetailTable.backgroundColor=[UIColor colorWithRed:31/255.0f green:41/255.0f blue:58/255.0f alpha:1];
    maintenacelogDetailTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [maintenacelogDetailTable setSeparatorColor:[UIColor colorWithRed:40/255.0f green:48/255.0f blue:64/255.0f alpha:1]];
    maintenacelogDetailTable.delegate = self;
	maintenacelogDetailTable.dataSource = self;
	[self addSubview:maintenacelogDetailTable]; 
    
}

#pragma mark-custom methods

-(void)createCustomNavigationView
{
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    //navBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navpopover_cell_backround (2)"]];
    navBar.tintColor=[UIColor colorWithRed:1/255.f green:14/255.f blue:41/255.f alpha:1];
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(5,5,80,30);
    button.backgroundColor=[UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [button setTitle:@"Back" forState:UIControlStateNormal];
    button.titleLabel.textColor=[UIColor whiteColor];
    [button addTarget:self action:@selector(logbackButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button]; 
 
    UILabel *logtitlelabel = [[UILabel alloc] initWithFrame:CGRectMake(100,10,200,25)];
    //logtitlelabel.numberOfLines = 0;//Dynamic
    logtitlelabel.backgroundColor = [UIColor clearColor];
    logtitlelabel.textColor = [UIColor whiteColor];
    logtitlelabel.text = title;
    [navBar addSubview:logtitlelabel];
    
    [self addSubview:navBar];
}

- (BOOL)isMaintenanceTaskTable
{
    BOOL result;
    
    if(componentid==Component)
    {
        result = NO;
        isMaintenanceTaskTable = NO;
    }
    else if(componentid==Task)
    {
        result = YES;
        isMaintenanceTaskTable = YES;
    }
    return result;
}
#pragma mark- Table Delegates
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    if (self.contentArray)
    {
        return [self.contentArray count];
    }
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
    
    static NSString *CellIdentifier = @"Cell";
    MaintenanceLogDetailCell *logmaintenanceDetailCell = (MaintenanceLogDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (logmaintenanceDetailCell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"MaintenanceLogDetailCell" owner:self options:nil];
        logmaintenanceDetailCell = maintenanceLogDetailCell;
        self.maintenanceLogDetailCell = nil;
    }
    
    logmaintenanceDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    logmaintenanceDetailCell.accessoryView = [self accessoryImage];

    if ([self isMaintenanceTaskTable]) 
    {
        maintenanceTask=[self.contentArray objectAtIndex:indexPath.row];
        [logmaintenanceDetailCell displayDetails:indexPath.row :maintenanceTask.name];
        //for display tick mark
        if (maintenanceTask.isSelected)
        {
            logmaintenanceDetailCell.accessoryType = UITableViewCellAccessoryCheckmark;
            //self.lastIndexPath = indexPath;        
        }
        else
            logmaintenanceDetailCell.accessoryType = UITableViewCellAccessoryNone;
    }
    else 
    {
        maintenanceComponent=[self.contentArray objectAtIndex:indexPath.row];
        [logmaintenanceDetailCell displayDetails:indexPath.row :maintenanceComponent.name];
        //for display tick mark
        if (maintenanceComponent.isSelected)
        {
            logmaintenanceDetailCell.accessoryType = UITableViewCellAccessoryCheckmark;
            //self.lastIndexPath = indexPath;        
        }
        else
            logmaintenanceDetailCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return logmaintenanceDetailCell;
   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{

    if (isMaintenanceTaskTable)
    {
        for(int i = 0; i < [self.contentArray count]; i++)
        {
            maintenanceTask = [self.contentArray objectAtIndex:i];
            
            if(i == indexPath.row)
            {
                maintenanceTask.isSelected = YES;
            }
            else
            {
                maintenanceTask.isSelected = NO;
            }
        }
    }
    else 
    {
        for(int i = 0; i < [self.contentArray count]; i++)
        {
            maintenanceComponent = [self.contentArray objectAtIndex:i];
            
            if(i == indexPath.row)
            {
                maintenanceComponent.isSelected = YES;
            }
            else
            {
                maintenanceComponent.isSelected = NO;
            }
        }
    }
     [maintenacelogDetailTable reloadData];
    //maintenanceTaskArray
    UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    if(newRow != oldRow)
    {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        lastIndexPath = indexPath;
        

    }
    else if(newRow==oldRow)
    {
        newCell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSString *maintenanceTaskName;
    if(componentid==Component)
    {
        maintenanceComponent=[self.contentArray objectAtIndex:indexPath.row];
        maintenanceTaskName = maintenanceComponent.name;
    }
    else if(componentid==Task)
    {
        maintenanceTask=[self.contentArray objectAtIndex:indexPath.row];
        maintenanceTaskName = maintenanceTask.name;
    }

    NSLog(@"task:%@",maintenanceTaskName);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(logdetailtaskselected::)])
        [self.delegate logdetailtaskselected:maintenanceTaskName :componentid];
    
    [self logbackButtonTouched:nil];
}

- (UIImage *)accessoryImage
{
    UIImage *accessoryImage = [UIImage imageNamed:@"popover_checkmark.png"];
    UIImageView *accImageView = [[UIImageView alloc] initWithImage:accessoryImage];
    accImageView.userInteractionEnabled = YES;
    [accImageView setFrame:CGRectMake(0, 0, 28.0, 28.0)];
    return accessoryImage;
}

#pragma mark-button actions

- (IBAction)logbackButtonTouched:(id)sender
 {
     
    [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
     ^{
         //self.center = CGPointMake(self.center.x + CGRectGetWidth(self.frame), self.frame.origin.y);         
         CGRect newRect = self.frame;
         newRect.origin.x += newRect.size.width;
         self.frame = newRect;
     } completion:^(BOOL finished) {
         if(self.delegate && [self.delegate respondsToSelector:@selector(backButtonTouched:)])
             [delegate backButtonTouched:self];
     }];
     
}





@end
