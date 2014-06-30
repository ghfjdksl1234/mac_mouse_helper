//
//  GrandCircleView.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 6/7/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "GrandCircleView.h"

@interface GrandCircleView()
@property CGFloat x, y;
@property CGFloat radius;
@end

@implementation GrandCircleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlphaValue:1]; // It'll start out mostly transparent

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    NSArray* colors = @[[NSColor redColor], [NSColor yellowColor]];
    NSGradient* gradient = [[NSGradient alloc] initWithColors:colors];
//    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:50 toCenter:NSMakePoint(self.x, self.y) radius:30 options:0];
    CGFloat innerCircle = self.radius * 0.9;
    if (70 < self.radius - innerCircle) {
        innerCircle = self.radius - 70;
    }
    [gradient drawFromCenter:NSMakePoint(self.x, self.y) radius:self.radius toCenter:NSMakePoint(self.x, self.y) radius:innerCircle options:0];

    
//    [[NSColor purpleColor] setStroke];
//    // Create our circle path
//    NSRect rect = NSMakeRect(self.x-self.radius, self.y - self.radius, self.radius*2, self.radius*2);
//    NSBezierPath* circlePath = [NSBezierPath bezierPath];
//    [circlePath setLineWidth:20];
//    [circlePath appendBezierPathWithOvalInRect: rect];
//    
//    // Outline and fill the path
//    [circlePath stroke];
    
}

-(void)updatePositionWithCenter:(NSPoint)center radius:(CGFloat)radius {
    //printf("update : (%5.2f, %5.2f) %6.2f\n%s", center.x, center.y, radius);
    self.x = center.x;
    self.y = center.y;
    self.radius = radius;
    [self setNeedsDisplay:YES];
}
@end
