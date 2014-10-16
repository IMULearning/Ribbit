//
//  SignupViewController.h
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

- (IBAction)signup:(id)sender;

@end
