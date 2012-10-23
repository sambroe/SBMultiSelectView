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
@property (nonatomic, assign) CGPoint directionChangePoint;

-(void)getData;
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
        _thresholdForDirectionSwitch = 5.0;
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
        
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        
        if (_direction == SBMultiSelectViewDirectionHorizontal)
        {
            width = (_scaleViewsToFit) ? floorf(CGRectGetWidth(self.frame)/_buttons.count) : CGRectGetWidth(button.frame);
            height = (_scaleViewsToFit) ? CGRectGetHeight(self.frame) : CGRectGetHeight(button.frame);
            
            [button setFrame:CGRectMake(CGRectGetMaxX(lastRect), 0.0, width, height)];
        }
        else
        {
            width = (_scaleViewsToFit) ? CGRectGetWidth(self.frame) : CGRectGetWidth(button.frame);
            height = (_scaleViewsToFit) ? floorf(CGRectGetHeight(self.frame)/_buttons.count) : CGRectGetHeight(button.frame);
            
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
    _selectionState = SBMultiSelectViewSelectionStateNone;
    
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesEnded:touches withEvent:event];
    
    _selectionState = SBMultiSelectViewSelectionStateNone;
    _currentlySelectedIndex = -1;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    _selectionState = SBMultiSelectViewSelectionStateNone;
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
            [self getData];
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
            [self getData];
        }
    }
}

-(void)setDirection:(SBMultiSelectViewDirection)direction
{
    _direction = direction;
    
    [self setNeedsLayout];
}

-(void)setScaleViewsToFit:(BOOL)scaleViewsToFit
{
    _scaleViewsToFit = scaleViewsToFit;
    
    [self getData];
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

-(void)getData
{
    if (!_dataSource || ![_dataSource respondsToSelector:@selector(multiSelectView:buttonForIndex:)]) return;

    NSArray *selectedIndicies = [self.selectedIndicies copy];
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
        
        if ([selectedIndicies containsObject:@(i)])
            [button setSelected:YES];

    }
    
    [self setSelectedIndicies:@[]];
    [selectedIndicies release];
    
    [self setNeedsLayout];
}

-(void)selectButtonAtIndex:(NSUInteger)index
{
    NSUInteger newIndex = (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:willSelectButtonAtIndex:)]) ? [_delegate multiSelectView:self willSelectButtonAtIndex:index] : index;
    UIButton *button = _buttons[newIndex];
    
    if (button.isSelected) return;
    
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
    
    if (!button.isSelected) return;
    
    [button setSelected:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(multiSelectView:didDeselectButtonAtIndex:)])
    {
        [_delegate multiSelectView:self didDeselectButtonAtIndex:newIndex];
    }
}

-(void)evalutateSelectionForPoint:(CGPoint)point directon:(CGPoint)direction
{
    if (_direction == SBMultiSelectViewDirectionHorizontal)
    {
        if (self.directionVector.x != direction.x)
        {
            _directionChangePoint = point;
        }
    }
    else
    {
        if (self.directionVector.y != direction.y)
        {
            _directionChangePoint = point;
        }
    }
    
    [super evalutateSelectionForPoint:point directon:direction];
    
    [_buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        
        if (CGRectContainsPoint(button.frame, point))
        {
            if (_selectionState == SBMultiSelectViewSelectionStateNone)
            {
                _selectionState = (button.isSelected) ? SBMultiSelectViewSelectionStateDeselecting : SBMultiSelectViewSelectionStateSelecting;
                _directionChangePoint = CGPointZero;
            }
            
            if (!CGPointEqualToPoint(_directionChangePoint, CGPointZero))
            {                
                CGFloat distanceFromDirectionChange = (_direction == SBMultiSelectViewDirectionHorizontal) ? fabsf(_directionChangePoint.x - point.x) : fabsf(_directionChangePoint.y - point.y);
                
                if (distanceFromDirectionChange >= _thresholdForDirectionSwitch)
                {
                    _selectionState = (_selectionState == SBMultiSelectViewSelectionStateDeselecting) ? SBMultiSelectViewSelectionStateSelecting : SBMultiSelectViewSelectionStateDeselecting;
                    _directionChangePoint = CGPointZero;
                }
            }
            
            if (_selectionState == SBMultiSelectViewSelectionStateSelecting)
            {
                [self selectButtonAtIndex:idx];
            }
            else
            {
                [self deselectButtonAtIndex:idx];
            }
        }
        
    }];
}

@end
