//
//  EdgeGuideView.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EdgeGuideView : NSView
- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y vertical:(BOOL)vertical;
- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y vertical:(BOOL)vertical alpha:(CGFloat)alpha;
- (void)updateWith:(NSPoint)location;
+ (int)WIDTH;
+ (int)HEIGHT;
@end
