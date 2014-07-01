//
//  MouseEvent.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/1/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MouseEvent : NSObject
- (id) initWithTimestamp: (NSTimeInterval) timestmap posX:(CGFloat)x posY:(CGFloat)y;
- (NSTimeInterval) getTimestamp;
- (CGFloat) getX;
- (CGFloat) getY;

@end
