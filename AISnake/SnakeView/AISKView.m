//
//  AISKView.m
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "AISKView.h"
#import "AISKNode.h"

@interface AISKView()
{
    SystemSoundID gu;
    SystemSoundID crash;
}

@property(nonatomic,strong) NSMutableArray *skNodeArr;
@property(nonatomic,strong) AISKNode *foodPoi;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) UIAlertView * overAlert;

@end

@implementation AISKView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self audioInit];
        [self addGrid];
        [self gameStart];
    }
    return self;
}

- (void)gameStart {
    
    self.skNodeArr = [NSMutableArray array];
    for (NSInteger i=0; i<5; i++) {
        AISKNode *node = [[AISKNode alloc] initWithPointX:i PointY:0];
        [self.skNodeArr addObject:node];
    }
    // 定义蛇的初始移动方向
    self.orient = kAISKRight;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self
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
       || [self.skNodeArr containsObject:head]) {
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
            if(![self.skNodeArr containsObject:newFoodPoi]) {
                self.foodPoi = newFoodPoi;
                // 成功生成了食物的位置，跳出循环
                break;
            }
        }
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // 获取绘图API
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, CGRectMake(0 , 0
                                       , WIDTH * CELL_SIZE , HEIGHT * CELL_SIZE));
    CGContextSetFillColorWithColor(ctx, [[UIColor brownColor] CGColor]);
    
    // 绘制背景，
    CGContextFillRect(ctx, CGRectMake(0 , 0
                                      , WIDTH * CELL_SIZE , HEIGHT * CELL_SIZE));
    
    // 遍历蛇的数据，绘制蛇的数据
    for (int i = 0 ; i < self.skNodeArr.count ; i++ ) {
        // 为每个蛇的点(记录的是在数组的位置)，在屏幕上绘制一个圆点
        AISKNode* node = [self.skNodeArr objectAtIndex:i];
        // 定义将要绘制蛇身点的矩形
        CGRect rect = CGRectMake(node.pointX * CELL_SIZE , node.pointY * CELL_SIZE
                                 , CELL_SIZE , CELL_SIZE);
        
        //蛇身，并填弃颜色
        CGContextSetLineWidth(ctx, SINGLE_LINE_WIDTH);//线的宽度
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);//填充颜色
        CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);//线框颜色
        CGContextAddRect(ctx,rect);//画方框
        CGContextDrawPath(ctx, kCGPathFillStroke);//绘画路径
    }
    
    //绘制“食物”图片
    CGRect rectfoo = CGRectMake(self.foodPoi.pointX * CELL_SIZE, self.foodPoi.pointY * CELL_SIZE, CELL_SIZE, CELL_SIZE);
    CGContextSetLineWidth(ctx, SINGLE_LINE_WIDTH);//线的宽度
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);//填充颜色
    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);//线框颜色
    CGContextAddRect(ctx,rectfoo);//画方框
    CGContextDrawPath(ctx, kCGPathFillStroke);//绘画路径
}

//网格
- (void)addGrid {
    CGFloat widthView = self.frame.size.width;
    CGFloat heightView = self.frame.size.height;
    CGFloat size = CELL_SIZE;
    
    void (^addLineWidthRect)(CGRect rect) = ^(CGRect rect) {
        CALayer *layer = [[CALayer alloc] init];
        [self.layer addSublayer:layer];
        layer.frame = rect;
        layer.backgroundColor = [[UIColor greenColor] CGColor];
    };
    
    for (int i = 0; i < widthView; i+= size) {
        addLineWidthRect(CGRectMake(i, 0, SINGLE_LINE_WIDTH, heightView));
    }
    for (int i = 0; i < heightView; i+= size) {
        addLineWidthRect(CGRectMake(0, i, widthView, SINGLE_LINE_WIDTH));
    }
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 如果用户点击了第二个按钮，重新开始游戏
    if(buttonIndex == 1)
        [self gameStart];
}

@end
