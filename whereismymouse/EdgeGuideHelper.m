//
//  EdgeGuideHelper.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "EdgeGuideHelper.h"
#import "ScreenEdgeList.h"

@interface EdgeGuideHelper()
@property (strong, nonatomic) NSMutableArray* screenEdgeList;
@property (strong, nonatomic) ScreenEdgeList* recentItem;
@end

@implementation EdgeGuideHelper
-(id)init {
    self.screenEdgeList = [[NSMutableArray alloc] init];
    for (NSScreen* screen in [NSScreen screens]) {
        ScreenEdgeList* item = [[ScreenEdgeList alloc] initWithScreen:screen];
        for (NSScreen* otherScreen in [NSScreen screens]) {
            if (CGPointEqualToPoint(screen.frame.origin, otherScreen.frame.origin)) {
                continue;
            }
            
            [self addIntoDictionaryIfPossibleWithItem:item otherScreen:otherScreen];
        }
        [self.screenEdgeList addObject:item];
    }
    self.recentItem = nil;
    return self;
}
-(void)addIntoDictionaryIfPossibleWithItem:(ScreenEdgeList*)item otherScreen:(NSScreen*)otherScreen {
    NSRect original = item.screen.frame;
    NSRect other = otherScreen.frame;
    if (original.origin.x + original.size.width == other.origin.x) {
        // other is on the right of original
        [item.right addObject:otherScreen];
    } else if (other.origin.x + other.size.width == original.origin.x) {
        // other is on the left of original
        [item.left addObject:otherScreen];
    } else if (original.origin.y + original.size.height == other.origin.y) {
        // other is on the bottom of original
        [item.bottom addObject:otherScreen];
    } else if (other.origin.y + other.size.height == original.origin.y) {
        // other is on the top of original
        [item.top addObject:otherScreen];
    }
}
-(void)onMoveWithEvent:(MouseEvent *)event {
//    ScreenEdgeList* item = [self findItemWithPoint:[event getPoint]];
//    if (item != nil) {
//        if ([self isGoingToLeftWithEvent:event]) {
//            
//        } else if ([self isGoingToLeftWithEvent:event]) {
//        } else if ([self isGoingToLeftWithEvent:event]) {
//        } else if ([self isGoingToLeftWithEvent:event]) {
//        }
//    }
//    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
//    if (MOVE_STOP_DECISION_TIME < (now - self.lastMoveTime)) {
//        self.isTrying = NO;
//    }
//    self.lastMoveTime = now;
//    
//    CGFloat newPos = [EdgeCrossHelper getNewPosFor:x pos:y dic:self.verticalByX];
//    if (newPos != CGFLOAT_MAX) {
//        if (self.isTrying == NO) {
//            self.isTrying = YES;
//            self.tryStartTime = now;
//            return;
//        } else if ((now - self.tryStartTime) < MOVE_DECISION_DELAY_TIME) {
//            return;
//        }
//        if (newPos < y) {
//            newPos -= MOVE_POSITION_BUFFER;
//        } else {
//            newPos += MOVE_POSITION_BUFFER;
//        }
//        if (floor(x) != x) {
//            x += 5;
//        } else {
//            x -= 5;
//        }
//        
//        newPos = ((NSScreen*)[[NSScreen screens] objectAtIndex:0]).frame.size.height - newPos;
//        [ApplicationManager moveMouseToGlobalPos:CGPointMake(x, newPos)];
//        //        CGWarpMouseCursorPosition(CGPointMake(x, newPos));
//    } else {
//        newPos = [EdgeCrossHelper getNewPosFor:y pos:x dic:self.horizontalByY];
//        if (newPos != CGFLOAT_MAX) {
//            if (newPos < x) {
//                newPos -= MOVE_POSITION_BUFFER;
//            } else {
//                newPos += MOVE_POSITION_BUFFER;
//            }
//            if (floor(y) != y) {
//                y += 5;
//            } else {
//                y -= 5;
//            }
//            
//            y = [NSScreen mainScreen].frame.size.height - y;
//            [ApplicationManager moveMouseToGlobalPos:CGPointMake(newPos, y)];
//            //            CGWarpMouseCursorPosition(CGPointMake(newPos, y));
//        } else {
//            self.isTrying = NO;
//        }
//    }
}
- (ScreenEdgeList*) findItemWithPoint:(CGPoint)p {
    ScreenEdgeList* foundItem = nil;
    if (self.recentItem != nil && CGRectContainsPoint(self.recentItem.screen.frame, p)) {
        foundItem = self.recentItem;
    } else {
        for (ScreenEdgeList* item in self.screenEdgeList) {
            if (item == foundItem) {
                continue;
            }
            if (CGRectContainsPoint(item.screen.frame, p)) {
                foundItem = item;
                break;
            }
        }
    }
    self.recentItem = foundItem;
    return foundItem;
}
-(void)didChangeScreenParameters:(NSNotification *)notification {
    [self init];
    //TODO should be called.
}

@end
