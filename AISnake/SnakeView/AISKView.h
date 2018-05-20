//
//  AISKView.h
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

// 记录地图上的宽和高有多少个格子
#define WIDTH 26
#define HEIGHT 26
// 定义每个格子的大小
#define CELL_SIZE 10
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)

typedef NS_ENUM(NSUInteger, AISKOrient) {
    kAISKDown = 0,
    kAISKUp,
    kAISKLeft,
    kAISKRight,
};


@interface AISKView : UIView<UIAlertViewDelegate>

@property(nonatomic,assign) AISKOrient orient;

@end
