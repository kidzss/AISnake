//
//  ViewController.m
//  AISnake
//
//  Created by 周刚涛 on 2018/5/19.
//  Copyright © 2018年 XYZ. All rights reserved.
//

#import "ViewController.h"
#import "AISKNode.h"
#import "AISKView.h"

@interface ViewController ()

@property(nonatomic,strong) AISKView* snakeView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.snakeView = [[AISKView alloc] initWithFrame:
                 CGRectMake(0, 0, WIDTH*CELL_SIZE , HEIGHT * CELL_SIZE)];
    
    // 为snakeView控件设置边框和圆角。
    // 设置self.view控件支持用户交互
    self.snakeView.center = self.view.center;
    self.view.userInteractionEnabled = YES;
    
    // 设置self.view控件支持多点触碰
    self.view.multipleTouchEnabled = YES;
    for (int i = 0 ; i < 4 ; i++) {
        // 创建手势处理器，指定使用该控制器的handleSwipe:方法处理轻扫手势
        UISwipeGestureRecognizer* gesture = [[UISwipeGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleSwipe:)];
        // 设置该点击手势处理器只处理i个手指的轻扫手势
        gesture.numberOfTouchesRequired = 1;
        // 指定该手势处理器只处理1 << i方向的轻扫手势
        gesture.direction = 1 << i;
        // 为self.view控件添加手势处理器。
        [self.view addGestureRecognizer:gesture];
    }
    
    [self.view addSubview:self.snakeView];
}


// 实现手势处理器的方法，该方法应该声明一个形参。
// 当该方法被激发时，手势处理器会作为参数传给该方法的参数。
- (void) handleSwipe:(UISwipeGestureRecognizer*)gesture {
    // 获取轻扫手势的方向
    NSUInteger direction = gesture.direction;
    switch (direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
            if(self.snakeView.orient != kAISKRight) // 只要不是向右，即可改变方向
                self.snakeView.orient = kAISKLeft;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            if(self.snakeView.orient != kAISKDown) // 只要不是向下，即可改变方向
                self.snakeView.orient = kAISKUp;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if(self.snakeView.orient != kAISKUp) // 只要不是向上，即可改变方向
                self.snakeView.orient = kAISKDown;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if(self.snakeView.orient != kAISKLeft) // 只要不是向左，即可改变方向
                self.snakeView.orient = kAISKRight;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
