//
//  MouseEvent.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/1/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "MouseEvent.h"

@interface MouseEvent()
@property NSTimeInterval timestamp;
@property CGFloat x, y;
@end

@implementation MouseEvent
-(id)initWithTimestamp:(NSTimeInterval)timestmap posX:(CGFloat)x posY:(CGFloat)y {
    self.timestamp = timestmap;
    self.x = x;
    self.y = y;
    return self;
}
- (NSTimeInterval) getTimestamp {
    return self.timestamp;
}
- (CGFloat) getX {
    return self.x;
}
- (CGFloat) getY {
    return self.y;
}
@end
