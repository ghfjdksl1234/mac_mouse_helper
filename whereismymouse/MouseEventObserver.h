//
//  EventObserver.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol MouseEventObserver <NSObject>
- (void) onMoveWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y;
@end
