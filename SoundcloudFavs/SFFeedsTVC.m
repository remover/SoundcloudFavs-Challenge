//
//  SFFeedsTVC.m
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 14/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import "SFFeedsTVC.h"
#import "SCUI.h"
#import "JSONKit.h"
#import "SFAppDelegate.h"
#import "SFUser.h"

@implementation SFFeedsTVC

@synthesize responseJKArray, titleLab, wavImageView, highestRowLoaded, delegate, user;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
                
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)login
{
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
        
        SCLoginViewController *loginViewController;
        loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL
                                                                      completionHandler:^(NSError *error){
                                                                          
                                                                          if (SC_CANCELED(error)) {
                                                                              NSLog(@"Canceled!");
                                                                          } else if (error) {
                                                                              NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                                                                          } else {
                                                                              NSLog(@"Done!");
                                                                              
                                                                              [self getFavourites];
                                                                          }
                                                                      }];
        
        [self presentModalViewController:loginViewController
                                animated:NO];
        
    }];
}

-(void)getFavourites
{
    
//    NSString *userIDStr = [[NSNumber numberWithInt:userID] stringValue];
    
//    NSString *urlStr = [NSString stringWithFormat: @"https://api.soundcloud.com/users/%@/favorites.json?client_id=%@", userIDStr, delegate.clientID];
    
    NSString *urlStr = @"https://api.soundcloud.com/me/favorites.json?";
    
    SCAccount *account = [SCSoundCloud account];

    id obj = [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:urlStr]
                      usingParameters:nil
                          withAccount:account
               sendingProgressHandler:nil
                      responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                          // Handle the response
                          if (error) {
                              NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                              
                              NSLog(@"response url: %@", response.URL);
                              
                          } else {
                              
                              responseJKArray = [[JSONDecoder decoder]parseJSONData:data];
                              
                              NSLog(@"favourites: %@", responseJKArray);
                              
                              [self createArraysForTableView];
                             
                          }
                      }];
    
}


-(void)createArraysForTableView
{
    user = [[SFUser alloc] init];                    
    
    user.favTitlesAr = [NSMutableArray arrayWithCapacity:1];
    user.favWavformURLAr = [NSMutableArray arrayWithCapacity:1];
    user.favTrackIDAr = [NSMutableArray arrayWithCapacity:1];

    
    for (int i = 0; i < [responseJKArray count]; i++)
    {
        NSDictionary *dict = [responseJKArray objectAtIndex:i];
        
        [user.favTitlesAr addObject:[dict objectForKey:@"title"]];
        [user.favWavformURLAr addObject:[dict objectForKey:@"waveform_url"]];
        [user.favTrackIDAr addObject:[dict objectForKey:@"id"]];
    }
    
    [self.tableView reloadData];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    delegate = (SFAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.tableView.rowHeight = 70;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    titleLab = nil;
    
    wavImageView = nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if([SCSoundCloud account] == nil)
        [self login];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.user.favTitlesAr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *lab = (UILabel*)[cell viewWithTag:1];
    UIImageView *iv = (UIImageView*)[cell viewWithTag:2];
    
    lab.text = [self.user.favTitlesAr objectAtIndex:indexPath.row];

    [self setHighestRowLoaded:indexPath.row];

    if (indexPath.row >= [self getHighestRowLoaded])
    { 
        iv.image = [self waveformForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

-(UIImage*)waveformForRowAtIndexPath:(NSIndexPath*)ip
{
    UIImage *returnVal = nil;
    
    if (ip.row < 100)
    {        
        NSURL *url = [[NSURL alloc] initWithString:[self.user.favWavformURLAr objectAtIndex:ip.row]];
        NSData *avatarData = [[NSData alloc] initWithContentsOfURL:url];
        returnVal = [[UIImage alloc] initWithData:avatarData];        
    }
    
    return returnVal;        
    
}

-(void)setHighestRowLoaded:(NSInteger)newVal
{
    if (newVal > highestRowLoaded)
        highestRowLoaded = newVal;
    
}

-(NSInteger)getHighestRowLoaded
{
    return highestRowLoaded;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UILabel *lab = (UILabel*)[cell viewWithTag:1];
    UIImageView *iv = (UIImageView*)[cell viewWithTag:2];
    
    NSLog(@"lab frame: %@", NSStringFromCGRect(lab.frame));
    NSLog(@"iv frame: %@", NSStringFromCGRect(iv.frame));
    
}





























@end
