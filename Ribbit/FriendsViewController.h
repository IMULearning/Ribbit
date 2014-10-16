//
//  FriendsViewController.h
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;

@end
