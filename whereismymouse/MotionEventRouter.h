//
//  MotionEventRouter.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MouseEventObserver.h"
#import "MotionDetector.h"
#import "DisplayManager.h"

@interface MotionEventRouter : NSObject<MouseEventObserver, MotionEventObserver, DisplayEventObserver>
- (id)init;
@end
