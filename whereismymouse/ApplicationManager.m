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

@interface ApplicationManager()
@property (strong, nonatomic) MouseEventDistributor* eventDistributor;
@property (strong, nonatomic) ShakeManager* shakeManager;
@property (strong, nonatomic) EdgeCrossHelper* crossHelper;
@end

@implementation ApplicationManager
- (id) init {
    self.eventDistributor = [[MouseEventDistributor alloc] init];
    [self setEnableShake:YES];
    [self setEnableCross:YES];
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
@end
