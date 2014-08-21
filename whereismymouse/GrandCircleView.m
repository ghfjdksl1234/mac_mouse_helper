//
//  GrandCircleView.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 6/7/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "GrandCircleView.h"

#define MAX_WIDTH 60

@interface GrandCircleView()
@property CGFloat orgX, orgY, x, y;
@property CGFloat radius;
@end

@implementation GrandCircleView

- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlphaValue:1]; // It'll start out mostly transparent
        self.orgX = x;
        self.orgY = y;
    }
    return self;
}
- (void)updateWithCenter:(NSPoint)center radius:(CGFloat)radius {
    self.x = center.x-self.orgX;
    self.y = center.y-self.orgY;
    self.radius = radius;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    [super drawRect:dirtyRect];
    
    /*
    // Create our circle path
    NSRect circleRect = NSMakeRect(self.x-self.radius, self.y - self.radius, self.radius*2, self.radius*2);
    
    NSBezierPath* outside = [NSBezierPath bezierPathWithRect:dirtyRect];
    NSBezierPath* circlePath = [NSBezierPath bezierPathWithOvalInRect:circleRect];
    circlePath = [circlePath bezierPathByReversingPath];
    [outside appendBezierPath:circlePath];
    
    NSColor *fillColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [fillColor setFill];
    [outside fill];
     */
    
    
    NSArray* colors = @[[NSColor redColor], [NSColor yellowColor], [NSColor redColor]];

    NSGradient* gradient = [[NSGradient alloc] initWithColors:colors];
    CGFloat innerCircle = self.radius * 0.9;
    if (MAX_WIDTH < self.radius - innerCircle) {
        innerCircle = self.radius - MAX_WIDTH;
    }
    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:self.radius toCenter:NSMakePoint(self.x, self.y) radius:innerCircle options:0];
     
    
    /*
    CGFloat innerCircle = self.radius * 0.9;
    if (MAX_WIDTH < self.radius - innerCircle) {
        innerCircle = self.radius - MAX_WIDTH;
    }
    
    int divideSize = 3;
    CGFloat width = (self.radius - innerCircle)/divideSize;
    NSArray *colors = @[[NSColor redColor], [NSColor yellowColor]];
    for (int i = 0; i < divideSize ; i++) {
        [[NSColor purpleColor] setStroke];
        // Create our circle path
        NSRect rect = NSMakeRect(self.x-self.radius + width*i, self.y - self.radius + width*i, self.radius*2 - width*i*2, self.radius*2 - width*i*2);
        NSBezierPath* circlePath = [NSBezierPath bezierPath];
        [colors[i%2] setStroke];
        [circlePath setLineWidth:width];
        [circlePath appendBezierPathWithOvalInRect: rect];
        
        // Outline and fill the path
        [circlePath stroke];
    }
     */
    
    /*
    NSArray* colors = @[[NSColor redColor], [NSColor yellowColor]];
    NSGradient* gradient = [[NSGradient alloc] initWithColors:colors];
    //    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:50 toCenter:NSMakePoint(self.x, self.y) radius:30 options:0];
    CGFloat innerCircle = self.radius * 0.9;
    if (70 < self.radius - innerCircle) {
        innerCircle = self.radius - 70;
    }
    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:self.radius toCenter:NSMakePoint(self.x, self.y) radius:innerCircle options:0];
    */

    /*
    [[NSColor purpleColor] setStroke];
    // Create our circle path
    NSRect rect = NSMakeRect(self.x-self.radius, self.y - self.radius, self.radius*2, self.radius*2);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath setLineWidth:20];
    [circlePath appendBezierPathWithOvalInRect: rect];
    
    // Outline and fill the path
    [circlePath stroke];
     */
    
    [NSGraphicsContext restoreGraphicsState];
}
@end
