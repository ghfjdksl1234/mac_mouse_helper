//
//  MouseRelocator.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/24/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "WakeupManager.h"
#import "ShakeDisplayManager.h"

@interface WakeupManager()
@property (strong, nonatomic) ShakeDisplayManager* displayManager;

@end
@implementation WakeupManager
-(id)init {
    [[NSWorkspace sharedWorkspace].notificationCenter addObserver:self selector:@selector(onWakeup) name:NSWorkspaceDidWakeNotification object:NULL];
    return self;
}
-(void)onMoveWithEvent:(MouseEvent *)event {
    [self.displayManager onMoveWithEvent:event];
}
-(void)onWakeup {
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(onTimer) userInfo:NULL repeats:NO];
}
-(void)onTimer {
    self.displayManager = [[ShakeDisplayManager alloc] init];
    [self.displayManager addObserver:self];
    
    CGPoint point = [NSEvent mouseLocation];
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    [self.displayManager onMoveWithEvent:[[MouseEvent alloc] initWithTimestamp:now posX:point.x posY:point.y]];
//    NSScreen* screen = [self findAppropriateScreen];
//    CGRect rect = screen.frame;
//    CGPoint point = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
//    [ApplicationManager moveMouseToGlobalPos:point];
}
//-(NSScreen*) findAppropriateScreen {
//    NSMutableArray* screens = [NSMutableArray arrayWithArray:[NSScreen screens]];
//    [screens sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        NSScreen* screen1 = obj1;
//        NSScreen* screen2 = obj2;
//        CGFloat compare = screen1.frame.origin.x - screen2.frame.origin.x;
//        NSComparisonResult result = NSOrderedSame;
//        if (compare < 0) {
//            result = NSOrderedAscending;
//        } else if (0 < compare ) {
//            result = NSOrderedDescending;
//        }
//        return result;
//    }];
//    return screens[(screens.count-1)/2];
//}
-(void)onStartDisplay {
    
}
-(void)onEndDisplay {
    self.displayManager = nil;
}
@end
