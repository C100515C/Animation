//
//  UIView+PullToRefreshView.m
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "UIView+PullToRefreshView.h"

@implementation UIView (PullToRefreshView)
- (CGPoint)jElasticPullToRefresh_centerUsePresentationLayerIfPossible:(BOOL)usePresentationLayerIfPossible {
    if (usePresentationLayerIfPossible && self.layer.presentationLayer) {
        CALayer *layer = (CALayer *)[self.layer presentationLayer];
        return layer.position;
    } else {
        return self.center;
    }
}
@end
