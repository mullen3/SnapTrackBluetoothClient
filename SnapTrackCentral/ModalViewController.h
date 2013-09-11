//
//  ModalViewController.h
//  SnapTrackCentral
//
//  Created by Mullen, Connor on 9/11/13.
//  Copyright (c) 2013 Sanka, Dheeraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@protocol ModalViewControllerDelegate <NSObject>

- (void) hideModal;

@end

@interface ModalViewController : UIViewController
@property (nonatomic, assign) id <ModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) Employee  *employee;
- (IBAction)clickedToDismissModal:(id)sender;

@end
