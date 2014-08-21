//
//  ScreenNoView.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define SCREEN_NO_WIDTH 500
#define SCREEN_NO_HEIGHT 500
#define FONT_SIZE       300

@interface ScreenNoView : NSView
- (id)initWithFrame:(NSRect)frame screenNo:(int)screenNo;
@end
