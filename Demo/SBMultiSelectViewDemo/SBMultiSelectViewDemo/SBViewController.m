//
//  SBViewController.m
//  SBMultiSelectViewDemo
//
//  Created by Sam Broe on 10/16/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import "SBViewController.h"
#import "SBSelectableButton.h"

@interface SBViewController ()

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.multiSelectView = [[[SBMultiSelectView alloc] initWithFrame:CGRectZero direction:SBMultiSelectViewDirectionVertical] autorelease];
    [_multiSelectView setDataSource:self];
    [_multiSelectView setDelegate:self];
    [_multiSelectView setScaleViewsToFit:YES];
    [self.view addSubview:_multiSelectView];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [_multiSelectView setDirection:SBMultiSelectViewDirectionHorizontal];
    }
    else
    {
        [_multiSelectView setDirection:SBMultiSelectViewDirectionVertical];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_multiSelectView setFrame:CGRectMake(20.0, 20.0, CGRectGetWidth(self.view.bounds) - 40.0, CGRectGetHeight(self.view.bounds) - 40.0)];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - SBMultiSelectViewDataSource/SBMultiSelectViewDelegate

-(NSUInteger)numberOfButtonsInMultiSelectView:(SBMultiSelectView *)multiSelectView
{
    return 10;
}

-(UIButton *)multiSelectView:(SBMultiSelectView *)multiSelectView buttonForIndex:(NSUInteger)index
{
    UIButton *button = [SBSelectableButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:[NSString stringWithFormat:@"BUTTON %i", index] forState:UIControlStateNormal];
    [button setTitle:[NSString stringWithFormat:@"BUTTON %i SELECTED", index] forState:UIControlStateSelected];
    [button setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame) - 40.0, 40.0)];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    
    return button;
}


@end
