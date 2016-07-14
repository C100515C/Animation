//
//  ViewController.m
//  SnowAnimation
//
//  Created by chenchen on 16/7/4.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "ViewController.h"
#import "LYJSnowView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    LYJSnowView *snow = [[LYJSnowView alloc]  initWithFrame:CGRectMake(50, 50, 220, 400)];
    [self.view addSubview:snow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
