//
//  HKMenuViewController.m
//  Haiku
//
//  Created by John Nguyen on 13/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKMenuViewController.h"
#import <ParseUI/ParseUI.h>

@interface HKMenuViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *displayNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation HKMenuViewController

// INIT
//
- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if (self = [super initWithCoder:aDecoder]) {
		_menuItems = @[@"Inbox", @"Friends", @"Settings", @"Log Out"];
	}
	return self;
}

// VIEW DID LOAD
//
- (void)viewDidLoad {
    [super viewDidLoad];
	
	_tableView.dataSource = self;
	_tableView.delegate = self;
	
	// Configure imageview
	_imageView.layer.cornerRadius = _imageView.frame.size.width / 2.0;
	_imageView.layer.masksToBounds = YES;
	
	// Set UI
	_displayNameLabel.text = [[PFUser currentUser] valueForKey:kHKUserDisplayName];
	_imageView.file = [[PFUser currentUser] valueForKey:kHKUserImage];
	[_imageView loadInBackground];
}

// MEMORY WARNING
//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	if ([segue.identifier isEqualToString:@"NavigationSegue"]) {
		
		UINavigationController *target = segue.destinationViewController;
		UIStoryboard *storyboard = self.storyboard;
		UIViewController *vc;
		NSString *menuItem = sender;
		
		if ([menuItem isEqualToString:@"Inbox"])
			vc = [storyboard instantiateViewControllerWithIdentifier:@"InboxViewController"];
		else if ([menuItem isEqualToString:@"Friends"])
			vc = [storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
		else if ([menuItem isEqualToString:@"Settings"])
			vc = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
	
		if (vc)
			[target setViewControllers:@[vc]];
	}
}


	#pragma mark USER INTERFACE
// ------------------------------------------------------------------------



	#pragma mark TABLE VIEW DATA SOURCE
// ------------------------------------------------------------------------

// SECTIONS
//
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// ROWS
//
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _menuItems.count;
}

// CELL
//
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	
	// Configure cell
	cell.textLabel.text = _menuItems[indexPath.row];
	
	return cell;
}


	#pragma mark TABLE VIEW DELEGATE
// ------------------------------------------------------------------------

// DID SELECT - response to menu selection
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Which menu item?
	NSString *menuItem = _menuItems[indexPath.row];
	
	if ([menuItem isEqualToString:@"Log Out"]) {
		[PFUser logOut];
		[self dismissViewControllerAnimated:YES completion:nil];
		
	} else {
		[self performSegueWithIdentifier:@"NavigationSegue" sender:menuItem];
	}
}


@end
