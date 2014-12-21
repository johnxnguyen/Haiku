//
//  HKSettingsViewController.m
//  Haiku
//
//  Created by John Nguyen on 19/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKSettingsViewController.h"
#import "SWRevealViewController.h"

@interface HKSettingsViewController ()

@end

@implementation HKSettingsViewController

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
	
	// Set nav bar title
	[self.navigationItem setTitle:@"Settings"];
	
	// Set gestures (swipe to reveal menu)
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
	[self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

@end
