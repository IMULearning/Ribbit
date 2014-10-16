//
//  CameraViewController.m
//  Ribbit
//
//  Created by Weinan Qiu on 2014-10-14.
//  Copyright (c) 2014 Eland. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraViewController ()

@property (nonatomic) BOOL isCameraOn;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeCamera];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.recipients = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        if (!self.isCameraOn) {
            [self presentViewController:self.imagePicker animated:NO completion:^{
                self.isCameraOn = YES;
            }];
        }
        
        PFQuery *query = [self.friendsRelation query];
        [query orderByAscending:@"username"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            } else {
                self.friends = objects;
                [self.tableView reloadData];
            }
        }];
    }
}

#pragma mark - Helper methods

- (void)initializeCamera {
    self.isCameraOn = NO;
    if (self.imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        self.imagePicker.videoMaximumDuration = 10;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    }
}

- (void)uploadMessage {
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (self.image != nil) {
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f AndHeight:320.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Occured!" message:@"Please trying sending the message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Occured!" message:@"Please trying sending the message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                } else {
                    [self cleanUp];
                }
            }];
        }
    }];
}

- (void)cleanUp {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *) resizeImage:(UIImage *)image toWidth:(float)width AndHeight:(float)height {
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRect = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRect];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseRecipientCell" forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *selectedUser = self.friends[indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:[selectedUser objectId]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:[selectedUser objectId]];
    }
}


#pragma mark - Image Picker Controller delegate

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:^{
        self.isCameraOn = NO;
    }];
    [self.tabBarController setSelectedIndex:0];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // image
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    // video
    else {
        NSURL *pathURL = [info objectForKeyedSubscript:UIImagePickerControllerMediaURL];
        self.videoFilePath = [pathURL path];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.isCameraOn = NO;
    }];
}

#pragma mark - IBActions

- (IBAction)send:(id)sender {
    if ([self.recipients count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wooh!" message:@"Please select at least one recipient" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (self.image == nil && [self.videoFilePath length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try again!" message:@"Please capture or select a photo or video to share" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self presentViewController:self.imagePicker animated:NO completion:^{
            self.isCameraOn = YES;
        }];
    } else {
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

- (IBAction)cancel:(id)sender {
    [self cleanUp];
    [self.tabBarController setSelectedIndex:0];
}

@end
