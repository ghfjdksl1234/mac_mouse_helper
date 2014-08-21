//
//  ScreenNoView.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ScreenNoView.h"

@interface ScreenNoView()
@end

@implementation ScreenNoView

- (id)initWithFrame:(NSRect)frame screenNo:(int)screenNo
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAlphaValue:0.9]; // It'll start out mostly transparent
        
        NSRect rect = self.frame;
        rect.origin.x = rect.origin.y = 0;
        NSTextView *textView = [[NSTextView alloc] initWithFrame:rect];
        [textView setBackgroundColor:nil];
        [textView setString:[NSString stringWithFormat:@"%d", screenNo]];
        [textView setFont:[NSFont userFontOfSize:400]];
        
        [self addSubview:textView];
        [textView alignCenter:self];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:50 yRadius:50];
    
    NSColor *lineColor = [NSColor blackColor];
    NSColor *fillColor = [NSColor whiteColor];
    [lineColor setStroke];
    [fillColor setFill];
    
    [path setLineWidth:20];
    [path fill];
    [path stroke];
    
    [super drawRect:dirtyRect];
}
@end
