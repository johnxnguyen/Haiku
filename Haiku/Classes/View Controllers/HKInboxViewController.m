//
//  HKInboxViewController.m
//  Haiku
//
//  Created by John Nguyen on 13/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKInboxViewController.h"
#import "SWRevealViewController.h"

@interface HKInboxViewController ()

@end

@implementation HKInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Set left menu bar button
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
																   style:UIBarButtonItemStylePlain
																  target:self.revealViewController
																  action:@selector(revealToggle:)];
	[self.navigationItem setLeftBarButtonItem:leftButton];
	
	// Set nav bar title
	[self.navigationItem setTitle:@"Inbox"];
	
	// Set gestures (swipe to reveal menu)
	[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
	[self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
