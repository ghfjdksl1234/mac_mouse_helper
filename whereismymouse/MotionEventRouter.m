//
//  MotionEventRouter.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "MotionEventRouter.h"

#define STATUS_MOTION_DETECTING 0
#define STATUS_DISPLAYING 1

@interface MotionEventRouter()
@property (strong, nonatomic) MotionDetector* motionDetector;
@property (strong, nonatomic) DisplayManager* displayManager;
@property int status;
@end

@implementation MotionEventRouter
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
    self.motionDetector = [[MotionDetector alloc] init];
    [self.motionDetector addObserver:self];
    
}
- (void)createDisplayManager {
    self.displayManager = [[DisplayManager alloc] init];
    [self.displayManager addObserver:self];
}

- (void)onMoveWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y {
    switch (self.status) {
        case STATUS_MOTION_DETECTING:
            [self.motionDetector onMoveWithTimestamp:timestamp posX:x posY:y];
            break;
        case STATUS_DISPLAYING:
            [self.displayManager onMoveWithTimestamp:timestamp posX:x posY:y];
            break;
    }
}
- (void)onMotionDetected {
    self.status = STATUS_DISPLAYING;
}
- (void)onStartDisplay {
    
}
- (void)onEndDisplay {
    self.status = STATUS_MOTION_DETECTING;
}
@end
