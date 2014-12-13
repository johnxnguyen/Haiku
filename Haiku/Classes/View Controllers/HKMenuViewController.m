//
//  HKMenuViewController.m
//  Haiku
//
//  Created by John Nguyen on 13/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKMenuViewController.h"

@interface HKMenuViewController ()

@end

@implementation HKMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


	#pragma mark USER INTERFACE
// ------------------------------------------------------------------------

- (IBAction)logoutButtonTapped:(UIButton *)sender {
	
	[PFUser logOut];
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
