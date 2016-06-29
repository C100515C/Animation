//
//  LYJDropView.m
//  GrainEffect
//
//  Created by chenchen on 16/6/29.
//  Copyright © 2016年 zhouen. All rights reserved.
//

#import "LYJDropView.h"
#import <CoreMotion/CoreMotion.h>

@interface LYJDropView ()
@property (nonatomic,strong) UIDynamicAnimator *animator;
@property (nonatomic,strong) UIGravityBehavior *gravity;
@property (nonatomic,strong) UICollisionBehavior *collision;
//@property (nonatomic,strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic,strong) CMMotionManager *motionManager;

@property (strong,nonatomic) UIImageView *leftShoot;
@property (strong,nonatomic) UIImageView *rightShoot;

@property (nonatomic,strong) NSMutableArray *dropViewsArr;

@property (nonatomic,assign) BOOL isDroping;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LYJDropView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUI];
        _motionManager = [[CMMotionManager alloc] init];
        [self startMotion];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"dealloc");
    [self didClickedClear];

}

#pragma mark - ui
-(void)setUI{
    self.leftShoot.image = [UIImage imageNamed:self.leftPointImage];
    self.rightShoot.image = [UIImage imageNamed:self.rightPointImage];
}

#pragma mark -property
-(UIDynamicAnimator*)animator{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        _gravity = [[UIGravityBehavior alloc] init];
        _collision = [[UICollisionBehavior alloc] init];
        _collision.translatesReferenceBoundsIntoBoundary = YES;
        [_animator addBehavior:_gravity];
        [_animator addBehavior:_collision];
    }
    return _animator;
}

-(NSMutableArray*)dropViewsArr{
    if (_dropViewsArr==nil) {
        _dropViewsArr = [NSMutableArray array];
    }
    return _dropViewsArr;
}

-(UIImageView*)leftShoot{
    if (_leftShoot==nil) {
        _leftShoot = [[UIImageView alloc] init];
        [self addSubview:_leftShoot];
        _leftShoot.frame = CGRectMake(5, 5, 20, 20);
    }
    return _leftShoot;
}

-(UIImageView*)rightShoot{
    if (_rightShoot==nil) {
        _rightShoot = [[UIImageView alloc] init];
        [self addSubview:_rightShoot];
        _rightShoot.frame = CGRectMake(self.frame.size.width-25, 5, 20, 20);
    }
    return _rightShoot;
}

#pragma mark - methods
//开启陀螺仪
-(void)startMotion{
    if(_motionManager.accelerometerAvailable){
        if (!_motionManager.accelerometerActive) {
            _motionManager.accelerometerUpdateInterval = 1.0/3.0;
            __unsafe_unretained typeof(self) weakSelf = self;
            [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
               
                if (error) {
                    NSLog(@"%@",error);
                    [_motionManager stopAccelerometerUpdates];

                }else{
                    CGFloat a = accelerometerData.acceleration.x;
                    CGFloat b = accelerometerData.acceleration.y;
                    weakSelf.gravity.gravityDirection = CGVectorMake(a, -b);//设置重力矢量方向
                }
                
            }];
        }
    }
}

-(void)didClickedClear{
    // 停止陀螺仪
    [_motionManager stopAccelerometerUpdates];
    _isDroping = NO;
    if (_timer) {
        dispatch_cancel(_timer);
        _timer = nil;
    }
    //移除所有的UIDynamicBehavior item
    for (UIDynamicBehavior *behavior in _animator.behaviors)
    {
        if (behavior == self.gravity)
        {
            for (UIImageView *v in self.gravity.items)
            {
                [self.gravity removeItem:v];
                if (v.superview)[v removeFromSuperview];
            }
            continue;
        }
        else if (behavior == self.collision)
        {
            for (UIImageView *v in self.collision.items) {
                [self.collision removeItem:v];
                if (v.superview)[v removeFromSuperview];
            }
            continue;
        }
        else [_animator removeBehavior:behavior];;
    }
    self.animator = nil;
    [self.dropViewsArr removeAllObjects];// 清空数据
}

-(void)addDropView{
    [self startMotion];
    if (self.imgeNames.count) {
        [self dropWithCount:30 images:self.imgeNames];
    }else{
        UIImage *love = [UIImage imageNamed:@"love"];
        UIImage *star = [UIImage imageNamed:@"star"];
        //设置 发射 dropview 的数据数组
        if (self.dropViewsArr.count % 2 == 0) {
            [self dropWithCount:30 images:@[love]];
        }else{
            [self dropWithCount:30 images:@[star]];
        }
    }
    
    [self serialDrop];
}

-(void)serialDrop{
    if (_isDroping) {
        return;
    }
    
    _isDroping = YES;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC));
    uint64_t time = (uint64_t)(0.05*NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, time, 0);
    dispatch_source_set_event_handler(self.timer, ^{
        if (self.dropViewsArr.count==0) {
            return ;
        }
        NSMutableArray *currentArr = self.dropViewsArr[0];
        if ([currentArr count]) {
            //每次取出第一个，并将其从数组中移除
            UIImageView *dropView = currentArr[0];
            [currentArr removeObjectAtIndex:0];
            [self addSubview:dropView];
            
            UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[dropView] mode:UIPushBehaviorModeInstantaneous];//发射方式  瞬间推出
            [self.animator addBehavior:push];
            
            //角度范围 ［0.6 1.0］
            float random = ((int)(2 + (arc4random() % (10 - 4 + 1))))*0.1;
            
            push.pushDirection = CGVectorMake(0.6,random);//发射角度
            if (dropView.tag != 11) {
                push.pushDirection = CGVectorMake(-0.6,random);
            }
            push.magnitude = 0.3;//设置推出量级
            [self.gravity addItem:dropView];
            [self.collision addItem:dropView];
            
            //延迟 五秒移除 所有dropview
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dropView.alpha = 0.0;
                //移除 view， animator 移除push
                [self.gravity removeItem:dropView];
                [self.collision removeItem:dropView];
                [push removeItem:dropView];
                [self.animator removeBehavior:push];

                [dropView removeFromSuperview];
                
            });
            
        }else{
            //取消 计时器
            dispatch_source_cancel(self.timer);
            [self.dropViewsArr removeObject:currentArr];//移除当前空 数组
            _isDroping = NO;//设置为 未掉落
            if (self.dropViewsArr.count) {
                [self serialDrop]; //再执行掉落方法
            }
        }
        
    });
    dispatch_source_set_cancel_handler(self.timer, ^{
        NSLog(@"cancle");
    });
    dispatch_resume(self.timer);
}
//添加dropview 到数组中
- (NSMutableArray *)dropWithCount:(int)count images:(NSArray *)images{
    
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < count; i++) {
        
        UIImage *image = [images objectAtIndex:rand()%[images count]];
        UIImageView * imageView =[[UIImageView alloc ]initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.center = self.leftShoot.center;//放 左边的图片
        imageView.tag = 11;
        if (i%2 == 0) {
            imageView.center = self.rightShoot.center;//放 右边的图片
            imageView.tag = 22;
        }
        [viewArray addObject:imageView];
    }
    [self.dropViewsArr addObject:viewArray];
    
    return self.dropViewsArr;
}

@end
