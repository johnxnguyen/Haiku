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

@end

@implementation HKLoginViewController


	#pragma mark LIFE CYCLE
// ------------------------------------------------------------------------

// VIEW DID APPEAR
//
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
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
}

// FACEBOOK BUTTON
- (IBAction)faceboookButtonTapped:(UIButton *)sender {
	
	NSArray *permission = @[@"public_profile", @"email", @"user_friends"];
	
	[PFFacebookUtils logInWithPermissions:permission block:^(PFUser *user, NSError *error) {
		
		if (user) {
			// Keep FB & Parse synced
			[self syncUserProfile];
			
			// Segue to inbox
			
		} else {
			if (error) {
				// Error
				NSLog(@"Error loggin in: %@", error.userInfo);
				
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
																message:@"Something went wrong. Please try again."
															   delegate:nil
													  cancelButtonTitle:@"Ok"
													  otherButtonTitles:nil];
				[alert show];
				
			} else {
				// Cancelled
				NSLog(@"The user cancelled FB authentication");
			}
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

// DID FINISH DOWNLOADING
//
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// Upload to Parse
	if (_imageData) {
		
		PFFile *image = [PFFile fileWithData:_imageData];
		[[PFUser currentUser] setObject:image forKey:kHKUserImage];
		[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			
			if (!error) {
				NSLog(@"Image successfully uploaded to Parse");
			} else {
				NSLog(@"Error Saving User: %@", error.userInfo);
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
			
			[self downloadImageWithFacebookId:facebookID];
			
			// Save details to Parse
			PFUser *currentUser = [PFUser currentUser];
			
			// When first created, set default display name
			if ([currentUser isNew]) {
				[currentUser setObject:name forKey:kHKUserDisplayName];
			}
			
			[currentUser setEmail:email];
			[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				
				if (!error) {
					NSLog(@"User successfully updated");
				} else {
					NSLog(@"Error Saving User: %@", error.userInfo);
				}
			}];
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

@end
