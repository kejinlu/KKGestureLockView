//
//  KKGestureLockView.m
//  KKGestureLockView
//
//  Created by Luke on 8/5/13.
//  Copyright (c) 2013 geeklu. All rights reserved.
//

#import "KKGestureLockView.h"
const static NSUInteger kNumberOfNodes = 9;
const static NSUInteger kNodesPerRow = 3;
const static CGFloat kNodeDefaultWidth = 60;
const static CGFloat kNodeDefaultHeight = 60;
const static CGFloat kLineDefaultWidth = 16;

const static CGFloat kTrackedLocationInvalidInContentView = -1.0;


@interface KKGestureLockView (){
    struct {
        unsigned int didBeginWithPasscode :1;
        unsigned int didEndWithPasscode : 1;
        unsigned int didCanceled : 1;
    } _delegateFlags;
}

@property (nonatomic, strong) UIView *contentView;

//Implement nodes with buttons
@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) NSMutableArray *selectedButtons;

@property (nonatomic, assign) CGPoint trackedLocationInContentView;

@end

@implementation KKGestureLockView

#pragma mark -
#pragma mark Private Methods

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIButton *)_buttonContainsThePoint:(CGPoint)point{
    for (UIButton *button in self.buttons) {
        if (CGRectContainsPoint(button.frame, point)) {
            return button;
        }
    }
    return nil;
}

- (void)_lockViewInitialize{
    self.backgroundColor = [UIColor clearColor];
    
    self.lineColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.lineWidth = kLineDefaultWidth;
    
    self.contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.contentView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    
    self.buttonSize = CGSizeMake(kNodeDefaultWidth, kNodeDefaultHeight);
    
    self.normalGestureNodeImage = [self imageWithColor:[UIColor greenColor] size:self.buttonSize];
    self.selectedGestureNodeImage = [self imageWithColor:[UIColor redColor] size:self.buttonSize];
    
    self.numberOfGestureNodes = kNumberOfNodes;
    self.gestureNodesPerRow = kNodesPerRow;
    
    self.selectedButtons = [NSMutableArray array];
    
    self.trackedLocationInContentView = CGPointMake(kTrackedLocationInvalidInContentView, kTrackedLocationInvalidInContentView);
}


