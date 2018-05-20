//
//  AISKNode.m
//  AISnake
//
//  Created by 周刚涛 on 2018/5/20.
//  Copyright © 2018年 XYZ. All rights reserved.
//

#import "AISKNode.h"

@implementation AISKNode

- (id)initWithPointX:(NSInteger)x PointY:(NSInteger)y {
    self = [super init];
    if (self) {
        _pointX = x;
        _pointY = y;
    }
    return self;
}

- (BOOL)isEqualSKNode:(AISKNode *)node {
    if ([self isEqual:node]) {
        return YES;
    } else if ([node isMemberOfClass:[AISKNode class]]) {
        return ((node.pointX == self.pointX) && (node.pointY == self.pointY));
    }
    return NO;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"pointX = %ld,PointY = %ld",(long)self.pointY,(long)self.pointY];
}

@end
