//
//  LYJSnowView.m
//  SnowAnimation
//
//  Created by chenchen on 16/7/4.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "LYJSnowView.h"

@interface LYJSnowView ()
{
    CAEmitterLayer *_emitterLayer;
    CAEmitterCell *_emitterCell;
}
@end

@implementation LYJSnowView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        _emitterLayer = [CAEmitterLayer layer];
        _emitterCell = [CAEmitterCell emitterCell];
        
        [self setEmitterLayer];
        [self setEmitterCell];
//        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(void)setEmitterLayer{
//    CGRect bounds = [[UIScreen mainScreen] bounds];
    _emitterLayer.emitterPosition = CGPointMake(self.frame.size.width/2.0, 0);// 发射起点 位置
    _emitterLayer.emitterSize = CGSizeMake(self.frame.size.width, 0);// 发射器的 大小
    _emitterLayer.emitterShape = kCAEmitterLayerLine; // 发射器形状
    _emitterLayer.emitterMode = kCAEmitterLayerSurface; // 发射器  的  模式
}

-(void)setEmitterCell{
    _emitterCell.contents = (__bridge id _Nullable)([(id)[UIImage imageNamed:@"FFTspark"] CGImage]);// cell 要展现的内容
    _emitterCell.birthRate = 10; //cell 参数的速度乘数因子
    _emitterCell.lifetime = 120.0f; // cell 生命周期时间
    _emitterCell.lifetimeRange = 0.5;//cell 生命周期 变化范围
    
    _emitterCell.velocity = 10;// cell速度
    _emitterCell.velocityRange = 10;//cell 速度 变化范围
    _emitterCell.yAcceleration = 10;// cell y方向上的速度加量
    
    _emitterCell.emissionLongitude = -M_PI;// x-y 平面发射角度范围
    _emitterCell.emissionRange = M_PI/4.0f;// 发射角度变化范围
    _emitterCell.spinRange = 0.25*M_PI; // cell 旋转的角度范围
    
    _emitterCell.scale = 0.5; //放缩比
    _emitterCell.scaleRange = 1.0; //放缩比的变化范围
    _emitterCell.scaleSpeed = 0.1; // 放缩比变化速度
    
    _emitterCell.color = [self getRandomColor];
    _emitterCell.redRange = -1.0;//cell  红色改变的范围
    _emitterCell.greenRange = 2.0;//cell 绿色 改变的范围
    _emitterCell.blueRange = 1.0; // cell 蓝色改变的范围
    _emitterCell.redSpeed = 0.2;
    _emitterCell.greenSpeed = 0.3;
    _emitterCell.blueSpeed = 0.1;
    _emitterCell.alphaRange = 0.5;
    _emitterCell.alphaSpeed = -0.1;
    
    if (_emitterLayer) {
        _emitterLayer.emitterCells = [NSArray arrayWithObject:_emitterCell];// cell 放入 发射器中
        [self.layer insertSublayer:_emitterLayer atIndex:0];//发射器添加到layer 上
    }
    
}

-(CGColorRef)getRandomColor{
    UIColor *col = nil;
    CGFloat red = arc4random()%200;
    CGFloat green = arc4random()%200;
    CGFloat blue = arc4random()%200;

    col = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    return col.CGColor;
}

@end
