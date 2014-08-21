//
//  FPRangeStartEnd.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "FPRangeStartEnd.h"


@implementation FPRangeStartEnd
+(FPRangeStartEnd*) rangeWithStart:(CGFloat)start end:(CGFloat)end {
    FPRangeStartEnd* range = [FPRangeStartEnd alloc];
    range.start = start;
    range.end = end;
    return range;
}
-(BOOL)contains:(CGFloat)value {
    BOOL contains = NO;
    if (self.start <= value && value <= self.end) {
        contains = YES;
    }
    return contains;
}
@end