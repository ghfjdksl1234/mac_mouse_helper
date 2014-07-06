//
//  DisplayManager.m
//  ;
//
//  Created by Choi Wonjoon on 7/6/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "DisplayManager.h"
#import "OverlayWindow.h"

@interface DisplayManager()
@property (strong, nonatomic)NSMutableDictionary* windowControllerDic;
@end

@implementation DisplayManager
+(DisplayManager*)getInstance {
    static dispatch_once_t pred;
    static DisplayManager* instance;
    
    dispatch_once(&pred, ^{
        instance = [[DisplayManager alloc] init];
    });
    return instance;
}
-(id)init {
    self.windowControllerDic = [[NSMutableDictionary alloc] init];
    return self;
}
-(void)addView:(NSView*)view screenNo:(int)screenNo {
    NSView* parentView = [self getParentViewForDisplay:screenNo];
    [parentView addSubview:view];
}
-(void)removeView:(NSView*)view screenNo:(int)screenNo {
    NSWindowController* controller = [self.windowControllerDic objectForKey:[NSNumber numberWithInt:screenNo]];
    [view removeFromSuperview];
    if (controller != nil && [controller.window.contentView subviews].count == 0) {
        [self.windowControllerDic removeObjectForKey:[NSNumber numberWithInt:screenNo]];
    }
}
-(NSView*)getParentViewForDisplay:(int)screenNo {
    NSScreen* screen = [[NSScreen screens] objectAtIndex:screenNo];
    
    NSRect frame = screen.frame;
    
    NSRect rect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width,  frame.size.height);
    
    NSWindowController *windowController = [[NSWindowController alloc] initWithWindowNibName:@"OverlayWindow"];
    OverlayWindow *window = (OverlayWindow*)windowController.window;
    [window setFrame:rect display:YES];
    [window makeKeyAndOrderFront: nil];
    
    [self.windowControllerDic setObject:windowController forKey:[NSNumber numberWithInt:screenNo]];
    
    return window.contentView;
}
@end
