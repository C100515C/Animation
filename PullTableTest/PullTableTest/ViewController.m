//
//  ViewController.m
//  PullTableTest
//
//  Created by chenchen on 16/7/6.
//  Copyright © 2016年 chenchen. All rights reserved.
//

#import "ViewController.h"
//#import "CircleView.h"
#import "UIScrollView+PullRefresh.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *mytable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CircleView *c = [[CircleView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.height, 10)];
//    c.backgroundColor = [UIColor redColor];
//    [self.mytable addSubview:c];
//    c.observing = YES;
    [self.mytable addHeaderCircle:^{
        NSLog(@"stop");
    } and:^{
        NSLog(@"start");
        [self performSelector:@selector(endll) withObject:nil afterDelay:5.0];
    }];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)endll{
    [self.mytable.header  stopCircleLoading];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
