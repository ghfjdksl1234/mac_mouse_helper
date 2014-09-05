//
//  CursorShowView.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/5/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "CursorShowView.h"

#define MAX_WIDTH 100

@interface CursorShowView()
@property CGFloat orgX, orgY, x, y;
@property CGFloat radius;
@end

@implementation CursorShowView

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
    [super drawRect:dirtyRect];    
    
    NSArray* colors = @[[NSColor redColor], [NSColor yellowColor], [NSColor redColor]];
    
    NSGradient* gradient = [[NSGradient alloc] initWithColors:colors];
    CGFloat innerCircle = self.radius * 0.9;
    if (MAX_WIDTH < self.radius - innerCircle) {
        innerCircle = self.radius - MAX_WIDTH;
    }
    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:self.radius toCenter:NSMakePoint(self.x, self.y) radius:innerCircle options:0];
}

@end
