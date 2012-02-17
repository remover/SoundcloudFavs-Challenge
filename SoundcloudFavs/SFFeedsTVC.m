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
#import "SFCustomTableViewCell.h"

enum cellSubviewTags {
    kCellSubViewTitleLabel = 1,
    kCellSubViewWavImageView
    };

@implementation SFFeedsTVC

@synthesize responseJKArray, titleLab, wavImageView, highestRowLoaded, delegate, user, hasLastRowBeenReached;

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
}

#pragma mark - login and requests

//log the user in
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
                                                                              
                                                                              [self makeUserNameRequest];
                                                                              
                                                                              [self getFavourites];
                                                                          }
                                                                      }];
        
        [self presentModalViewController:loginViewController
                                animated:YES];
        
    }];
}

//get user name for user
-(void)makeUserNameRequest
{
    NSLog(@"makeUserNameRequest");
    
    NSString *urlStr = @"https://api.soundcloud.com/me.json?";
    
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
                              
                              self.user = [SFUser sharedUserObj];
                              
                              self.user.userName = [responseJKArray objectForKey:@"username"];
                              
                          }
                      }];
    
}

//get favourites data
-(void)getFavourites
{
    NSLog(@"getFavourites");
    
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
                                                            
                              [self createArraysForTableView];
                             
                          }
                      }];
    
}

#pragma mark - datasource helper methods

-(void)createArraysForTableView
{
    //set up user arrays for table view
    for (int i = 0; i < [responseJKArray count]; i++)
    {
        NSDictionary *dict = [responseJKArray objectAtIndex:i];
        
        [self.user.favTitlesAr addObject:[dict objectForKey:@"title"]];
        [self.user.favWavformURLAr addObject:[dict objectForKey:@"waveform_url"]];
        [self.user.favTrackIDAr addObject:[dict objectForKey:@"id"]];
        [self.user.favTrackURIsAr addObject:[dict objectForKey:@"uri"]];
    }
    
    //create placeholders for wavformImagesAr so we can use replaceObjectAtIndex on async callbacks from cellForRowAtIndexPath    
    for (id obj in self.user.favTitlesAr)
    {
        UIImage *placeholder = [[UIImage alloc]init];
        [self.user.wavformImagesAr addObject:placeholder];
    }
    
    [self.tableView reloadData]; 
}


-(void)setHighestRowLoaded:(NSInteger)newVal
{
    if (newVal > highestRowLoaded)
        highestRowLoaded = newVal;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    delegate = (SFAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.tableView.rowHeight = 70;
    
    self.user = [SFUser sharedUserObj];
    
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

//
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([SCSoundCloud account] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Log in to see your favorites!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
        
        [alert show];
    }
// for debugging
//    else
//    {
//        [self makeUserNameRequest];
//        
//        [self getFavourites];
//    }
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
    
    UILabel *lab = (UILabel*)[cell viewWithTag:kCellSubViewTitleLabel];
    UIImageView *iv = (UIImageView*)[cell viewWithTag:kCellSubViewWavImageView];

    lab.text = [self.user.favTitlesAr objectAtIndex:indexPath.row];    
    
    self.highestRowLoaded = indexPath.row;
        
    //only download images once
    if (indexPath.row >= self.highestRowLoaded && !hasLastRowBeenReached)
    { 
        //ensure last row doesn't cause image download
        if(indexPath.row == [self.user.favTitlesAr count] - 1)
            hasLastRowBeenReached = YES;
               
        //async for scroll performance
        dispatch_queue_t queue = 
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
        
            NSURL *url = [[NSURL alloc] initWithString:[self.user.favWavformURLAr objectAtIndex:indexPath.row]];
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            //crop the image
            CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, image.size.width, image.size.height / 2)); 

            //replace UIImage for placeholder image
            UIImage *imageToInsertInAr = [UIImage imageWithCGImage:cgImage];
            [self.user.wavformImagesAr replaceObjectAtIndex:indexPath.row withObject:imageToInsertInAr];            
            
            //take image from array to ensure it's the correct one for this row
            iv.image = [self.user.wavformImagesAr objectAtIndex:indexPath.row];
           
            [iv setBackgroundColor:[UIColor blueColor]];
                        
            [(SFCustomTableViewCell*)cell setShouldResetBgColour:NO];
            
            [iv performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
                                
        });
        
        //placeholder image while image is downloading 
        iv.image = [UIImage imageNamed:@"loading_wav"];
    }
    else
    {
        //set the correct image for this row
        iv.image = [self.user.wavformImagesAr objectAtIndex:indexPath.row];        
    }
        
    return cell;
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

//play the track on soundcloud app or online
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *scURL = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud:track:%@",[self.user.favTrackIDAr objectAtIndex:indexPath.row]]]; 
                     
    if([[UIApplication sharedApplication]canOpenURL:scURL])
    {
        [[UIApplication sharedApplication] openURL:scURL];
    }
    else
    {
        NSURL *onlineURL = [NSURL URLWithString:[self.user.favTrackURIsAr objectAtIndex:indexPath.row]]; 
        [[UIApplication sharedApplication] openURL:onlineURL];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
        [self login];
    
}



























@end
