//
//  UIView+PullToRefreshView.h
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PullToRefreshView)
- (CGPoint)jElasticPullToRefresh_centerUsePresentationLayerIfPossible:(BOOL)usePresentationLayerIfPossible;
@end
