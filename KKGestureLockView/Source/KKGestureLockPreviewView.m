//
//  KKGestureLockPreviewView.m
//  KKGestureLockView
//
//  Created by Luke on 3/11/14.
//  Copyright (c) 2014 geeklu. All rights reserved.
//

#import "KKGestureLockPreviewView.h"

@implementation KKGestureLockPreviewView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)setPasscode:(NSString *)passcode{
    _passcode = passcode;
    
    
    for (UIButton *button in self.buttons) {
        if (button.selected) {
            button.selected = NO;
        }
    }
    [self.selectedButtons removeAllObjects];
    
    NSArray *passcodeComponents = [passcode componentsSeparatedByString:@","];
    for (NSString *indexString in passcodeComponents) {
        NSInteger index = [indexString integerValue];
        if (index < [self.buttons count]) {
            UIButton *button = [self.buttons objectAtIndex:index];
            button.selected = YES;
            [self.selectedButtons addObject:button];
        }
    }
    
    [self setNeedsDisplay];
}

@end
