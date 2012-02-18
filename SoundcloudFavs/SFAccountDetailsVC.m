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
#import "SFUser.h"

//private category
@interface SFAccountDetailsVC ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginAndOutButton;
@end


@implementation SFAccountDetailsVC
@synthesize statusLabel, loginAndOutButton;

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
    id tvc = [self.tabBarController.viewControllers objectAtIndex:0];
    
    if([SCSoundCloud account] == nil)
    {
        if ([tvc respondsToSelector:@selector(login)])    
             [tvc login];       
    }
    // log out
    else
    {
        [SCSoundCloud removeAccess];
        
        [[SFUser sharedUserObj]purgeUserData];
        
        self.tabBarController.delegate = nil;
        
        //remove user data from tv
        SFFeedsTVC *feeds = [self.storyboard instantiateViewControllerWithIdentifier:@"tableViewController"];                
        NSArray *arr = [NSArray arrayWithObjects:feeds, self, nil];        
        self.tabBarController.viewControllers = arr;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //force loading of view so interface can be updated even when not displayed
    if(self.view)
    {
        if([keyPath isEqualToString:@"userName"])
        {
            if([SFUser sharedUserObj].userName)
            {            
                self.statusLabel.text = [NSString stringWithFormat:@"Logged in: %@", [SFUser sharedUserObj].userName];
                [self.loginAndOutButton setTitle:@"Log out" forState:UIControlStateNormal];
            }
            else
            {            
                self.statusLabel.text = @"You are logged out";
                [self.loginAndOutButton setTitle:@"Log in" forState:UIControlStateNormal];
            }
        }
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

-(void)awakeFromNib
{    
    //update UI when userName property changes
    [[SFUser sharedUserObj] addObserver:self forKeyPath:@"userName" options:NSKeyValueObservingOptionNew context:nil];
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
