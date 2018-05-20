//
//  AISKView.m
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//
#import "AISKDefine.h"
#import "AISKView.h"
#import "AISKNode.h"


@interface AISKView()
@property(nonatomic,strong) NSMutableArray *snakeArr;
@property(nonatomic,strong) AISKNode *foodNode;

@end

@implementation AISKView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addGrid];
    }
    return self;
}

- (void)snakeViewUpdata:(NSMutableArray*)snakeArr
           withFoodPoi:(AISKNode*)foodNode {
    _snakeArr = snakeArr;
    _foodNode = foodNode;
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
    //遍历蛇的数据，绘制蛇的数据
    for (int i = 0 ; i < _snakeArr.count ; i++ ) {
        // 为每个蛇的点(记录的是在数组的位置)，在屏幕上绘制一个圆点
        AISKNode* node = [_snakeArr objectAtIndex:i];
        // 定义将要绘制蛇身点的矩形
        CGRect rect = CGRectMake(node.pointX * CELL_SIZE , node.pointY * CELL_SIZE
                                 , CELL_SIZE , CELL_SIZE);
        // 获取绘图API
        
        //蛇身，并填弃颜色
        CGContextSetLineWidth(ctx, SINGLE_LINE_WIDTH);//线的宽度
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);//填充颜色
        CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);//线框颜色
        CGContextAddRect(ctx,rect);//画方框
        CGContextDrawPath(ctx, kCGPathFillStroke);//绘画路径
    }
    
    //绘制“食物”图片
    CGRect rectfoo = CGRectMake(_foodNode.pointX * CELL_SIZE, _foodNode.pointY * CELL_SIZE, CELL_SIZE, CELL_SIZE);
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

@end
