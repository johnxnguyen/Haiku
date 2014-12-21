//
//  HKFriendsViewController.m
//  Haiku
//
//  Created by John Nguyen on 19/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKFriendsViewController.h"
#import "SWRevealViewController.h"

@interface HKFriendsViewController ()

@end

@implementation HKFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


	#pragma mark HELPERS
// ------------------------------------------------------------------------

// SETUP
//
- (void)setupViewController {
	
	// Set left menu bar button
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
																   style:UIBarButtonItemStylePlain
																  target:self.revealViewController
																  action:@selector(revealToggle:)];
	[self.navigationItem setLeftBarButtonItem:leftButton];
	
	// Set right menu bar button
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																				 target:nil
																				 action:nil];
	[self.navigationItem setRightBarButtonItem:rightButton];
	
	// Set nav bar title
	[self.navigationItem setTitle:@"Friends"];
	
	// Set gestures (swipe to reveal menu)
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
	[self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

@end
