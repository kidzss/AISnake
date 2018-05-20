//
//  AISKView.h
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AISKNode;

@interface AISKView : UIView
- (void)snakeViewUpdata:(NSArray*)snakeArr
           withFoodPoi:(AISKNode*)foodNode;
@end
