//
//  CircleView.m
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "CircleView.h"
#import "UIView+PullToRefreshView.h"

// ContentOffset
static NSString *const LYJElasticPullToRefreshContentOffset = @"contentOffset";
// ContentInset
static NSString *const LYJElasticPullToRefreshContentInset = @"contentInset";
// Frame
static NSString *const LYJElasticPullToRefreshFrame = @"frame";
// PanGestureRecognizerState
static NSString *const LYJElasticPullToRefreshPanGestureRecognizerState = @"panGestureRecognizer.state";
static NSString *const RotationAnimation = @"RotationAnimation";

// MaxHeight
static CGFloat const LYJElasticPullToRefreshWaveMaxHeight = 70.0;
// MinOffsetToPull
static CGFloat const LYJElasticPullToRefreshMinOffsetToPull = 150.0;
// LoadingContentInset
static CGFloat const LYJElasticPullToRefreshLoadingContentInset = 80.0;
// LoadingViewSize
static CGFloat const LYJElasticPullToRefreshLoadingViewSize = 15.0;

@interface CircleView ()

@property (strong, nonatomic)  CAShapeLayer *circleLayer;
@property (strong,nonatomic) CALayer *contentLayer;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) CADisplayLink *displayLink;

@property (assign, nonatomic) CATransform3D identityTransform;

@property (assign,nonatomic)  CGPoint point;
@property (assign,nonatomic) CGFloat changeY;
@property (assign,nonatomic) CGFloat changeX;
@property (assign,nonatomic) BOOL isAnimation;

@end

@implementation CircleView

#pragma mark - property
-(CAShapeLayer*)circleLayer{
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
    }
    return _circleLayer;
}
-(CGFloat)changeY{
    return  _changeY*(-1.0);
}
- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];

    }
    return _shapeLayer;
}
- (void)setObserving:(BOOL)observing {
    _observing = observing;
    
    UIScrollView *scrollView = [self scrollView];
    if (!scrollView) {
        return;
    } else {
        if (observing) {
            [scrollView addObserver:self forKeyPath:LYJElasticPullToRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
            [scrollView addObserver:self forKeyPath:LYJElasticPullToRefreshContentInset options:NSKeyValueObservingOptionNew context:nil];
            [scrollView addObserver:self forKeyPath:LYJElasticPullToRefreshFrame options:NSKeyValueObservingOptionNew context:nil];
            [scrollView addObserver:self forKeyPath:LYJElasticPullToRefreshPanGestureRecognizerState options:NSKeyValueObservingOptionNew context:nil];
        } else {
            [scrollView removeObserver:self forKeyPath:LYJElasticPullToRefreshContentOffset];
            [scrollView removeObserver:self forKeyPath:LYJElasticPullToRefreshContentInset];
            [scrollView removeObserver:self forKeyPath:LYJElasticPullToRefreshFrame];
            [scrollView removeObserver:self forKeyPath:LYJElasticPullToRefreshPanGestureRecognizerState];
        }
    }
}
- (UIScrollView *)scrollView {
    return (UIScrollView *)self.superview;
}

- (CATransform3D)identityTransform {

    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500;
    _identityTransform = CATransform3DRotate(transform, (-90.0 * M_PI / 180.0), 0, 0, 1.0);
    
    return _identityTransform;
}

#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    UIScrollView *scrollView = [self scrollView];

    if (keyPath == LYJElasticPullToRefreshContentOffset) {
        CGFloat newContentOffsetY = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y;
        if (scrollView) {
            self.changeY = newContentOffsetY;

            if (self.changeY>LYJElasticPullToRefreshMinOffsetToPull) {
                if (!self.isAnimation) {
                    scrollView.contentInset = UIEdgeInsetsMake(LYJElasticPullToRefreshLoadingContentInset, 0, 0, 0);
                    scrollView.scrollEnabled = NO;
                }
            }
            self.frame = CGRectMake(0, -self.changeY, scrollView.frame.size.width, self.changeY);
            [self pull];
            
//            NSLog(@"change=%f",newContentOffsetY);
            
        }
    } else if (keyPath == LYJElasticPullToRefreshContentInset) {
        
        CGFloat newContentInsetTop = [[change objectForKey:NSKeyValueChangeNewKey] UIEdgeInsetsValue].top;
        NSLog(@"inset top =%f",newContentInsetTop);
        [self startCircleAnimating];
        
    } else if (keyPath == LYJElasticPullToRefreshFrame) {
        
        
    } else if (keyPath == LYJElasticPullToRefreshPanGestureRecognizerState) {
        
        UIGestureRecognizerState gestureState = [self scrollView].panGestureRecognizer.state;
        if (gestureState == UIGestureRecognizerStateEnded || gestureState == UIGestureRecognizerStateCancelled || gestureState == UIGestureRecognizerStateFailed) {
        }
        CGFloat x = [scrollView.panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow].x;
        CGFloat y = [scrollView.panGestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow].y;
//        NSLog(@"x=%f---y=%f",x,y);
        self.point = CGPointMake(x, y);
    }
}

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
        self.backgroundColor = [UIColor yellowColor];
        self.shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
        self.shapeLayer.fillColor = [[UIColor redColor] CGColor];
        self.shapeLayer.actions = @{@"path" : [NSNull null], @"position" : [NSNull null], @"bounds" : [NSNull null]};
        self.shapeLayer.contents = (__bridge id _Nullable)([[UIImage imageNamed:@"tu.jpg"] CGImage]);
        
        CALayer *content = [CALayer layer];
        content.mask = self.shapeLayer;
        content.frame = self.bounds;
        content.backgroundColor = [UIColor purpleColor].CGColor;
        content.contents = (__bridge id _Nullable)([[UIImage imageNamed:@"tu.jpg"] CGImage]);
        self.contentLayer = content;
        [self.layer addSublayer:content];
        
        self.circleLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.circleLayer.strokeColor = [UIColor redColor].CGColor;
        self.circleLayer.fillColor = [UIColor clearColor].CGColor;
        self.circleLayer.actions =@{@"strokeEnd":[NSNull null], @"transform":[NSNull null]};
        self.circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        self.circleLayer.strokeStart = 0.0;
        [self.contentLayer addSublayer:self.circleLayer];
        self.circleLayer.transform = self.identityTransform;
