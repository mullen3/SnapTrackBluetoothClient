//
//  Employee.h
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EmployeeDelegate;

@interface Employee : NSObject <NSURLConnectionDelegate>

@property (nonatomic, assign) id<EmployeeDelegate> delegate;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSDate *timeIn;
@property (strong, nonatomic) NSDate *timeOut;

- (void)checkIn;
- (void)checkOut;
- (NSString *)timeInString;
- (NSString *)timeOutString;
- (NSString *)hoursWorkedString;
- (BOOL)isEqual:(id)object;

@end


@protocol EmployeeDelegate <NSObject>

- (void)employeeDidCheckIn:(Employee *)employee;
- (void)employeeDidCheckOut:(Employee *)employee;

@end

