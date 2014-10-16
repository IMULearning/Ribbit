//
//  InboxTableViewController.h
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InboxTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

- (IBAction)logout:(id)sender;


@end
