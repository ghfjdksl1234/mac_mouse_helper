//
//  OverlayWindow.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/30/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MouseEventObserver.h"

@interface OverlayWindow : NSWindow
- (void)initOriginWithPosX:(CGFloat)x posY:(CGFloat)y;
- (void)updateWithCenter:(NSPoint)center radius:(CGFloat)radius;
@end
