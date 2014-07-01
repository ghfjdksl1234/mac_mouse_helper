//
//  MotionEventRegulator.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 4/27/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEvent.h"

@interface MotionEventRegulator : NSObject
- (BOOL) nextWithMouseEvent:(MouseEvent*)event pointObject:(CGPoint*)point;
@end
