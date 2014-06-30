//
//  MotionEventRegulator.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 4/27/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "MotionEventRegulator.h"

#define IGNORE_TIME_DISTANCE    1000

@interface MotionEventRegulator()
@property NSTimeInterval lastTimestamp;
@property CGRect *window;
@end

@implementation MotionEventRegulator
- (BOOL) nextWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y pointObject:(CGPoint*)point {
    BOOL newPoint = NO;
    if (point != nil) {
        double tolerance = [self getToleranceDistance];
        
        if ([self isNewPointWithTimestamp:timestamp posX:x posY:y]) {
            if (self.window == nil) {
                self.window = malloc(sizeof(CGRect));
            }
            
            *self.window = NSMakeRect(x-tolerance, y-tolerance, tolerance * 2, tolerance * 2);
            
            (*point).x = x;
            (*point).y = y;
            newPoint = YES;
        } else if ([self isOutsideOfWindowWithPosX:x posY:y]) {
            if (x < (*self.window).origin.x) {
                (*self.window).origin.x = x;
            } else if( (*self.window).origin.x + (*self.window).size.width < x) {
                (*self.window).origin.x = x - tolerance;
            }
            if (y < (*self.window).origin.y) {
                (*self.window).origin.y = y;
            } else if( (*self.window).origin.y + (*self.window).size.height < y) {
                (*self.window).origin.y = y - tolerance;
            }
            (*self.window).size = NSMakeSize(tolerance, tolerance);
            
            (*point).x = x;
            (*point).y = y;
            newPoint = YES;
        }
    }
    self.lastTimestamp = timestamp;
    return newPoint;
}
- (BOOL) isNewPointWithTimestamp:(CGFloat)timestamp posX:(CGFloat)x posY:(CGFloat)y {
    return (self.window == nil || [self isTimeout:timestamp]);
}
- (BOOL) isTimeout:(NSTimeInterval) timestamp {
    return (IGNORE_TIME_DISTANCE < timestamp - self.lastTimestamp);
}
- (BOOL) isOutsideOfWindowWithPosX:(CGFloat)x posY:(CGFloat)y {
    return x < (*self.window).origin.x ||
            (*self.window).origin.x + (*self.window).size.width < x ||
            y < (*self.window).origin.y ||
            (*self.window).origin.y + (*self.window).size.height < y;
}
- (double) getToleranceDistance {
    return 30;
}
@end
