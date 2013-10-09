//
//  SMLViewController.m
//  SMLBookshelfTransition
//
//  Created by Jerry Jones on 9/29/13.
//  Copyright (c) 2013 Spaceman Labs, Inc. All rights reserved.
//

#import "SMLViewController.h"
#import "SMLBackViewController.h"
#import "SMLBookshelfTransitionAnimator.h"

@interface SMLViewController () <UIViewControllerTransitioningDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *direction;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rotation;
@property (weak, nonatomic) IBOutlet UITextField *duration;
@property (weak, nonatomic) IBOutlet UIButton *hideKeyboardButton;
@end

@implementation SMLViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.hideKeyboardButton.alpha = 0.0f;
	self.duration.delegate = self;
}

- (SMLBookshelfTransitionAnimator *)animator:(BOOL)dismissing
{
	SMLBookshelfTransitionAnimator *animator = [[SMLBookshelfTransitionAnimator alloc] init];
	
	if (dismissing) {
		animator.dismissing = YES;
	}

	animator.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left.jpg"]];
	animator.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right.jpg"]];
	
	animator.rotationDirection = self.direction.selectedSegmentIndex > 0 ? SMLBookshelfTransitionRight : SMLBookshelfTransitionLeft;
	animator.dismissesWithOppositeDirection = self.rotation.selectedSegmentIndex > 0;

	CGFloat duration = [self.duration.text floatValue];
	animator.duration = duration;
	
	return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																   presentingController:(UIViewController *)presenting
																	   sourceController:(UIViewController *)source
{
	return [self animator:NO];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	return [self animator:YES];
}

- (IBAction)show:(id)sender
{
	SMLBackViewController *backVC = [[SMLBackViewController alloc] initWithNibName:nil bundle:nil];
	backVC.transitioningDelegate = self;
	backVC.modalPresentationStyle = UIModalPresentationCustom;
	[self presentViewController:backVC animated:YES completion:NULL];
}

- (IBAction)doneEditinDuration:(id)sender
{
	[self.duration resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.hideKeyboardButton.alpha = 1.0f;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.hideKeyboardButton.alpha = 0.0f;
}

@end
