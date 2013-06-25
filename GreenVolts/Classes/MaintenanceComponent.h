//
//  MaintenanceComponent.h
//  GreenVolts
//
//  Created by Shinu Mohan on 05/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MaintenanceComponent : NSObject

@property(nonatomic,strong) NSNumber *displayOrder;
@property(nonatomic,strong) NSString *err;
@property(nonatomic,strong) NSNumber *errId;
@property(nonatomic,strong) NSNumber *iD;
@property(nonatomic,readwrite) BOOL isReplacedRequired;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,readwrite) BOOL requiredValidation;
@property(nonatomic,assign)BOOL isSelected;

@end
