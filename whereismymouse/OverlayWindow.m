//
//  OverlayWindow.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/30/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "OverlayWindow.h"
#import "GrandCircleView.h"

@interface OverlayWindow()
@property CGFloat x, y, orgX, orgY;
@end

@implementation OverlayWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    
    if ( self ) {
        [self setOpaque:NO]; // Needed so we can see through it when we have clear stuff on top
        [self setHasShadow:YES];
        [self setLevel:NSFloatingWindowLevel]; // Let's make it sit on top of everything else
        NSColor *transparentColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        [self setBackgroundColor:transparentColor];
        [self setIgnoresMouseEvents:YES];
    }
    
    return self;
}
- (void)awakeFromNib {
}

- (void)initOriginWithPosX:(CGFloat)x posY:(CGFloat)y {
    self.orgX = x;
    self.orgY = y;
}
- (void)updateWithCenter:(NSPoint)center radius:(CGFloat)radius {
    GrandCircleView* view = (GrandCircleView*)self.contentView;
    [view updatePositionWithCenter:NSMakePoint(center.x-self.orgX, center.y-self.orgY) radius:radius];
    [view setNeedsDisplay:YES];
}
@end
