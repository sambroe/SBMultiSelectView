//
//  PKViewController.h
//  SBMultiSelectViewDemo
//
//  Created by Sam Broe on 10/16/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBMultiSelectView.h"

@interface PKViewController : UIViewController <SBMultiSelectViewDataSource, SBMultiSelectViewDelegate>

@property (nonatomic, retain) SBMultiSelectView *multiSelectView;

@end
