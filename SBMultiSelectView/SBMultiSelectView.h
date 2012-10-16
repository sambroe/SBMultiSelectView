//
//  SBMultiSelectView.h
//  Parkr
//
//  Created by Sam Broe on 10/12/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBDraggableSelectionView.h"

typedef enum
{
    SBMultiSelectViewDirectionVertical = 0,
    SBMultiSelectViewDirectionHorizontal
}
SBMultiSelectViewDirection;

@class SBMultiSelectView;

@protocol SBMultiSelectViewDelegate <NSObject>

@optional
-(NSUInteger)multiSelectView:(SBMultiSelectView *)multiSelectView willSelectButtonAtIndex:(NSUInteger)index;
-(void)multiSelectView:(SBMultiSelectView *)multiSelectView didSelectButtonAtIndex:(NSUInteger)index;
-(NSUInteger)multiSelectView:(SBMultiSelectView *)multiSelectView willDeselectButtonAtIndex:(NSUInteger)index;
-(void)multiSelectView:(SBMultiSelectView *)multiSelectView didDeselectButtonAtIndex:(NSUInteger)index;

@end

@protocol SBMultiSelectViewDataSource <NSObject>

-(NSUInteger)numberOfButtonsInMultiSelectView:(SBMultiSelectView *)multiSelectView;
-(UIButton *)multiSelectView:(SBMultiSelectView *)multiSelectView buttonForIndex:(NSUInteger)index;

@end

@interface SBMultiSelectView : SBDraggableSelectionView

@property (nonatomic, assign) id <SBMultiSelectViewDataSource> dataSource;
@property (nonatomic, assign) id <SBMultiSelectViewDelegate> delegate;
@property (nonatomic, retain) NSArray *selectedIndicies;
@property (nonatomic, assign) SBMultiSelectViewDirection direction;
@property (nonatomic, assign) BOOL scaleViewsToFit;

-(id)initWithFrame:(CGRect)frame direction:(SBMultiSelectViewDirection)direction;

@end
