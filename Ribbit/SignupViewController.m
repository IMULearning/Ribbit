//
//  SignupViewController.m
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signup:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    NSString *email = self.emailField.text;
    
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    username = [username stringByTrimmingCharactersInSet:charSet];
    password = [password stringByTrimmingCharactersInSet:charSet];
    email = [email stringByTrimmingCharactersInSet:charSet];
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username, password and email address!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    } else {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:error.userInfo[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}
@end
