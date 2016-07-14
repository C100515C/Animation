//
//  CircleView.h
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleView : UIView
@property (assign, nonatomic) BOOL observing;
@property (nonatomic,copy) void (^startAnimation)(void);
@property (nonatomic,copy) void (^stopAnimation)(void);
- (void)stopCircleLoading;
- (void)startCircleAnimating;

@end
