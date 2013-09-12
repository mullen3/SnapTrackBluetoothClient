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
        self.activeEmployees = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addEmployee:(Employee *)employee {
    if (employee && ![self.activeEmployees containsObject:employee]) {
        [self.activeEmployees addObject:employee];
    }
}


#pragma mark - TableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.activeEmployees count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Employee *employee = [self.activeEmployees objectAtIndex:indexPath.row];
    // add error checking here for employee object?
    
    UITableViewCell *employeeCell = [tableView dequeueReusableCellWithIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    
    if (employeeCell == nil) {
        employeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    }
    
    UIImage *employeePhoto = [UIImage imageNamed:employee.imagePath];
    
    UILabel *timeInLabel = (UILabel *)[employeeCell viewWithTag:102];
    timeInLabel.text = [employee timeInString];
    
    UILabel *timeOutLabel = (UILabel *)[employeeCell viewWithTag:103];
    timeOutLabel.text = [employee timeOutString];
    
    UILabel *employeeNameLabel = (UILabel *)[employeeCell viewWithTag:101];
    employeeNameLabel.text = employee.name;
    
    //employeeCell.textLabel.text = _employeeNames[0];
    employeeCell.imageView.image = employeePhoto;
    return employeeCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Active Employees";
}

- (void)employeeDidCheckIn:(Employee *)employee {
    
}

- (void)employeeDidCheckOut:(Employee *)employee
{
    
}

@end
