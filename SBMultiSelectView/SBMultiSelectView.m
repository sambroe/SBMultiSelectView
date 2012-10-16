//
//  SBMultiSelectView.m
//  Parkr
//
//  Created by Sam Broe on 10/12/12.
//  Copyright (c) 2012 Sam Broe. All rights reserved.
//

#import "SBMultiSelectView.h"

@interface SBMultiSelectView ()

@property (nonatomic, readonly) NSUInteger numButtons;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) UIView *buttonsView;
@property (nonatomic, retain) UIView *touchInterceptorView;
@property (nonatomic, assign) NSInteger currentlySelectedIndex;

-(void)setup;
-(void)selectButtonAtIndex:(NSUInteger)index;
-(void)deselectButtonAtIndex:(NSUInteger)index;

@end

@implementation SBMultiSelectView

@synthesize selectedIndicies = _selectedIndicies;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.buttonsView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_buttonsView];
        
        self.touchInterceptorView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_touchInterceptorView];
        
        _currentlySelectedIndex = -1;
        _direction = SBMultiSelectViewDirectionVertical;
        _scaleViewsToFit = NO;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame direction:(SBMultiSelectViewDirection)direction
{
    if (self = [self initWithFrame:frame])
    {
        self.direction = direction;
    }
    return self;
}

-(void)dealloc
{
    self.buttons = nil;
    self.buttonsView = nil;
    self.touchInterceptorView = nil;
    
    [super dealloc];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    __block CGRect lastRect = CGRectZero;
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        
        CGFloat width = (_scaleViewsToFit) ? floorf(CGRectGetWidth(self.frame)/_buttons.count) : CGRectGetWidth(button.frame);
        CGFloat height = (_scaleViewsToFit) ? floorf(CGRectGetHeight(self.frame)/_buttons.count) : CGRectGetHeight(button.frame);
        
        if (_direction == SBMultiSelectViewDirectionHorizontal)
        {
            [button setFrame:CGRectMake(CGRectGetMaxX(lastRect), 0.0, width, height)];
        }
        else
        {
            [button setFrame:CGRectMake(0.0, CGRectGetMaxY(lastRect), width, height)];
        }

        lastRect = button.frame;
        
    }];
    
    [_buttonsView setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetMaxY(lastRect))];
    [_touchInterceptorView setFrame:_buttonsView.frame];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return _touchInterceptorView;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    _currentlySelectedIndex = -1;
}

#pragma mark - Getters/Setters

-(void)setDataSource:(id<SBMultiSelectViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        [_dataSource release];
        _dataSource = [dataSource retain];
        
        if (_dataSource && _delegate)
        {
            [self setup];
        }
    }
}

-(void)setDelegate:(id<SBMultiSelectViewDelegate>)delegate
{
    if (_delegate != delegate)
    {
        [_delegate release];
        _delegate = [delegate retain];
        
        if (_dataSource && _delegate)
        {
            [self setup];
        }
    }
}

-(void)setDirection:(SBMultiSelectViewDirection)direction
{
    _direction = direction;
    
    [self setNeedsLayout];
}

-(NSUInteger)numButtons
{
    return (_dataSource && [_dataSource respondsToSelector:@selector(numberOfButtonsInMultiSelectView:)]) ? [_dataSource numberOfButtonsInMultiSelectView:self] : 0;
}

-(void)setSelectedIndicies:(NSArray *)selectedIndicies
{
    if (_selectedIndicies != selectedIndicies)
    {
        [_selectedIndicies release];
        _selectedIndicies = [selectedIndicies retain];
        
        [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            
            [button setSelected:NO];
            
        }];
        
        [_selectedIndicies enumerateObjectsUsingBlock:^(NSNumber *index, NSUInteger idx, BOOL *stop) {
            
            [self selectButtonAtIndex:index.unsignedIntegerValue];
            
        }];
    }
}

-(NSArray *)selectedIndicies
{
    __block NSMutableArray *buttons = [NSMutableArray array];
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        
        if (button.selected)
            [buttons addObject:@(idx)];
        
    }];
    
    return buttons;
}

-(UIView *)viewForPointLocation
{
    return _touchInterceptorView;
}

#pragma mark - Private Methods

-(void)setup
{
    if (!_dataSource || ![_dataSource respondsToSelector:@selector(multiSelectView:buttonForIndex:)]) return;
    
    self.buttons = [NSMutableArray array];
    
    [_buttonsView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    UIButton *button = nil;
    
    for (NSUInteger i = 0; i < self.numButtons; i++)
    {
        button = [_dataSource multiSelectView:self buttonForIndex:i];
        [button setSelected:NO];
        
        [_buttons addObject:button];
        [_buttonsView addSubview:button];
    }
    
    [self setSelectedIndicies:@[]];
    
    [self setNeedsLayout];
}

-(void)selectButtonAtIndex:(NSUInteger)index
{
    NSUInteger newIndex = (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:willSelectButtonAtIndex:)]) ? [_delegate multiSelectView:self willSelectButtonAtIndex:index] : index;
    UIButton *button = _buttons[newIndex];
    
    [button setSelected:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:didSelectButtonAtIndex:)])
    {
        [_delegate multiSelectView:self didSelectButtonAtIndex:newIndex];
    }
}

-(void)deselectButtonAtIndex:(NSUInteger)index
{
    NSUInteger newIndex = (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:willDeselectButtonAtIndex:)]) ? [_delegate multiSelectView:self willDeselectButtonAtIndex:index] : index;
    UIButton *button = _buttons[newIndex];
    
    [button setSelected:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:didDeselectButtonAtIndex:)])
    {
        [_delegate multiSelectView:self didDeselectButtonAtIndex:newIndex];
    }
}

-(void)evalutateSelectionForPoint:(CGPoint)point directon:(CGPoint)direction
{
    [super evalutateSelectionForPoint:point directon:direction];
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        
        if (CGRectContainsPoint(button.frame, point))
        {
            NSInteger newDir = (_direction == SBMultiSelectViewDirectionVertical) ? direction.y : direction.x;
            NSInteger curDir = (_direction == SBMultiSelectViewDirectionVertical) ? self.currentYDir : self.currentXDir;
            
            if (_currentlySelectedIndex != idx || (newDir != 0 && newDir != curDir))
            {
                if (button.selected)
                {
                    [self deselectButtonAtIndex:idx];
                }
                else
                {
                    [self selectButtonAtIndex:idx];
                }
                
                _currentlySelectedIndex = idx;
            }
        }
        
    }];
}

@end
