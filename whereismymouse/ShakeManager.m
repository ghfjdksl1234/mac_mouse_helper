//
//  MotionEventRouter.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ShakeManager.h"
#import "ShakeDetector.h"
#define STATUS_MOTION_DETECTING 0
#define STATUS_DISPLAYING 1

@interface ShakeManager()
@property (strong, nonatomic) ShakeDetector* shakeDetector;
@property (strong, nonatomic) DisplayManager* displayManager;
@property int status;
@end

@implementation ShakeManager
-(id)init {
    self = [super init];
    if (self) {
        [self createMotionDetector];
        [self createDisplayManager];
        self.status = STATUS_MOTION_DETECTING;
    }
    return self;
}
- (void)createMotionDetector {
    self.shakeDetector = [[ShakeDetector alloc] init];
    [self.shakeDetector addObserver:self];
    
}
- (void)createDisplayManager {
    self.displayManager = [[DisplayManager alloc] init];
    [self.displayManager addObserver:self];
}

- (void)onMoveWithEvent:(MouseEvent *)event {
    switch (self.status) {
        case STATUS_MOTION_DETECTING:
            [self.shakeDetector onMoveWithEvent:event];
            break;
        case STATUS_DISPLAYING:
            [self.displayManager onMoveWithEvent:event];
            break;
    }
}
- (void)onShakeDetected {
    self.status = STATUS_DISPLAYING;
}
- (void)onStartDisplay {
    
}
- (void)onEndDisplay {
    self.status = STATUS_MOTION_DETECTING;
}
@end