#pragma mark -
#pragma mark UIView Overrides
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self _lockViewInitialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self _lockViewInitialize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    CGFloat horizontalNodeMargin = (self.contentView.bounds.size.width - self.buttonSize.width * self.gestureNodesPerRow)/(self.gestureNodesPerRow - 1);
    NSUInteger numberOfRows = ceilf((self.numberOfGestureNodes * 1.0 / self.gestureNodesPerRow));
    CGFloat verticalNodeMargin = (self.contentView.bounds.size.height - self.buttonSize.height *numberOfRows)/(numberOfRows - 1);
    
    for (int i = 0; i < self.numberOfGestureNodes ; i++) {
        int row = i / self.gestureNodesPerRow;
        int column = i % self.gestureNodesPerRow;
        UIButton *button = [self.buttons objectAtIndex:i];
        button.frame = CGRectMake(floorf((self.buttonSize.width + horizontalNodeMargin) * column), floorf((self.buttonSize.height + verticalNodeMargin) * row), self.buttonSize.width, self.buttonSize.height);
    }
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if ([self.selectedButtons count] > 0) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        UIButton *firstButton = [self.selectedButtons objectAtIndex:0];
        [bezierPath moveToPoint:[self convertPoint:firstButton.center fromView:self.contentView]];
        
        for (int i = 1; i < [self.selectedButtons count]; i++) {
            UIButton *button = [self.selectedButtons objectAtIndex:i];
            [bezierPath addLineToPoint:[self convertPoint:button.center fromView:self.contentView]];
        }
        
        if (self.trackedLocationInContentView.x != kTrackedLocationInvalidInContentView &&
            self.trackedLocationInContentView.y != kTrackedLocationInvalidInContentView) {
            [bezierPath addLineToPoint:[self convertPoint:self.trackedLocationInContentView fromView:self.contentView]];
        }
        [bezierPath setLineWidth:self.lineWidth];
        [bezierPath setLineJoinStyle:kCGLineJoinRound];
        [self.lineColor setStroke];
        [bezierPath stroke];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationInContentView = [touch locationInView:self.contentView];
    UIButton *touchedButton = [self _buttonContainsThePoint:locationInContentView];
    if (touchedButton != nil) {
        touchedButton.selected = YES;
        [self.selectedButtons addObject:touchedButton];
        self.trackedLocationInContentView = locationInContentView;
        
        if (_delegateFlags.didBeginWithPasscode) {
            [self.delegate gestureLockView:self didBeginWithPasscode:[NSString stringWithFormat:@"%d",touchedButton.tag]];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint locationInContentView = [touch locationInView:self.contentView];
    if (CGRectContainsPoint(self.contentView.bounds, locationInContentView)) {
        UIButton *touchedButton = [self _buttonContainsThePoint:locationInContentView];
        if (touchedButton != nil && [self.selectedButtons indexOfObject:touchedButton]==NSNotFound) {
            touchedButton.selected = YES;
            [self.selectedButtons addObject:touchedButton];
            if ([self.selectedButtons count] == 1) {
                //If the touched button is the first button in the selected buttons,
                //It's the beginning of the passcode creation
                if (_delegateFlags.didBeginWithPasscode) {
                    [self.delegate gestureLockView:self didBeginWithPasscode:[NSString stringWithFormat:@"%d",touchedButton.tag]];
                }
            }
        }
        self.trackedLocationInContentView = locationInContentView;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{    
    if ([self.selectedButtons count] > 0) {
        if (_delegateFlags.didEndWithPasscode) {
            NSMutableArray *passcodeArray = [NSMutableArray array];
            for (UIButton *button in self.selectedButtons) {
                [passcodeArray addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }
            
            [self.delegate gestureLockView:self didEndWithPasscode:[passcodeArray componentsJoinedByString:@","]];
        }
    }
    
    for (UIButton *button in self.selectedButtons) {
        button.selected = NO;
    }
    [self.selectedButtons removeAllObjects];
    self.trackedLocationInContentView = CGPointMake(kTrackedLocationInvalidInContentView, kTrackedLocationInvalidInContentView);
    [self setNeedsDisplay];
    

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.selectedButtons count] > 0) {
        if (_delegateFlags.didCanceled) {
            NSMutableArray *passcodeArray = [NSMutableArray array];
            for (UIButton *button in self.selectedButtons) {
                [passcodeArray addObject:[NSString stringWithFormat:@"%d",button.tag]];
            }
            
            [self.delegate gestureLockView:self didCanceledWithPasscode:[passcodeArray componentsJoinedByString:@","]];
        }
    }
    
    for (UIButton *button in self.selectedButtons) {
        button.selected = NO;
    }
    [self.selectedButtons removeAllObjects];
    self.trackedLocationInContentView = CGPointMake(kTrackedLocationInvalidInContentView, kTrackedLocationInvalidInContentView);
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Accessors
- (void)setNormalGestureNodeImage:(UIImage *)normalGestureNodeImage{
    if (_normalGestureNodeImage != normalGestureNodeImage) {
        _normalGestureNodeImage = normalGestureNodeImage;
        CGSize buttonSize = self.buttonSize;
        buttonSize.width = self.buttonSize.width > normalGestureNodeImage.size.width ? self.buttonSize.width : normalGestureNodeImage.size.width;
        buttonSize.height = self.buttonSize.height > normalGestureNodeImage.size.height ? self.buttonSize.height : normalGestureNodeImage.size.height;
        self.buttonSize = buttonSize;
        
        if (self.buttons != nil && [self.buttons count] > 0) {
            for (UIButton *button in self.buttons) {
                [button setImage:normalGestureNodeImage forState:UIControlStateNormal];
            }
        }
    }
}

- (void)setSelectedGestureNodeImage:(UIImage *)selectedGestureNodeImage{
    if (_selectedGestureNodeImage != selectedGestureNodeImage) {
        _selectedGestureNodeImage = selectedGestureNodeImage;
        
        CGSize buttonSize = self.buttonSize;
        buttonSize.width = self.buttonSize.width > selectedGestureNodeImage.size.width ? self.buttonSize.width : selectedGestureNodeImage.size.width;
        buttonSize.height = self.buttonSize.height > selectedGestureNodeImage.size.height ? self.buttonSize.height : selectedGestureNodeImage.size.height;
        self.buttonSize = buttonSize;
        
        if (self.buttons != nil && [self.buttons count] > 0) {
            for (UIButton *button in self.buttons) {
                [button setImage:selectedGestureNodeImage forState:UIControlStateSelected];
            }
        }
    }
}

- (void)setDelegate:(id<KKGestureLockViewDelegate>)delegate{
    _delegate = delegate;
    
    _delegateFlags.didBeginWithPasscode = [delegate respondsToSelector:@selector(gestureLockView:didBeginWithPasscode:)];
    _delegateFlags.didEndWithPasscode = [delegate respondsToSelector:@selector(gestureLockView:didEndWithPasscode:)];
    _delegateFlags.didCanceled = [delegate respondsToSelector:@selector(gestureLockViewCanceled:)];
}

- (void)setNumberOfGestureNodes:(NSUInteger)numberOfGestureNodes{
    if (_numberOfGestureNodes != numberOfGestureNodes) {
        _numberOfGestureNodes = numberOfGestureNodes;
        
        if (self.buttons != nil && [self.buttons count] > 0) {
            for (UIButton *button in self.buttons) {
                [button removeFromSuperview];
            }
        }
        
        NSMutableArray *buttonArray = [NSMutableArray arrayWithCapacity:numberOfGestureNodes];
        for (NSUInteger i = 0; i < numberOfGestureNodes; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.userInteractionEnabled = NO;
            button.frame = CGRectMake(0, 0, self.buttonSize.width, self.buttonSize.height);
            button.backgroundColor = [UIColor clearColor];
            if (self.normalGestureNodeImage != nil) {
                [button setImage:self.normalGestureNodeImage forState:UIControlStateNormal];
            }
            
            if (self.selectedGestureNodeImage != nil) {
                [button setImage:self.selectedGestureNodeImage forState:UIControlStateSelected];
            }
            
            [buttonArray addObject:button];
            [self.contentView addSubview:button];
        }
        self.buttons = [buttonArray copy];
    }
}
@end
