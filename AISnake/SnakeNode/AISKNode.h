//
//  AISKNode.h
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AISKNode : NSObject

@property(nonatomic,assign) NSInteger pointX;
@property(nonatomic,assign) NSInteger pointY;

- (id)initWithPointX:(NSInteger)x PointY:(NSInteger)y;
- (BOOL)isEqualSKNode:(AISKNode*)node;

@end
