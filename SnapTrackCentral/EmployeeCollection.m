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
        self.unactiveEmployees = [[NSMutableArray alloc] init];
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
    if (section == 0) {
        return [self.activeEmployees count];
    }
    else {
        return [self.unactiveEmployees count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // add error checking here for employee object?
    
    UITableViewCell *employeeCell = [tableView dequeueReusableCellWithIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    
    if (employeeCell == nil) {
        employeeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EMPLOYEE_CELL_IDENTIFIER];
    }
    
    Employee *employee;
    if (indexPath.section == 0) {
        employee = [self.activeEmployees objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1) {
        employee = [self.unactiveEmployees objectAtIndex:indexPath.row];
        // change background color
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor grayColor];
        backgroundView.alpha = 0.3f;
        employeeCell.backgroundView = backgroundView;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Active Employees";
    }
    else {
        return @"Inactive Employees";
    }
}

- (void)employeeDidCheckIn:(Employee *)employee {
    if (!employee) return;
    
    // first check if employee is in unactive employees
    if ([self.unactiveEmployees containsObject:employee]){
        // remove from unactive employees then
        [self.unactiveEmployees removeObject:employee];
    }
    
    // if not in active employees, add it
    if (![self.activeEmployees containsObject:employee]){
        [self.activeEmployees addObject:employee];
    }
}

- (void)employeeDidCheckOut:(Employee *)employee
{
    if (!employee) return;
    
    // first check if employee is in active employees
    if ([self.activeEmployees containsObject:employee]){
        // remove from unactive employees then
        [self.activeEmployees removeObject:employee];
    }
    
    // if not in unactive employees, add it
    if (![self.unactiveEmployees containsObject:employee]){
        [self.unactiveEmployees addObject:employee];
    }
}

@end
