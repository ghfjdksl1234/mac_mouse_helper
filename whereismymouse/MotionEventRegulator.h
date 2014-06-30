//
//  MotionEventRegulator.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 4/27/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MotionEventRegulator : NSObject
- (BOOL) nextWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y pointObject:(CGPoint*)point;
@end
