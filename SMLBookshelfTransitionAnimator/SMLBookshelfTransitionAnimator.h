//
//  SMLBookshelfTransitionAnimator.h
//  Repartee
//
//  Created by Jerry Jones on 9/27/13.
//  Copyright (c) 2013 Spaceman Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SMLBookshelfTransitionDirection)
{
	SMLBookshelfTransitionLeft = 0,
	SMLBookshelfTransitionRight
};

@interface SMLBookshelfTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (assign, nonatomic) BOOL dismissing; // Required for left/right side views to be adjusted automatically

@property (assign, nonatomic) CGFloat duration; // Default is 1.5f
@property (assign, nonatomic) CGFloat bookshelfDepth; // Default is 150.0f
@property (assign, nonatomic) SMLBookshelfTransitionDirection direction; // Default is Left
@property (assign, nonatomic) BOOL dismissesWithOppositeDirection; // Default is NO

 // Always resized to fit bookshelf depth and view controller height
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;
@end
