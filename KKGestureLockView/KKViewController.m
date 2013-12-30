//
//  KKViewController.m
//  KKGestureLockView
//
//  Created by Luke on 8/5/13.
//  Copyright (c) 2013 geeklu. All rights reserved.
//

#import "KKViewController.h"
@interface KKViewController ()
@property (nonatomic, assign) NSUInteger tryTimes;
@property (nonatomic, strong) NSString *firstPasscode;
@end

@implementation KKViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.tryTimes = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.lockView.normalGestureNodeImage = [UIImage imageNamed:@"gesture_node_normal.png"];
    self.lockView.selectedGestureNodeImage = [UIImage imageNamed:@"gesture_node_selected.png"];
    self.lockView.lineColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
    self.lockView.lineWidth = 12;
    self.lockView.delegate = self;
    self.lockView.contentInsets = UIEdgeInsetsMake(150, 20, 100, 20);
    //if set autoResetSelectionState to NO, you need to manage the selection state by yourself.
    self.lockView.autoResetSelectionState = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reset:(KKGestureLockView *)gestureLockView
{
    [gestureLockView resetSelectionState];
    gestureLockView.lineColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
    gestureLockView.selectedGestureNodeImage = [UIImage imageNamed:@"gesture_node_selected.png"];
    gestureLockView.userInteractionEnabled = YES;
}

- (void)gestureLockView:(KKGestureLockView *)gestureLockView didBeginWithPasscode:(NSString *)passcode{
    NSLog(@"passcode1: %@", passcode);
}

- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)passcode{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@""
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];

    NSLog(@"passcode2: %@", passcode);
    if (!gestureLockView.autoResetSelectionState) {
        gestureLockView.userInteractionEnabled = NO;
    }
    if (self.tryTimes == 0) {
        self.firstPasscode = passcode;
        alert.message = [NSString stringWithFormat:@"第一次输入的密码是：\n%@", passcode];
        [alert show];
        [self reset:gestureLockView];
    } else {
        if ([passcode isEqualToString:self.firstPasscode]) {
            alert.message = @"两次密码一样!";
            [alert show];
            [self reset:gestureLockView];
        } else {
            alert.message = @"两次密码不一样!";
            [alert show];
            UIImage *selectedImage = [UIImage imageNamed:@"gesture_node_error"];
            [gestureLockView redrawOnlySelectionWithLineColor:[UIColor redColor] selectedImage:selectedImage];
            [self performSelector:@selector(reset:) withObject:gestureLockView afterDelay:1];
        }
    }
    self.tryTimes += 1;
}
@end
