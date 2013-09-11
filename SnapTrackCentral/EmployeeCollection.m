//
//  EmployeeCollection.m
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import "EmployeeCollection.h"


#define EMPLOYEE_CELL_IDENTIFIER @"employeeCell"

@implementation EmployeeCollection

- (id)init {
    self = [super init];
    if (self) {
        self.employees = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addEmployee:(Employee *)employee {
    if (employee && ![self.employees containsObject:employee]) {
        [self.employees addObject:employee];
    }
}


#pragma mark - TableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.employees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *employeeCell = [tableView dequeueReusableCellWithIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    
    if (employeeCell == nil) {
        employeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    }
    
    UIImage *employeePhoto = [UIImage imageNamed:[[self.employees objectAtIndex:indexPath.row] imagePath]];
    
    UILabel *employeeNameLabel = (UILabel *)[employeeCell viewWithTag:101];
    employeeNameLabel.text = [[self.employees objectAtIndex:indexPath.row] name];
    
    //employeeCell.textLabel.text = _employeeNames[0];
    employeeCell.imageView.image = employeePhoto;
    return employeeCell;
}

@end
