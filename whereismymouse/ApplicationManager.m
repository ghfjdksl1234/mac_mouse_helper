//
//  ApplicationManager.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/1/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ApplicationManager.h"
#import "MouseEventDistributor.h"
#import "ShakeManager.h"
#import "EdgeCrossHelper.h"
#import "HotKeyManager.h"
#import "DisplayEdgeGuide.h"
//#import "WakeupManager.h"

@interface ApplicationManager()
@property (strong, nonatomic) MouseEventDistributor* eventDistributor;
@property (strong, nonatomic) ShakeManager* shakeManager;
@property (strong, nonatomic) EdgeCrossHelper* crossHelper;
@property (strong, nonatomic) HotKeyManager* hotkeyManager;
@property (strong, nonatomic) DisplayEdgeGuide* displayEdgeGuide;

//@property (strong, nonatomic) WakeupManager* wakeupManager;
@end

@implementation ApplicationManager
- (id) init {
    self.eventDistributor = [[MouseEventDistributor alloc] init];
    [self setEnableShake:YES];
    [self setEnableCross:YES];
    [self setEnableHotKey:YES];
    [self setShowEdgeAlignGuide:NO];
    // Can't use below because of delay after wakeup
//    [self setEnableCenterAtWakeup:YES];
    
    //    static int roundCount = 0;
    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSMouseMovedMask | NSKeyDownMask) handler:^(NSEvent* event) {
        //the code commented below is for energy effiency. but I think it's not a matter. So I commented it.
        //        roundCount = (roundCount+1)%3;
        //        if (0 < roundCount) {
        //            return;
        //        }
        if (event.type == NSMouseMoved) {
            NSPoint position = [NSEvent mouseLocation];
            MouseEvent* mouseEvent = [[MouseEvent alloc] initWithTimestamp:event.timestamp posX:position.x posY:position.y];
            [self onMoveWithEvent:mouseEvent];
            printf("(%10.4f) : x(%f), y(%f)\n", event.timestamp, position.x, position.y);
        } else if (event.type == NSKeyDown) {
            int k = 3;
            k = 5;
        }
        
    }];
    /*/
     for (int i = 0 ; i < sizeof(testInput) / sizeof(testInput[0]) ; i++) {
     double* input = testInput[i];
     [self.mouseEventRouter onMoveWithTimestamp:input[0] posX:input[1] posY:input[2]];
     }
     /**/
    
    return self;
}
- (void)onMoveWithEvent:(MouseEvent *)event {
    [self.eventDistributor onMoveWithEvent:event];
}

- (void) setEnableShake:(BOOL)enable {
    if (enable == YES && self.shakeManager == nil) {
        self.shakeManager = [[ShakeManager alloc] init];
        [self.eventDistributor addObserver:self.shakeManager];
    } else if (enable == NO && self.shakeManager != nil) {
        [self.eventDistributor removeObserver:self.shakeManager];
        self.shakeManager = nil;
    }
}
- (void) setEnableCross:(BOOL)enable {
    if (enable == YES && self.crossHelper == nil) {
        self.crossHelper = [[EdgeCrossHelper alloc] init];
        [self.eventDistributor addObserver:self.crossHelper];
    } else if (enable == NO && self.crossHelper != nil) {
        [self.eventDistributor removeObserver:self.crossHelper];
        self.crossHelper = nil;
    }
}
- (void) setEnableHotKey:(BOOL)enable {
    if (enable == YES && self.hotkeyManager == nil) {
        self.hotkeyManager = [[HotKeyManager alloc] init];
        [self.hotkeyManager setEnable:YES];
        [self.eventDistributor addObserver:self.hotkeyManager];
    } else if (enable == NO && self.hotkeyManager != nil) {
        [self.hotkeyManager setEnable:NO];
        [self.eventDistributor removeObserver:self.hotkeyManager];
        self.hotkeyManager = nil;
    }
}
- (void) setShowEdgeAlignGuide:(BOOL)enable {
    if (enable == YES && self.displayEdgeGuide == nil) {
        self.displayEdgeGuide = [[DisplayEdgeGuide alloc] init];
    } else if (enable == NO && self.displayEdgeGuide != nil) {
        self.displayEdgeGuide = nil;
    }
}
//- (void) setEnableCenterAtWakeup:(BOOL)enable {
//    if (enable == YES && self.wakeupManager == nil) {
//        self.wakeupManager = [[WakeupManager alloc] init];
//        [self.eventDistributor addObserver:self.wakeupManager];
//    } else if (enable == NO && self.wakeupManager != nil) {
//        [self.eventDistributor removeObserver:self.wakeupManager];
//        self.wakeupManager = nil;
//    }
//}
+(void)moveMouseToGlobalPos:(CGPoint)point {
    CGDisplayHideCursor (kCGNullDirectDisplay);
    CGAssociateMouseAndMouseCursorPosition (false);
    CGDisplayMoveCursorToPoint(kCGNullDirectDisplay, point);
    //        CGWarpMouseCursorPosition(CGPointMake(x, newPos));
    CGAssociateMouseAndMouseCursorPosition(true);
    CGDisplayShowCursor (kCGNullDirectDisplay);
}
- (void)didChangeScreenParameters:(NSNotification *)notification {
    if (self.crossHelper != nil) {
        [self.crossHelper didChangeScreenParameters:notification];
    }
    if (self.displayEdgeGuide != nil) {
        [self.displayEdgeGuide didChangeScreenParameters:notification];
    }
}
@end
