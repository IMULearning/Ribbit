//
//  InboxTableViewController.m
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-13.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import "InboxTableViewController.h"
#import "ImageViewController.h"

@interface InboxTableViewController ()

@end

@implementation InboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        NSLog(@"%@ is logged in", currentUser.username);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser] != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                self.messages = objects;
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [message objectForKey:@"fileType"];
    
    cell.textLabel.text = [message objectForKey:@"senderName"];
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    // Delete it!
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    if (recipientIds.count > 1) {
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    } else if (recipientIds.count == 1) {
        [self.selectedMessage deleteInBackground];
    }
    
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        InboxTableViewController *vc = [segue destinationViewController];
        [vc setHidesBottomBarWhenPushed:YES];
        [vc.navigationItem setHidesBackButton:YES animated:YES];
    } else if ([segue.identifier isEqualToString:@"showImage"]) {
        ImageViewController *vc = [segue destinationViewController];
        [vc setHidesBottomBarWhenPushed:YES];
        vc.message = self.selectedMessage;
    }
}

@end
