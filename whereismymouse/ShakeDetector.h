//
//  MotionDetector.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@protocol ShakeObserver<NSObject>
- (void)onShakeDetected;
@end

@interface ShakeDetector : NSObject<MouseEventObserver>
- (void)addObserver:(NSObject<ShakeObserver>*)observer;
@end
