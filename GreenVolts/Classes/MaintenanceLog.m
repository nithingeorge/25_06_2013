//
//  MaintenanceLogContent.m
//  GreenVolts
//
//  Created by Shinu Mohan on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenanceLog.h"

@implementation MaintenanceLog

@synthesize componentType,dateTimeLocal,description,duration,err,errId,iD,
 location,maintenanceAction,maintenancePlan,newcomponent,oldComponent,owner;

-(id)init
{
    if(self  = [super init])
    {
        componentType=nil;
        dateTimeLocal=nil;
        description=nil;
        duration=nil;
        err=nil;
        errId=nil;
        iD=nil;
        location=nil;
        maintenanceAction=nil;
        maintenancePlan=nil;
        newcomponent=nil;
        oldComponent=nil;
        owner=nil;        
        
    }
    return self;
}


@end
