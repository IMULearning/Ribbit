//
//  ImageViewController.h
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-15.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PFObject *message;

@end
