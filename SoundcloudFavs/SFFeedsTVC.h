//
//  SFFeedsTVC.h
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 14/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFAppDelegate, SFUser;

@interface SFFeedsTVC : UITableViewController <UIAlertViewDelegate, UITabBarControllerDelegate>

-(void)login;

@end
