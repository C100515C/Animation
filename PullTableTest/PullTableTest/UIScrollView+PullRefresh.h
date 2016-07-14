//
//  UIScrollView+PullRefresh.h
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleView.h"

@interface UIScrollView (PullRefresh)
@property (nonatomic,strong) CircleView *header;
-(void)addHeaderCircle:(void(^)(void))finish and:(void (^)(void))option;

@end
