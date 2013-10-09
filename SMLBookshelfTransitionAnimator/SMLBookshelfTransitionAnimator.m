//
//  SMLBookshelfTransitionAnimator.m
//  Repartee
//
//  Created by Jerry Jones on 9/27/13.
//  Copyright (c) 2013 Spaceman Labs. All rights reserved.
//

#import "SMLBookshelfTransitionAnimator.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation SMLBookshelfTransitionAnimator

- (id)init
{
	self = [super init];
	if (nil == self) {
		return nil;
	}
	
	self.duration = 1.5f;
	self.bookshelfDepth = 150.0f;
	self.perspective = -1.0f/1000.0f;
	self.direction = SMLBookshelfTransitionLeft;
	self.dismissesWithOppositeDirection = NO;
	
	return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
	return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
	// Grab the from and to view controllers from the context
	UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIView *containerView = transitionContext.containerView;
	UIView *fromView = fromViewController.view;
	
	CGRect sideLFrame = CGRectMake(0, 0, self.bookshelfDepth, fromView.frame.size.height);
	CGRect sideRFrame = CGRectMake(0, 0, self.bookshelfDepth, fromView.frame.size.height);
	
	if (self.rightView) {
		self.rightView.frame = sideRFrame;
	} else {
		self.rightView = [[UIView alloc] initWithFrame:sideRFrame];
		self.rightView.backgroundColor = [UIColor redColor];
	}
	
	if (self.leftView) {
		self.leftView.frame = sideLFrame;
	} else {
		self.leftView = [[UIView alloc] initWithFrame:sideLFrame];
		self.leftView.backgroundColor = [UIColor blueColor];
	}
	
	BOOL switchLeftAndRight = (self.dismissing);
	
	UIView *leftView = switchLeftAndRight ? self.rightView : self.leftView;
	UIView *rightView = switchLeftAndRight ? self.leftView : self.rightView;
		
	[containerView addSubview:toViewController.view];
	[containerView addSubview:leftView];
	[containerView addSubview:rightView];
	
	UIView *frontSnapshot = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
	UIView *backSnapshot = [toViewController.view snapshotViewAfterScreenUpdates:YES];
	UIView *rightSnapshot = [rightView snapshotViewAfterScreenUpdates:YES];
	UIView *leftSnapshot = [leftView snapshotViewAfterScreenUpdates:YES];
	[containerView addSubview:frontSnapshot];
	[containerView addSubview:backSnapshot];
	[containerView addSubview:leftSnapshot];
	[containerView addSubview:rightSnapshot];
	
	toViewController.view.frame = fromViewController.view.bounds;
	
	UIView *perspectiveView = [[UIView alloc] initWithFrame:containerView.bounds];
	perspectiveView.backgroundColor = [UIColor blackColor];
	
	CATransform3D perspective = CATransform3DIdentity;
	perspective.m34 = self.perspective;
	perspectiveView.layer.sublayerTransform = perspective;
	
	[containerView addSubview:perspectiveView];
	
	// transform layer owns the 3d layout we're going to create
	// rotating a transform layer rotates the stuff inside it in real 3d space
	CATransformLayer *transformLayer = [CATransformLayer layer];
	transformLayer.frame = containerView.bounds;
	
	[perspectiveView.layer addSublayer:transformLayer];
		
	// the front layer of the bookshelf; this is just the current view
	UIView *frontView = frontSnapshot;
	frontView.layer.doubleSided = NO;
	
	[transformLayer addSublayer:frontView.layer];

	// move the layer towards the screen, to make space for the sides
	frontView.layer.zPosition = self.bookshelfDepth * .5f;

	// move the whole transform layer back, so the front layer is in the same place it started
	transformLayer.zPosition = self.bookshelfDepth * -.5f;
	
	// side on the left--substitute your wood grain or whatever here
	CALayer *sideL = leftSnapshot.layer;
	sideL.frame = sideLFrame;
	
	// rotate, and move by the width of the side to get it flush with the edges
	sideL.transform = CATransform3DTranslate(CATransform3DMakeRotation(-M_PI_2, 0, 1, 0), 0, 0, self.bookshelfDepth * .5f);
	[transformLayer addSublayer:sideL];
	
	// side on the right
	CALayer *sideR = rightSnapshot.layer;
	sideR.frame = sideRFrame;
	
	// rotate, and move by the width of the front plus the width of the side, to get it flush
	sideR.transform = CATransform3DTranslate(CATransform3DMakeRotation(M_PI_2, 0, 1, 0), 0, 0, frontView.frame.size.width - self.bookshelfDepth * .5f);
	[transformLayer addSublayer:sideR];
	
	UIView *backView = backSnapshot;
	backView.layer.doubleSided = NO;

	// rotate the back completely around, and move it away from the viewer to make space for the sides
	backView.layer.transform = CATransform3DTranslate(CATransform3DMakeRotation(M_PI, 0, 1, 0), 0, 0, self.bookshelfDepth * .5f);
	[transformLayer addSublayer:backView.layer];
	
	
	CGFloat duration = self.duration;
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	[CATransaction setCompletionBlock:^{
		[leftSnapshot removeFromSuperview];
		[rightSnapshot removeFromSuperview];
		[frontSnapshot removeFromSuperview];
		[backSnapshot removeFromSuperview];
		[perspectiveView removeFromSuperview];
		[containerView addSubview:toViewController.view];
		[transitionContext completeTransition:YES];
	}];
	
	// flip the transform layer around, and move it back such that the back layer is now where the front layer was
	
	CAKeyframeAnimation *animation;
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	animation.calculationMode = kCAAnimationPaced;
	animation.duration = duration;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	SMLBookshelfTransitionDirection direction = self.direction;

	// Reverse our direction if we are dismissing, and the dismissesWithOppositeDirection flag is set
	if (self.dismissing && self.dismissesWithOppositeDirection) {
		switch (self.direction) {
			case SMLBookshelfTransitionLeft: {
				direction = SMLBookshelfTransitionRight;
				break;
			}
			case SMLBookshelfTransitionRight: {
				direction = SMLBookshelfTransitionLeft;
				break;
			}
			default:
				break;
		}
	}
	
	double midRotation = direction == SMLBookshelfTransitionRight ? M_PI_2 : -1.0 * M_PI_2;
	CATransform3D transform = CATransform3DIdentity;
	NSValue *startValue = [NSValue valueWithCATransform3D:transform];
	transform = CATransform3DTranslate(CATransform3DRotate(CATransform3DIdentity, midRotation, 0, 1, 0), 0, 0, (self.bookshelfDepth / 1000.0f));
	NSValue *midValue = [NSValue valueWithCATransform3D:transform];
	transform = CATransform3DTranslate(CATransform3DRotate(CATransform3DIdentity, M_PI, 0, 1, 0), 0, 0, (self.bookshelfDepth / 1000.0f));
	NSValue *finalValue = [NSValue valueWithCATransform3D:transform];
	animation.values = @[startValue, midValue, finalValue];
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.removedOnCompletion = NO;
	theGroup.fillMode = kCAFillModeForwards;
	theGroup.animations = @[animation];
	
	// set the timing function for the group and the animation duration
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.duration = duration;
	[transformLayer addAnimation:theGroup forKey:@"transform.rotation.z"];
	
	[CATransaction commit];
}

@end
