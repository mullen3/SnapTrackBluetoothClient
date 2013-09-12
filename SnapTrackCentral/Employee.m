//
//  Employee.m
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import "Employee.h"

@implementation Employee

- (id)init{
    self = [super init];
    if (self){
        self.name = [[NSString alloc]init];
        self.imagePath = @"useravatar.png";
    }
    return self;
}

- (void)checkIn {
    self.timeIn = [NSDate date];
}

- (void)checkOut {
    self.timeOut = [NSDate date];
}

- (NSString *)timeInString {
    return [self stringFor:self.timeIn];
}

- (NSString *)timeOutString {
    return [self stringFor:self.timeOut];
}

- (NSString *)hoursWorkedString {
    NSDate *fromTime;
    NSDate *toTime;
    
    // pulled this from stack overflow... kind of confusing
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSHourCalendarUnit startDate:&fromTime interval:NULL forDate:self.timeIn];
    [calendar rangeOfUnit:NSHourCalendarUnit startDate:&toTime interval:NULL forDate:self.timeOut];
    
    NSDateComponents *difference = [calendar components:NSHourCalendarUnit fromDate:fromTime toDate:toTime options:0];
    
    return [NSString stringWithFormat:@"%d", [difference hour]];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]){
        Employee *employee = object;
        return [self.name isEqualToString:employee.name];
    }
    return NO;
}

- (NSString *)stringFor:(NSDate *) date{
    NSString *dateString = @"";
    if (date) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"HH:mm"];
        dateString = [timeFormat stringFromDate:date];
    }
    return dateString;
}

@end
