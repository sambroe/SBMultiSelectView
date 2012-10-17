//
//  UIColor+Random.m
//  ScoreCenter
//
//  Created by Matthew Brochstein on 6/4/12.
//  Copyright (c) 2012 Expand The Room. All rights reserved.
//

#import "UIColor+Random.h"

@implementation UIColor (Random)

+ (UIColor *) randomColor
{
	return [UIColor randomColorWithAlpha:1.0];
}

+ (UIColor *) randomColorWithAlpha:(CGFloat)alpha
{
	CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
