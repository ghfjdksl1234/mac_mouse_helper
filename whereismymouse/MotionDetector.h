//
//  MotionDetector.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@protocol MotionEventObserver<NSObject>
- (void)onMotionDetected;
@end

@interface MotionDetector : NSObject<MouseEventObserver>
- (void)addObserver:(NSObject<MotionEventObserver>*)observer;
@end
