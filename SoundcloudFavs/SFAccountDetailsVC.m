//
//  SFAccountDetailsVC.m
//  SoundcloudFavs
//
//  Created by Donal O'Brien on 16/02/2012.
//  Copyright (c) 2012 Queens University Belfast. All rights reserved.
//

#import "SFAccountDetailsVC.h"
#import "SFFeedsTVC.h"
#import "SCAPI.h"


@implementation SFAccountDetailsVC
@synthesize statusLabel;
@synthesize loginAndOutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction)logInOrOut:(id)sender 
{
    id vc = [self.tabBarController.viewControllers objectAtIndex:0];
    
    if([SCSoundCloud account] == nil)
    {
        if ([vc respondsToSelector:@selector(logIn)])    
             [vc login];       
    }
    else
    {
        [SCSoundCloud removeAccess];
        
        SFFeedsTVC *feeds = [self.storyboard instantiateViewControllerWithIdentifier:@"tableViewController"];
                
        NSArray *arr = [NSArray arrayWithObjects:feeds, self, nil];
        
        self.tabBarController.viewControllers = arr;
    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setStatusLabel:nil];
    [self setLoginAndOutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
