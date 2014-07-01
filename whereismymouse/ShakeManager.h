//
//  MotionEventRouter.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MouseEventObserver.h"
#import "ShakeDetector.h"
#import "DisplayManager.h"

@interface ShakeManager : NSObject<MouseEventObserver, ShakeObserver, DisplayEventObserver>
- (id)init;
@end
