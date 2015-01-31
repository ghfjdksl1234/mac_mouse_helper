//
//  EdgeGuideView2.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EdgeGuideView2 : NSView
- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y colorDistance:(CGFloat)colorDistance vertical:(BOOL)vertical;
//+(int)VERTICAL_GUIDE_COLORS;
//+(int)HORIZONTAL_GUIDE_COLORS;

@end
