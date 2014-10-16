//
//  LoginViewController.m
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)login:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    username = [username stringByTrimmingCharactersInSet:charSet];
    password = [password stringByTrimmingCharactersInSet:charSet];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username, password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    } else {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:error.userInfo[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorView show];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
    }
}

@end
