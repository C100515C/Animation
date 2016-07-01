//
//  SprayViewController.m
//  GrainEffect
//
//  Created by zhouen on 16/6/22.
//  Copyright © 2016年 zhouen. All rights reserved.
//

#import "SprayViewController.h"
@interface SprayViewController ()
@property (assign,nonatomic) BOOL               isCleared;
@property (strong,nonatomic) NSMutableArray     *cacheEmitterLayers;
@end
@implementation SprayViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    self.cacheEmitterLayers = [NSMutableArray array];
    
    
    UIButton *buton = [[UIButton alloc] initWithFrame:CGRectMake(200, 80, 50, 30)];
    buton.backgroundColor = [UIColor grayColor];
    [buton setTitle:@"清除" forState:UIControlStateNormal];
    [self.view addSubview:buton];
    [buton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *start = [[UIButton alloc] initWithFrame:CGRectMake(100, 80, 50, 30)];
    start.backgroundColor = [UIColor grayColor];
    [start setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:start];
    [start addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self clear];
}
-(void)start{
    _isCleared = NO;
    UIImage *image = [UIImage imageNamed:@"star"];
    [self shootFrom:self.view.center Level:10 Cells:@[image]];
}

- (void)shootFrom:(CGPoint)position Level:(int)level Cells:(NSArray <UIImage *>*)images; {
    if (_isCleared) return;
    CGPoint emiterPosition = position;
    // 配置发射器
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
    emitterLayer.emitterPosition = emiterPosition;
    //发射源的尺寸大小
    emitterLayer.emitterSize     = CGSizeMake(10, 10);
    //发射模式
    emitterLayer.emitterMode     = kCAEmitterLayerSurface;
    //发射源的形状
    emitterLayer.emitterShape    = kCAEmitterLayerLine;
    emitterLayer.renderMode      = kCAEmitterLayerOldestLast;
//    emitterLayer.velocity = 1;
    [self.view.layer addSublayer:emitterLayer];
    
    int index = rand()%[images count];
    CAEmitterCell *snowflake          = [CAEmitterCell emitterCell];
    //粒子的名字
    snowflake.name                    = @"sprite";
    //粒子参数的速度乘数因子
    snowflake.birthRate               = level;
    snowflake.lifetime                = 1.01;
    snowflake.lifetimeRange           = 0.5;
    //粒子速度
    snowflake.velocity                = 300;
    //粒子的速度范围
    snowflake.velocityRange           = 100;
    //粒子y方向的加速度分量
    snowflake.yAcceleration           = 300;
    //snowflake.xAcceleration = 200;
    //周围发射角度
    snowflake.emissionRange           = 0.5*M_PI;
    //    snowflake.emissionLatitude = 200;
    snowflake.emissionLongitude       = 2*M_PI;//
    //子旋转角度范围
    snowflake.spinRange               = 2*M_PI;
    
    snowflake.contents                = (id)[[images objectAtIndex:index] CGImage];
    snowflake.contentsScale = 0.9;
    snowflake.scale                   = 0.1;
    snowflake.scaleSpeed              = 0.2;
    ///*
    //爆炸
    CAEmitterCell *burst  = [CAEmitterCell emitterCell];
    burst.birthRate			= 1.0;		// at the end of travel//粒子产生系数，默认为1.0
    burst.velocity			= 0;    //速度
    burst.scale				= 2.5;  //缩放比例
    burst.redSpeed			=-1.5;		// shifting粒子red在生命周期内的改变速度
    burst.blueSpeed			=+1.5;		// shifting粒子blue在生命周期内的改变速度
    burst.greenSpeed		=+1.0;		// shifting粒子green在生命周期内的改变速度
    burst.lifetime			= 0.2; //生命周期
    
    // 火花 and finally, the sparks
    CAEmitterCell* spark = [CAEmitterCell emitterCell];
    
    spark.birthRate			= 400;//粒子产生系数，默认为1.0
    spark.velocity			= 125;//速度
    spark.emissionRange		= 2* M_PI;	// 360 deg//周围发射角度
    spark.yAcceleration		= 75;		// gravity//y方向上的加速度分量
    spark.lifetime			= 1;    //粒子生命周期
    
    spark.contents			= (id) [[UIImage imageNamed:@"FFTspark"] CGImage];//是个CGImageRef的对象,既粒子要展现的图片
    spark.scaleSpeed		=-0.2;  //缩放比例速度
    spark.greenSpeed		=-0.6;  //粒子green在生命周期内的改变速度
    spark.redSpeed			= 0.4;  //粒子red在生命周期内的改变速度
    spark.blueSpeed			=-0.8;  //粒子blue在生命周期内的改变速度
    spark.alphaSpeed		=-0.25; //粒子透明度在生命周期内的改变速度
    spark.spin				= 2* M_PI;  //子旋转角度
    spark.spinRange			= 2* M_PI;  //子旋转角度范围
    //*/
    emitterLayer.emitterCells  = [NSArray arrayWithObject:snowflake];
    snowflake.emitterCells = [NSArray arrayWithObjects:burst, nil];
    burst.emitterCells = [NSArray arrayWithObject:spark];
    
    [self.cacheEmitterLayers addObject:emitterLayer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_isCleared)return ;
        emitterLayer.birthRate = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_isCleared)return ;
            [emitterLayer removeFromSuperlayer];
            [self.cacheEmitterLayers removeObject:emitterLayer];
        });
    });
    
}

-(void)clear{
    self.isCleared = YES;
    for (CAEmitterLayer *emitterLayer in self.cacheEmitterLayers)
    {
        [emitterLayer removeFromSuperlayer];
        emitterLayer.emitterCells = nil;
    }
    [self.cacheEmitterLayers removeAllObjects];
}
@end
