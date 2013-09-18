//
//  Employee.m
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import "Employee.h"

#define SNAPTRACK_ENDPOINT_URL @"http://snaptrack.intuit.com/api/mtalk/"
#define JSON_TEMPLATE @"{\"destination\": { \"shortCode\": \"97068\"}, \"message\": [ {\"content\": { \"textContent\": \"%@\"}, \"messageDate\": \"2013-09-16\", \"keyword\": \"%@\" }], \"senderProfile\": { \"senderId\": \"8478946423\"}}"

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
    if (self.timeIn) {
        [self.delegate employeeDidCheckIn:self];
    }
    [self post:[NSString stringWithFormat:JSON_TEMPLATE, @"In", @"In"]];
}

- (void)checkOut {
    self.timeOut = [NSDate date];
    if (self.timeOut) {
        [self.delegate employeeDidCheckOut:self];
    }
    [self post:[NSString stringWithFormat:JSON_TEMPLATE, @"Out", @"Out"]];
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

- (void)post:(NSString *)requestJSON {
    NSString *post = requestJSON;
    NSLog(@"%@", requestJSON);
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:SNAPTRACK_ENDPOINT_URL]];
    NSLog(@"%@", [request.URL absoluteString]);
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
        
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSLog(@"responseData: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
}

// add delegate methods to handle data?

@end
