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

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]){
        Employee *employee = object;
        return [self.name isEqualToString:employee.name];
    }
    return NO;
}

@end
