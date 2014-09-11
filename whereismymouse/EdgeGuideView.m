
//
//  EdgeGuideView.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "EdgeGuideView.h"

#define WIDTH_VAL 100
#define HEIGHT_VAL 100

@interface EdgeGuideView()
@property BOOL vertical;
@property CGFloat orgX, orgY, x, y;
@end

@implementation EdgeGuideView

- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y vertical:(BOOL)vertical {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlphaValue:0.1]; // It'll start out mostly transparent
        
        self.orgX = x;
        self.orgY = y;
    }
    self.vertical = vertical;
    return self;
}
- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y vertical:(BOOL)vertical alpha:(CGFloat)alpha{
    self = [self initWithFrame:frame orgX:x orgY:y vertical:vertical];
    if (self) {
        [self setAlphaValue:alpha]; // It'll start out mostly transparent
    }
    return self;
}
- (void)updateWith:(NSPoint)location {
    self.x = location.x-self.orgX;
    self.y = location.y-self.orgY;
    
    [self setNeedsDisplay:YES];
}
+ (int)WIDTH {
    return WIDTH_VAL;
}
+ (int)HEIGHT {
    return HEIGHT_VAL;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor orangeColor] setStroke];
    NSBezierPath* path = [NSBezierPath bezierPath];
    if (self.vertical) {
        [path moveToPoint:NSMakePoint(self.x, 0)];
        [path lineToPoint:NSMakePoint(self.x, self.frame.size.height)];
    } else {
        [path moveToPoint:NSMakePoint(0, self.y)];
        [path lineToPoint:NSMakePoint(self.frame.size.width, self.y)];
    }
    [path setLineWidth:20];
    [path stroke];
}

@end
