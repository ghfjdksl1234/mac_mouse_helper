//
//  FPRangeStartEnd.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FPRangeStartEnd : NSObject
@property CGFloat start, end;
+(FPRangeStartEnd*) rangeWithStart:(CGFloat)start end:(CGFloat)end;
-(BOOL)contains:(CGFloat)value;
@end