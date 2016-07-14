//
//  UIScrollView+PullRefresh.m
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "UIScrollView+PullRefresh.h"
#import <objc/runtime.h>

static const void *headerKey = &headerKey;

@implementation UIScrollView (PullRefresh)
@dynamic header;
-(CircleView*)header{
    return objc_getAssociatedObject(self, headerKey);
}
-(void)setHeader:(CircleView *)header{
    objc_setAssociatedObject(self, headerKey, header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)addHeaderCircle:(void(^)(void))finish and:(void (^)(void))option{
    if (!self.header) {
        CircleView *header = [[CircleView alloc] initWithFrame:CGRectZero];
        self.header = header;
        [self addSubview:header];
        self.header.observing = YES;
    }
    if (finish) {
        self.header.stopAnimation = finish;
    }
    
    if (option) {
        self.header.startAnimation = option;
    }
}

@end
