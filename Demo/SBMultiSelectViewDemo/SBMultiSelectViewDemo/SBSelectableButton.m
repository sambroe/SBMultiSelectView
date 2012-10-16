//
//  SBSelectableButton.m
//  SBMultiSelectViewDemo
//
//  Created by Sam Broe on 10/16/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import "SBSelectableButton.h"
#import "UIColor+Random.h"

@interface SBSelectableButton ()

@property (nonatomic, retain) UIView *bgView;

@end

@implementation SBSelectableButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.bgView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        [_bgView setBackgroundColor:[UIColor randomColor]];
        [_bgView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    
        [self addSubview:_bgView];
    }
    return self;
}

-(void)dealloc
{
    self.bgView = nil;
    
    [super dealloc];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [_bgView setAlpha:(self.selected ? 1.0 : 0.5)];
}

@end
