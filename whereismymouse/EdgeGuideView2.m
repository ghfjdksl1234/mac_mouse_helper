//
//  EdgeGuideView2.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "EdgeGuideView2.h"

static NSArray* verticalColors;
static NSArray* horizontalColors;

@interface EdgeGuideView2()
@property CGFloat orgX, orgY;
@property CGFloat colorDistance;
@property BOOL vertical;
@end

static void initColors() {
    if (verticalColors == nil) {
        verticalColors = @[[NSColor redColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor greenColor], [NSColor blueColor], [NSColor purpleColor]];
    }
    if (horizontalColors == nil) {
        horizontalColors = @[[NSColor brownColor], [NSColor redColor], [NSColor orangeColor], [NSColor yellowColor], [NSColor greenColor], [NSColor blueColor], [NSColor purpleColor]];
    }
}
@implementation EdgeGuideView2

- (id)initWithFrame:(NSRect)frame orgX:(CGFloat)x orgY:(CGFloat)y colorDistance:(CGFloat)colorDistance vertical:(BOOL)vertical
{
    initColors();
    self = [super initWithFrame:frame];
    if (self) {
        self.orgX = x;
        self.orgY = y;
        self.colorDistance = colorDistance;
        self.vertical = vertical;
        if (vertical) {
            colorDistance *= 1.5;
        }
        
        [self setAlphaValue:1];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSColor* color;
    int colorIndex = 0;
    CGFloat red, green, blue;
    @try {
        if (self.vertical == false) {
            for (CGFloat y = ((int)-self.orgY % (int)self.colorDistance) + self.colorDistance ; y < self.frame.size.height ; y += self.colorDistance) {
                NSBezierPath* path = [NSBezierPath bezierPath];
                color = [verticalColors objectAtIndex:colorIndex];
                red = [color redComponent];
                green = [color greenComponent];
                blue = [color blueComponent];
                color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:0.3];
                [color setStroke];
                [path moveToPoint:NSMakePoint(0, y)];
                [path lineToPoint:NSMakePoint(self.frame.size.width, y)];
                [path setLineWidth:20];
                [path stroke];
                colorIndex++;
                if (verticalColors.count <= colorIndex) {
                    colorIndex = 0;
                }
                [path closePath];
            }
        } else {
            colorIndex = 0;
            for (CGFloat x = self.orgX + self.colorDistance ; x < self.frame.size.width; x += self.colorDistance) {
                NSBezierPath* path = [NSBezierPath bezierPath];
                color = [horizontalColors objectAtIndex:colorIndex];
                red = [color redComponent];
                green = [color greenComponent];
                blue = [color blueComponent];
                color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:0.5];
                [color setStroke];
                [path moveToPoint:NSMakePoint(x, 0)];
                [path lineToPoint:NSMakePoint(x, self.frame.size.height)];
                [path setLineWidth:20];
                [path stroke];
                colorIndex++;
                if (horizontalColors.count <= colorIndex) {
                    colorIndex = 0;
                }
                [path closePath];
            }
        }
    } @catch(NSException *err) {
        err = nil;
        
    }
}

//+(int)VERTICAL_GUIDE_COLORS {
//    initColors();
//    return verticalColors.count;
//}
//+(int)HORIZONTAL_GUIDE_COLORS {
//    initColors();
//    return horizontalColors.count;
//}
@end
