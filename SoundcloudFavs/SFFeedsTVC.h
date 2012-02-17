//
//  SFFeedsTVC.h
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 14/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAppDelegate, SFUser;

@interface SFFeedsTVC : UITableViewController <UIAlertViewDelegate>

//array for JSON response to requests
@property (nonatomic, strong) id responseJKArray;
//user details: favorites titles etc.
@property (nonatomic, weak) SFUser *user;
//table view cell lab and image view
@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) UIImageView *wavImageView;

@property (nonatomic, assign) NSInteger highestRowLoaded;
@property (nonatomic, weak) SFAppDelegate *delegate;
@property (nonatomic, assign) BOOL hasLastRowBeenReached;

-(void)login;
-(void)getFavourites;
-(void)createArraysForTableView;
-(void)setHighestRowLoaded:(NSInteger)newVal;
-(void)makeUserNameRequest;


@end
