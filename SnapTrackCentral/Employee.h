//
//  Employee.h
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSDate *timeIn;
@property (strong, nonatomic) NSDate *timeOut;

- (void)checkIn;
- (void)checkOut;
- (BOOL)isEqual:(id)object;

@end
