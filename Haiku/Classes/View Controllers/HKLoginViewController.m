//
//  HKLoginViewController.m
//  Haiku
//
//  Created by John Nguyen on 10/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKLoginViewController.h"
#import "AppDelegate.h"

@interface HKLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation HKLoginViewController


	#pragma mark LIFE CYCLE
// ------------------------------------------------------------------------

// VIEW DID APPEAR
//
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// Clear textfields
	_emailTextField.text = @"";
	_passwordTextField.text = @"";
	
	// Already logged in?
	if ([PFUser currentUser]) {
		
		// Is user linked with facebook?
		if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
			[self syncUserProfile];
		
		// Proceed
		[self performSegueWithIdentifier:@"RevealViewControllerSegue" sender:nil];
	}
}


	#pragma mark User Interface
// ------------------------------------------------------------------------

// LOGIN BUTTON
//
- (IBAction)loginButtonTapped:(UIButton *)sender {
	
	NSString *email = _emailTextField.text;
	NSString *password = _passwordTextField.text;
	
	[PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
		
		if (!error) {
			// Proceed
			[self performSegueWithIdentifier:@"RevealViewControllerSegue" sender:nil];
			
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
															message:error.userInfo[@"error"]
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
		}
	}];
}

// FACEBOOK BUTTON
- (IBAction)faceboookButtonTapped:(UIButton *)sender {
	
	NSArray *permission = @[@"public_profile", @"email", @"user_friends"];
	
	[PFFacebookUtils logInWithPermissions:permission block:^(PFUser *user, NSError *error) {
		
		if (user) {
			// Keep FB & Parse synced
			[self syncUserProfile];
			
			// Segue to inbox
			[self performSegueWithIdentifier:@"RevealViewControllerSegue" sender:nil];
			
		} else {
			[self handleAuthError:error];
		}
	}];
}

- (IBAction)signUpButtonTapped:(UIButton *)sender {
	
	[self performSegueWithIdentifier:@"RegisterSegue" sender:@"Email"];
}


	#pragma mark URL CONNECTION DATA DELEGATE
// ------------------------------------------------------------------------

// DID RECEIVE DATA
//
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	// Store data as it comes in
	[_imageData appendData:data];
}

// DID FINISH DOWNLOADING - save image to current user
//
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// Upload to Parse
	if (_imageData) {
		
		PFFile *image = [PFFile fileWithName:@"profileImage" data:_imageData];
		[image saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			
			if (succeeded) {
				[_currentUser setObject:image forKey:kHKUserImage];
				[_currentUser saveEventually];
			}
		}];
		
	} else {
		NSLog(@"Error: no image data found");
	}
}

	#pragma mark HELPERS
// ------------------------------------------------------------------------

// SYNC USER PROFILE - keep FB Profile synced with Parse
//
- (void)syncUserProfile {
	
	// Request for current FB User
	FBRequest *request = [FBRequest requestForMe];
	
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		
		// Success
		if (!error) {
			
			// Get user data
			NSDictionary *userData = (NSDictionary*)result;
			
			NSString *facebookID = userData[@"id"];
			NSString *name = userData[@"name"];
			NSString *email = userData[@"email"];
			
			// Save details to Parse
			_currentUser = [PFUser currentUser];
						
			[_currentUser setEmail:email];
			
			// When first created, set default display name
			if ([_currentUser isNew]) {
				[_currentUser setObject:name forKey:kHKUserDisplayName];
			}
			
			// Start image download, save user when finished
			[self downloadImageWithFacebookId:facebookID];
		}
	}];
	
}

// DOWNLOAD FACEBOOK IMAGE
//
- (void)downloadImageWithFacebookId:(NSString*)facebookId {
	
	// Init imageData buffer
	_imageData = [[NSMutableData alloc] init];
	
	// Create URL
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
											  timeoutInterval:4.0f];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (!connection) {
		NSLog(@"Error: Failed to download image from Facebook");
	}
}

// HANDLE FB AUTHENTICATION ERROR
//
- (void)handleAuthError:(NSError*)error {
	
	NSString *alertTitle;
	NSString *alertText;
	
	// Error requires user action outside of app
	if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
	
		alertTitle = @"Something went wrong";
		alertText = [FBErrorUtility userMessageForError:error];
		[self showMessage:alertText withTitle:alertTitle];
		
	} else {
		// Need to find out more info to handle error within app
		if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
			NSLog(@"User cancelled");
		} else {
			// All other errors need retries. Show generic message
			alertTitle = @"Something went wrong";
			alertText = @"Please retry";
			[self showMessage:alertText withTitle:alertTitle];
		}
	}
}

// SHOW MESSAGE
//
- (void)showMessage:(NSString*)message withTitle:(NSString*)title {
	
	[[[UIAlertView alloc] initWithTitle:title
								message:message delegate:nil
					  cancelButtonTitle:@"Ok"
					  otherButtonTitles:nil] show];
}

@end
