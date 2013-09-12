//
//  EmployeeCollection.h
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Employee.h"

@interface EmployeeCollection : NSObject <UITableViewDataSource, EmployeeDelegate>

@property (strong, nonatomic) NSMutableArray *activeEmployees;
@property (strong, nonatomic) NSMutableArray *unactiveEmployees;

- (void)addEmployee:(Employee *)employee;

@end
