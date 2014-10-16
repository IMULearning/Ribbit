//
//  ImageViewController.m
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-15.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageURL = [NSURL URLWithString:[imageFile url]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    self.imageView.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"];
    self.navigationItem.title = [NSString stringWithFormat:@"Sent from %@", senderName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self respondsToSelector:@selector(timeOut)]) {
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    } else {
        NSLog(@"Error: selector missing");
    }
}

#pragma mark - Helper methods

- (void)timeOut {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
