//
//  MaintenancePlanDetailView.m
//  GreenVolts
//
//  Created by Rapidvalue on 8/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancePlanDetailView.h"
#import "MaintenanceLogView.h"

@implementation MaintenancePlanDetailView
@synthesize maintenancePlanDetailCell;
@synthesize delegate;
@synthesize maintenancePlan;
#pragma mark-initial methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadview];
        // Initialization code
    }
    return self;
}
#pragma mark- load views
-(void) loadview
{
    
    maintenaceDetailTable = [[UITableView alloc] initWithFrame: CGRectMake(0,0,320,330) style:UITableViewStylePlain];
    //maintenaceTable.backgroundColor = [UIColor grayColor];
   // maintenaceDetailTable.separatorStyle=UITableViewCellSeparatorStyleNone;
    maintenaceDetailTable.backgroundColor=[UIColor colorWithRed:31/255.0f green:41/255.0f blue:58/255.0f alpha:1];
    maintenaceDetailTable.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [maintenaceDetailTable setSeparatorColor:[UIColor colorWithRed:40/255.0f green:48/255.0f blue:64/255.0f alpha:1]];
	maintenaceDetailTable.delegate = self;
	maintenaceDetailTable.dataSource = self;
	[self addSubview:maintenaceDetailTable]; 
}

#pragma mark- Tableview DataSource/Delegate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    MaintenancePlanDetailCell *maintenanceDetailCell = (MaintenancePlanDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (maintenanceDetailCell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"MaintenancePlanDetailCell" owner:self options:nil];
        maintenanceDetailCell = maintenancePlanDetailCell;
        self.maintenancePlanDetailCell = nil;
    }
    
    
    maintenanceDetailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [maintenanceDetailCell displayDetails:indexPath.row :self.maintenancePlan];
    return maintenanceDetailCell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if(indexPath.row==0)
    {
     
    [self animateview];
        
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor=[UIColor whiteColor];
}

#pragma mark- animation
   
-(void)animateview
{
        [UIView animateWithDuration:.35 delay:0.0 options:UIViewAnimationCurveEaseOut animations:
         ^{
             //self.center = CGPointMake(self.center.x + CGRectGetWidth(self.frame), self.frame.origin.y);         
             CGRect newRect = self.frame;
             newRect.origin.x += newRect.size.width;
             self.frame = newRect;
         } completion:^(BOOL finished) 
    {
             [self removeFromSuperview];
         }];
}


#pragma mark- Button Touched
- (IBAction)maintenanceplandetaillogButtonTouched:(id)sender
{
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"islog_button_pressed"];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(planDetailViewlogbuttontouchedWithLocation:maintenancePlanID:task:component:notes:)])
        [delegate planDetailViewlogbuttontouchedWithLocation:self.maintenancePlan.location maintenancePlanID:self.maintenancePlan.iD task:self.maintenancePlan.maintenanceAction component:self.maintenancePlan.componentType notes:self.maintenancePlan.notes];    
}

@end
