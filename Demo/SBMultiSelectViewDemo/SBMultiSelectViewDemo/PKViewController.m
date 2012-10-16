//
//  PKViewController.m
//  SBMultiSelectViewDemo
//
//  Created by Sam Broe on 10/16/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import "PKViewController.h"
#import "UIColor+Random.h"

@interface PKViewController ()

@end

@implementation PKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.multiSelectView = [[[SBMultiSelectView alloc] initWithFrame:CGRectZero direction:SBMultiSelectViewDirectionVertical] autorelease];
    [_multiSelectView setDataSource:self];
    [_multiSelectView setDelegate:self];
    [self.view addSubview:_multiSelectView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_multiSelectView setFrame:CGRectMake(20.0, 20.0, CGRectGetWidth(self.view.frame) - 40.0, CGRectGetHeight(self.view.frame) - 40.0)];
}

#pragma mark - SBMultiSelectViewDataSource/SBMultiSelectViewDelegate

-(NSUInteger)numberOfButtonsInMultiSelectView:(SBMultiSelectView *)multiSelectView
{
    return 10;
}

-(UIButton *)multiSelectView:(SBMultiSelectView *)multiSelectView buttonForIndex:(NSUInteger)index
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor randomColor]];
    [button setTitle:[NSString stringWithFormat:@"BUTTON %i", index] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"BUTTON %i SELECTED", index] forState:UIControlStateSelected];
    [button setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame) - 40.0, 40.0)];
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    return button;
}

@end
