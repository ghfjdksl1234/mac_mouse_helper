//
//  GrandCircleView.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 6/7/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GrandCircleView : NSView
-(void)updatePositionWithCenter:(NSPoint)center radius:(CGFloat)radius;
@end
