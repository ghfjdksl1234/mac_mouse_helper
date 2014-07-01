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

@interface ApplicationManager()
@property (strong, nonatomic) MouseEventDistributor* eventDistributor;
@end

@implementation ApplicationManager
- (id) init {
    self.eventDistributor = [[MouseEventDistributor alloc] init];
    ShakeManager* shakeManager = [[ShakeManager alloc] init];
    [self.eventDistributor addObserver:shakeManager];
    
    return self;
}
- (void)onMoveWithEvent:(MouseEvent *)event {
    [self.eventDistributor onMoveWithEvent:event];
}
@end
