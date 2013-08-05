//
//  KKGestureLockView.h
//  KKGestureLockView
//
//  Created by Luke on 8/5/13.
//  Copyright (c) 2013 geeklu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KKGestureLockView;

@protocol KKGestureLockViewDelegate <NSObject>
@optional
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didBeginWithPasscode:(NSString *)passcode;

- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)passcode;

- (void)gestureLockView:(KKGestureLockView *)gestureLockView didCanceledWithPasscode:(NSString *)passcode;
@end

@interface KKGestureLockView : UIView

@property (nonatomic, assign) NSUInteger numberOfGestureNodes;
@property (nonatomic, assign) NSUInteger gestureNodesPerRow;

@property (nonatomic, strong) UIImage *normalGestureNodeImage;
@property (nonatomic, strong) UIImage *selectedGestureNodeImage;

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, strong, readonly) UIView *contentView;//the container of the gesture notes
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@property (nonatomic, weak) id<KKGestureLockViewDelegate> delegate;

@end
