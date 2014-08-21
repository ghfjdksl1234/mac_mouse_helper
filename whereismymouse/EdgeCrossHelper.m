//
//  EdgeCrossHelper.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/7/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "EdgeCrossHelper.h"
#import "FPRangeStartEnd.h"
#import "ApplicationManager.h"

#define PRECISION 1
#define MOVE_POSITION_BUFFER 25

#define MOVE_DECISION_DELAY_TIME 0.27
#define MOVE_STOP_DECISION_TIME 0.4

@interface EdgeCrossHelper()
@property BOOL isTrying;
@property NSTimeInterval tryStartTime;
@property NSTimeInterval lastMoveTime;

@property (strong, nonatomic) NSMutableDictionary* verticalByX;
@property (strong, nonatomic) NSMutableDictionary* horizontalByY;
@end

@implementation EdgeCrossHelper
-(id)init {
    self.isTrying = NO;
    
    self.verticalByX = [[NSMutableDictionary alloc] init];
    self.horizontalByY = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSScreen* screen in [NSScreen screens]) {
        for (NSScreen* otherScreen in array) {
            NSRect frame1 = screen.frame;
            NSRect frame2 = otherScreen.frame;
            
            [self addIntoDictionaryIfPossibleWithFrame1:frame1 frame2:frame2];
        }
        [array addObject:screen];
    }
    return self;
}
-(void)addIntoDictionaryIfPossibleWithFrame1:(NSRect)frame1 frame2:(NSRect)frame2 {
    FPRangeStartEnd *range1, *range2;
    range1 = [FPRangeStartEnd rangeWithStart:frame1.origin.y end:frame1.origin.y + frame1.size.height];
    range2 = [FPRangeStartEnd rangeWithStart:frame2.origin.y end:frame2.origin.y + frame2.size.height];
    [EdgeCrossHelper testAndAddWithPos1:frame1.origin.x size1:frame1.size.width
                                 range1:range1
                                   pos2:frame2.origin.x size2:frame2.size.width
                                 range2:range2
                             dictionary:self.verticalByX];
    
    [EdgeCrossHelper testAndAddWithPos1:frame2.origin.x size1:frame2.size.width
                                 range1:range2
                                   pos2:frame1.origin.x size2:frame1.size.width
                                 range2:range1
                             dictionary:self.verticalByX];
    
    
    
    range1 = [FPRangeStartEnd rangeWithStart:frame1.origin.x end:frame1.origin.x + frame1.size.width];
    range2 = [FPRangeStartEnd rangeWithStart:frame2.origin.x end:frame2.origin.x + frame2.size.width];
    [EdgeCrossHelper testAndAddWithPos1:frame1.origin.y size1:frame1.size.height
                                 range1:range1
                                   pos2:frame2.origin.y size2:frame2.size.height
                                 range2:range2
                             dictionary:self.horizontalByY];
    
    [EdgeCrossHelper testAndAddWithPos1:frame2.origin.y size1:frame2.size.height
                                 range1:range2
                                   pos2:frame1.origin.y size2:frame1.size.height
                                 range2:range1
                             dictionary:self.horizontalByY];
}
+(void)testAndAddWithPos1:(CGFloat)pos1 size1:(CGFloat)size1
                   range1:(FPRangeStartEnd*)range1
                     pos2:(CGFloat)pos2 size2:(CGFloat)size2
                   range2:(FPRangeStartEnd*)range2
               dictionary:(NSMutableDictionary*) dic {
//    if (pos1 == pos2 && size1 == size2) { // this makes a bug
//        return;
//    }
    if (pos1 + size1 == pos2 &&
        range1.start <= range2.end &&
        range2.start <= range1.end) {
        NSNumber* key = [NSNumber numberWithFloat:pos2];
        NSMutableArray* array = [dic objectForKey:key];
        if (array == nil) {
            array = [[NSMutableArray alloc] init];
            [dic setObject:array forKey:key];
        }
        CGFloat start = MAX(range1.start, range2.start);
        CGFloat end = MIN(range1.end, range2.end);
        
        FPRangeStartEnd* newRange = [FPRangeStartEnd rangeWithStart:start end:end];
        [array addObject:newRange];
    }
}
-(void)onMoveWithEvent:(MouseEvent *)event {
    CGFloat x = [event getX];
    CGFloat y = [event getY];
    
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    if (MOVE_STOP_DECISION_TIME < (now - self.lastMoveTime)) {
        self.isTrying = NO;
    }
    self.lastMoveTime = now;
    
    CGFloat newPos = [EdgeCrossHelper getNewPosFor:x pos:y dic:self.verticalByX];
    if (newPos != CGFLOAT_MAX) {
        if (self.isTrying == NO) {
            self.isTrying = YES;
            self.tryStartTime = now;
            return;
        } else if ((now - self.tryStartTime) < MOVE_DECISION_DELAY_TIME) {
            return;
        }
        if (newPos < y) {
            newPos -= MOVE_POSITION_BUFFER;
        } else {
            newPos += MOVE_POSITION_BUFFER;
        }
        if (floor(x) != x) {
            x += 5;
        } else {
            x -= 5;
        }
        
        newPos = ((NSScreen*)[[NSScreen screens] objectAtIndex:0]).frame.size.height - newPos;
        [ApplicationManager moveMouseToGlobalPos:CGPointMake(x, newPos)];
//        CGWarpMouseCursorPosition(CGPointMake(x, newPos));
    } else {
        newPos = [EdgeCrossHelper getNewPosFor:y pos:x dic:self.horizontalByY];
        if (newPos != CGFLOAT_MAX) {
            if (newPos < x) {
                newPos -= MOVE_POSITION_BUFFER;
            } else {
                newPos += MOVE_POSITION_BUFFER;
            }
            if (floor(y) != y) {
                y += 5;
            } else {
                y -= 5;
            }

            y = [NSScreen mainScreen].frame.size.height - y;
            [ApplicationManager moveMouseToGlobalPos:CGPointMake(newPos, y)];
//            CGWarpMouseCursorPosition(CGPointMake(newPos, y));
        } else {
            self.isTrying = NO;
        }
    }
}
+ (CGFloat)getNewPosFor:(CGFloat)keyValue pos:(CGFloat)pos dic:(NSMutableDictionary*)dic {
    CGFloat newPos = CGFLOAT_MAX;
    NSNumber* searchKey = nil;
    for (NSNumber* key in [dic allKeys]) {
        if (fabs(key.floatValue-keyValue)<PRECISION) {
            searchKey = key;
            break;
        }
    }
    if (searchKey != nil) {
        NSArray* array = [dic objectForKey:searchKey];
        
        CGFloat distance = CGFLOAT_MAX;
        for (FPRangeStartEnd *range in array) {
            if ([range contains:pos]) {
                newPos = CGFLOAT_MAX;
                break;
            }
            CGFloat testValue = fabs(range.start-pos);
            if (testValue < distance) {
                distance = testValue;
                newPos = range.start;
            }
            testValue = fabs(range.end-pos);
            if (testValue < distance) {
                distance = testValue;
                newPos = range.end;
            }
        }
    }
    return newPos;
}
-(void)didChangeScreenParameters:(NSNotification *)notification {
    [self init];
}
@end
