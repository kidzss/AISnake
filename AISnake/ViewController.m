//
//  ViewController.m
//  AISnake
//
//  Created by 周刚涛 on 2018/5/19.
//  Copyright © 2018年 XYZ. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "ViewController.h"
#import "AISKNode.h"
#import "AISKView.h"
#import "AISKDefine.h"

typedef NS_ENUM(NSUInteger, AISKOrient) {
    kAISKDown = 0,
    kAISKUp,
    kAISKLeft,
    kAISKRight
};

@interface ViewController ()<UIAlertViewDelegate>
{
    SystemSoundID gu;
    SystemSoundID crash;
}

@property(nonatomic,strong) NSMutableArray *skNodeArr;
@property(nonatomic,strong) AISKNode *foodPoi;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) UIAlertView * overAlert;
@property(nonatomic,strong) AISKView* snakeView;
@property(nonatomic,assign) AISKOrient orient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self audioInit];
    [self snakeViewInit];
    [self.view addSubview:self.snakeView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self gameStart];
}

- (void)snakeViewInit {
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
}

- (void)gameStart {
    self.skNodeArr = [NSMutableArray array];
    for (NSInteger i=0; i<NODE_COUNT; i++) {
        AISKNode *node = [[AISKNode alloc] initWithPointX:i PointY:0];
        [self.skNodeArr addObject:node];
    }
    // 定义蛇的初始移动方向
    self.orient = kAISKRight;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIME target:self
                                                selector:@selector(snakeMove) userInfo:nil repeats:YES];
}

- (UIAlertView*)overAlert {
    if (!_overAlert) {
        _overAlert = [[UIAlertView alloc] initWithTitle:@"游戏结束"
                                                message:@"您输了，是否重新再来？" delegate:self
                                      cancelButtonTitle:@"不来了" otherButtonTitles:@"再来一盘！", nil];
    }
    return _overAlert;
}

- (void)audioInit {
    // 获取两个音效文件的的URL
    NSURL* guUrl = [[NSBundle mainBundle]
                    URLForResource:@"gu" withExtension:@"mp3"];
    NSURL* crashUrl = [[NSBundle mainBundle]
                       URLForResource:@"crash" withExtension:@"wav"];
    // 加载两个音效文件
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)guUrl , &gu);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)crashUrl , &crash);
}

- (void)snakeMove {
    // 除了蛇头受方向控制之外，其他点都是占它的前一个
    // 获取当前蛇头
    AISKNode* last = [self.skNodeArr lastObject];
    //下一步的蛇头
    AISKNode* head = [[AISKNode alloc] initWithPointX:last.pointX PointY:last.pointY];
    
    switch(self.orient) {
        case kAISKDown: // 代表向下
            head.pointY = head.pointY + 1;
            break;
        case kAISKLeft: // 代表向左
            head.pointX = head.pointX - 1;
            break;
        case kAISKRight: // 代表向右
            head.pointX = head.pointX + 1;
            break;
        case kAISKUp: // 3代表上
            head.pointY = head.pointY - 1;
            break;
    }
    
    //判断游戏是否结束
    // 如果移动后蛇头超出界面或与蛇身碰撞，游戏结束
    if(head.pointX < 0 || head.pointX > WIDTH - 1
       || head.pointY < 0 || head.pointY > HEIGHT - 1
       || [self containsAISKNode:head]) {
        // 播放碰撞的音效
        AudioServicesPlaySystemSound(crash);
        [self.overAlert show];
        [self.timer invalidate];
        _timer = nil;
    }
    
    //判断是否吃到实物
    // 表明蛇头与食物点重合
    if([head isEqualSKNode:self.foodPoi]) {
        // 播放吃食物的音效
        AudioServicesPlaySystemSound(gu);
        // 将食物点添加成新的蛇头
        [self.skNodeArr addObject:self.foodPoi];
        // 食物清空
        _foodPoi = nil;
    } else {
        // 从第一个点开始，控制蛇身向前
        for (int i = 0 ; i < self.skNodeArr.count - 1; i++) {
            // 将第i个点的坐标设置为第i+1个点的的坐标
            AISKNode* curPt = [self.skNodeArr objectAtIndex:i];
            AISKNode* nextPt = [self.skNodeArr objectAtIndex:i + 1];
            curPt.pointX = nextPt.pointX;
            curPt.pointY = nextPt.pointY;
        }
        
        // 重新设置蛇头坐标
        [self.skNodeArr setObject:head atIndexedSubscript:(self.skNodeArr.count - 1)];
    }
    
    //生成实物
    if(_foodPoi == nil) {
        while(true) {
            AISKNode* newFoodPoi = [[AISKNode alloc] initWithPointX:arc4random() % WIDTH
                                                             PointY:arc4random() % HEIGHT];
            
            // 如果新产生的食物点，没有位于蛇身体上
            if(![self containsAISKNode:newFoodPoi]) {
                self.foodPoi = newFoodPoi;
                // 成功生成了食物的位置，跳出循环
                break;
            }
        }
    }
    [self.snakeView snakeViewUpdata:self.skNodeArr withFoodPoi:self.foodPoi];
}


// 实现手势处理器的方法，该方法应该声明一个形参。
// 当该方法被激发时，手势处理器会作为参数传给该方法的参数。
- (void) handleSwipe:(UISwipeGestureRecognizer*)gesture {
    // 获取轻扫手势的方向
    NSUInteger direction = gesture.direction;
    switch (direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
            if(self.orient != kAISKRight) // 只要不是向右，即可改变方向
                self.orient = kAISKLeft;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            if(self.orient != kAISKDown) // 只要不是向下，即可改变方向
                self.orient = kAISKUp;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            if(self.orient != kAISKUp) // 只要不是向上，即可改变方向
                self.orient = kAISKDown;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if(self.orient != kAISKLeft) // 只要不是向左，即可改变方向
                self.orient = kAISKRight;
            break;
    }
}

- (BOOL)containsAISKNode:(AISKNode*)headNode {
    BOOL contain = NO;
    for (AISKNode* node in self.skNodeArr) {
//        NSLog(@"headNode.pointX %ld",headNode.pointX);
//        NSLog(@"headNode.pointY %ld",headNode.pointY);
//
//        NSLog(@"node.pointX %ld",node.pointX);
//        NSLog(@"node.pointY %ld",node.pointY);
        
        if ([node isEqualSKNode:headNode]) {
            contain = YES;
            break;
        }
    }
    return contain;
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 如果用户点击了第二个按钮，重新开始游戏
    if(buttonIndex == 1)
        [self gameStart];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
