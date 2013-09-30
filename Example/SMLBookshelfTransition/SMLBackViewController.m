//
//  SMLBackViewController.m
//  SMLBookshelfTransition
//
//  Created by Jerry Jones on 9/29/13.
//  Copyright (c) 2013 Spaceman Labs, Inc. All rights reserved.
//

#import "SMLBackViewController.h"

@interface SMLBackViewController ()

@end

@implementation SMLBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)done:(id)sender
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
