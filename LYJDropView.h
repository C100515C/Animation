//
//  LYJDropView.h
//  GrainEffect
//
//  Created by chenchen on 16/6/29.
//  Copyright © 2016年 zhouen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYJDropView : UIView

@property (nonatomic,copy) NSArray *imgeNames;//发射图片 数组
@property (nonatomic,copy) NSString *leftPointImage;//左起点 图
@property (nonatomic,copy) NSString *rightPointImage;//右起点 图

//添加发射
-(void)addDropView;
//清除
-(void)didClickedClear;

@end
