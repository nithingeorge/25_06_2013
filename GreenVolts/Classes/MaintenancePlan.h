//
//  MaintenancePlanContent.h
//  GreenVolts
//
//  Created by Shinu Mohan on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaintenancePlan : NSObject

@property(nonatomic,retain)NSString *componentType;
@property(nonatomic,retain)NSString *dateTimeLocal;
@property(nonatomic,retain)NSString *err;
@property(nonatomic,retain)NSNumber *errId;
@property(nonatomic,retain)NSNumber *eventalertId;
@property(nonatomic,retain)NSNumber *iD;
@property(nonatomic,retain)NSString *isCompleted;
@property(nonatomic,retain)NSString *location;
@property(nonatomic,retain)NSString *maintenanceAction;
@property(nonatomic,retain)NSString *notes;
@property(nonatomic,retain)NSString *owner;

@end
