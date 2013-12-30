//
//  KKViewController.h
//  KKGestureLockView
//
//  Created by Luke on 8/5/13.
//  Copyright (c) 2013 geeklu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGestureLockView.h"

@interface KKViewController : UIViewController<KKGestureLockViewDelegate>

@property (nonatomic, strong) IBOutlet KKGestureLockView *lockView;
@end
