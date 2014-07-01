//
//  EventObserver.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MouseEvent.h"
@protocol MouseEventObserver <NSObject>
- (void) onMoveWithEvent:(MouseEvent*) event;
@end