//        [self performSelector:@selector(stopCircleLoading) withObject:nil afterDelay:5.0];

    }
    
    return self;
}

#pragma mark - method
- (void)startDisplayLink {
    self.displayLink.paused = NO;
}

- (void)stopDisplayLink {
    self.displayLink.paused = YES;
}

- (void)displayLinkTick {
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = 0;
    self.contentLayer.frame = self.bounds;
    self.shapeLayer.frame = CGRectMake(0, 0, width, height+self.changeY*0.5);
    self.shapeLayer.path = [self currentPath];
    self.circleLayer.frame = [self circleFrame];
    self.circleLayer.path = [self circlePath];
    [self circleAnimation];
}

-(void)pull{
    CGFloat width = self.bounds.size.width;
    CGFloat height = 0;
    self.contentLayer.frame = self.bounds;
    self.shapeLayer.frame = CGRectMake(0, 0, width, height+self.changeY*0.5);
    self.shapeLayer.path = [self currentPath];
    self.circleLayer.frame = [self circleFrame];
    self.circleLayer.path = [self circlePath];
    [self circleAnimation];
}

-(void)circleAnimation{
    CGFloat end = MIN(0.9 * self.changeY*0.01, 0.9);
    if (end==0.9) {
        CGFloat progress = 0.9 * self.changeY*0.01 ;
        if (progress>1) {
            CGFloat degress = ((progress-1.0)*200.0);
             self.circleLayer.transform = CATransform3DRotate(self.identityTransform, (degress* M_PI / 180.0) , 0, 0, 1.0);
        }else{
            self.circleLayer.transform = self.identityTransform;
        }
       
    }else{
        self.circleLayer.strokeEnd = end;
    }
}

-(CGRect)circleFrame{
    
    CGFloat x=0,y=0,width=20,height=20;
    
    x = self.shapeLayer.frame.size.width/2.0-width/2.0;
    y = self.shapeLayer.frame.size.height-height+5;
    
    CGRect rect = CGRectMake(x, y, width, height);
    return rect;
}

-(CGPathRef)circlePath{
    CGFloat inset = self.circleLayer.lineWidth / 2.0;
    CGPathRef path = [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.circleLayer.bounds, inset, inset)] CGPath];
    return path;
}

- (CGPathRef)currentPath {
    CGFloat width = [self scrollView].bounds.size.width;
    CGFloat height = self.shapeLayer.frame.size.height;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//    NSLog(@"height=%f",height);
    [bezierPath moveToPoint:CGPointZero];
    [bezierPath addLineToPoint:CGPointMake(0, height)];
    
    [bezierPath addQuadCurveToPoint:CGPointMake(width, height) controlPoint:CGPointMake(width/2, height+self.changeY*0.8)];

    [bezierPath addLineToPoint:CGPointMake(width, 0)];

    [bezierPath closePath];
    
    return bezierPath.CGPath;
}

- (void)startCircleAnimating {
    [self scrollView].scrollEnabled = YES;

    if (self.isAnimation) {
        return;
    }
    self.isAnimation = YES;
    if ([self.circleLayer animationForKey:RotationAnimation]) {
        return;
    }
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(2.0 * M_PI + [[self.circleLayer valueForKeyPath:@"transform.rotation.z"] doubleValue]);
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = INFINITY;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.circleLayer addAnimation:rotationAnimation forKey:RotationAnimation];
    
    if (_startAnimation) {
        _startAnimation();
    }
}

- (void)stopCircleLoading {
    UIScrollView *scrollView = [self scrollView];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    NSLog(@"dddd%f",self.changeY);
    [self pull];
    [self.circleLayer removeAnimationForKey:RotationAnimation];
    self.isAnimation = NO;
    
    if (_stopAnimation) {
        _stopAnimation();
    }
}

- (CGFloat)currentDegree {
    CGFloat degree = [[self.circleLayer valueForKeyPath:@"transform.rotation.z"] doubleValue];
    return degree;
}

@end
