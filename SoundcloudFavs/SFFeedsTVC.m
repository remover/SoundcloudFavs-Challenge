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


//private category
@interface SFFeedsTVC ()

//array for JSON response to requests
@property (nonatomic, weak) id responseJKArray;
//user details: favorites titles etc.
@property (nonatomic, weak) SFUser *user;
//table view cell lab and image view
@property (nonatomic, weak) UILabel *titleLab;
@property (nonatomic, weak) UIImageView *wavImageView;

@property (nonatomic, assign) NSInteger highestRowLoaded;
@property (nonatomic, weak) SFAppDelegate *delegate;
@property (nonatomic, assign) BOOL hasLastRowBeenReached;
@property (nonatomic, assign) BOOL shouldShowLoginAlert;
@property (strong, nonatomic) IBOutlet UIView *noFavsView; 

-(void)doUserNameRequest;
-(void)doFavouritesRequest;
-(void)setupUserArraysForTableView;
-(void)setHighestRowLoaded:(NSInteger)newVal;

@end



@implementation SFFeedsTVC

@synthesize responseJKArray, titleLab, wavImageView, highestRowLoaded, delegate, user, hasLastRowBeenReached, shouldShowLoginAlert, noFavsView;

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
                                                                              if(self.tabBarController.selectedViewController == self)
                                                                                  shouldShowLoginAlert = NO;

                                                                          } else if (error) {
                                                                              shouldShowLoginAlert = NO;
                                                                              
                                                                              UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil 
                                                                                                                             message:@"Oops... Couldn't log you in. Please try again later." 
                                                                                                                            delegate:nil 
                                                                                                                   cancelButtonTitle:nil 
                                                                                                                   otherButtonTitles:@"OK", nil];
                                                                              [alert show];



                                                                          } else {
                                                                              shouldShowLoginAlert = YES;
                                                                              
                                                                              [self doUserNameRequest];
                                                                              
                                                                              [self doFavouritesRequest];
                                                                          }
                                                                      }];
        
        [self presentModalViewController:loginViewController animated:YES];
        
    }];
}

//get user name for user
-(void)doUserNameRequest
{    
    NSString *urlStr = @"https://api.soundcloud.com/me.json?";
    
    SCAccount *account = [SCSoundCloud account];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:urlStr]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                 } else {
                     
                     responseJKArray = [[JSONDecoder decoder]parseJSONData:data];
                     
                     self.user = [SFUser sharedUserObj];
                     
                     self.user.userName = [responseJKArray objectForKey:@"username"];
                     
                 }
             }];
    
}

//get favourites data
-(void)doFavouritesRequest
{    
    NSString *urlStr = @"https://api.soundcloud.com/me/favorites.json?";
    
    SCAccount *account = [SCSoundCloud account];

    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:urlStr]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil 
                                                                    message:@"Oops... Something went wrong. Please try again later." 
                                                                   delegate:nil 
                                                          cancelButtonTitle:nil 
                                                          otherButtonTitles:@"OK", nil];
                     [alert show];                                          

                     
                 } else {
                     
                     responseJKArray = [[JSONDecoder decoder]parseJSONData:data];
                     
                     [self setupUserArraysForTableView];
                     
                 }
             }];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    delegate = (SFAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.tableView.rowHeight = 70;
    
    self.user = [SFUser sharedUserObj];
    
    self.tabBarController.delegate = self;
    
    shouldShowLoginAlert = YES;

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setNoFavsView:nil];
    
    titleLab = nil;
    
    wavImageView = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([SCSoundCloud account] == nil && shouldShowLoginAlert)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Log in to see your favorites!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
        
        [alert show];
    }
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
    
    //prevent crash for NSNull objects returned in JSON data
    if(![[self.user.favTitlesAr objectAtIndex:indexPath.row]isMemberOfClass:[NSNull class]])
        lab.text = [self.user.favTitlesAr objectAtIndex:indexPath.row];
    
    UIImageView *iv = (UIImageView*)[cell viewWithTag:kCellSubViewWavImageView];;
    
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
        
            //prevent crash for NSNull objects returned in JSON data
            NSURL *url = nil;
            if(![[self.user.favWavformURLAr objectAtIndex:indexPath.row]isMemberOfClass:[NSNull class]])
               url = [[NSURL alloc] initWithString:[self.user.favWavformURLAr objectAtIndex:indexPath.row]];

            NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            
            //crop the image
            CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, image.size.width, image.size.height / 2)); 

            //replace UIImage for placeholder image
            UIImage *imageToInsertInAr = [UIImage imageWithCGImage:cgImage];
            [self.user.wavformImagesAr replaceObjectAtIndex:indexPath.row withObject:imageToInsertInAr];            
           
            [iv setBackgroundColor:[UIColor colorWithRed:251.0f/256.0 green:94.0f/256.0f blue:38.0f/256.0f alpha:1.0f]];
                        
            [(SFCustomTableViewCell*)cell setShouldResetBgColour:NO];
            
            dispatch_queue_t main_queue = dispatch_get_main_queue();
            dispatch_async(main_queue, ^{
                //take image from array to ensure it's the correct one for this row
                iv.image = [self.user.wavformImagesAr objectAtIndex:indexPath.row];
            });
                                
        });
        
        //placeholder image while image is downloading 
        iv.image = [UIImage imageNamed:@"loading_wav2"];
    }
    else
    {
        //set the correct image for this row
        iv.image = [self.user.wavformImagesAr objectAtIndex:indexPath.row];        
    }
        
    return cell;
}

#pragma mark - datasource helper methods

-(void)setupUserArraysForTableView
{
    //set up user arrays for table view
    for (int i = 0; i < [responseJKArray count]; i++)
    {
        NSDictionary *dict = [responseJKArray objectAtIndex:i];
        
        [self.user.favTitlesAr addObject:[dict objectForKey:@"title"]];//title
        [self.user.favWavformURLAr addObject:[dict objectForKey:@"waveform_url"]];//waveform_url
        [self.user.favTrackIDAr addObject:[dict objectForKey:@"id"]];//id
        [self.user.favTrackURIsAr addObject:[dict objectForKey:@"permalink_url"]];//permalink_url
    }
    
    //create placeholders for wavformImagesAr so we can use replaceObjectAtIndex on async callbacks from cellForRowAtIndexPath    
    for (id obj in self.user.favTitlesAr)
    {
        UIImage *placeholder = [[UIImage alloc]init];
        [self.user.wavformImagesAr addObject:placeholder];
    }
    
    [self.tableView reloadData]; 
    
    //show 'no favs view' if the user has no favs
    if(responseJKArray ==  nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"NoFavsView" owner:self options:nil];
        [self.tableView addSubview:noFavsView];
    }
}


-(void)setHighestRowLoaded:(NSInteger)newVal
{
    if (newVal > highestRowLoaded)
        highestRowLoaded = newVal;    
}

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
        //prevent crash for NSNull objects returned in JSON data
        NSURL *onlineURL = nil;
        if(![[self.user.favTrackURIsAr objectAtIndex:indexPath.row]isMemberOfClass:[NSNull class]])
        {
            onlineURL = [NSURL URLWithString:[self.user.favTrackURIsAr objectAtIndex:indexPath.row]];       
            [[UIApplication sharedApplication] openURL:onlineURL];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry, can't play that track" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
            
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //user wants to log in
    if(buttonIndex == 1)
        [self login];
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(viewController != self)
        shouldShowLoginAlert = YES;    
}

























@end
