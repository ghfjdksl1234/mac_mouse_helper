//
//  CursorShowView.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/5/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CursorShowView : NSView
- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y;
- (void)updateWithCenter:(NSPoint)center radius:(CGFloat)radius;
@end
