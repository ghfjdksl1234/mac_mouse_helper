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
@property (weak, nonatomic)NSObject<DisplayKeyEventListener>* listener;
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
    self.listener = nil;
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
    NSWindowController* windowController = [self.windowControllerDic objectForKey:[NSNumber numberWithInt:screenNo]];
    if (windowController == nil) {
        NSScreen* screen = [[NSScreen screens] objectAtIndex:screenNo];
        
        NSRect frame = screen.frame;
        
        NSRect rect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width,  frame.size.height);
        
        windowController = [[NSWindowController alloc] initWithWindowNibName:@"OverlayWindow"];
        OverlayWindow *window = (OverlayWindow*)windowController.window;
        [window setFrame:rect display:YES];
        [window makeKeyAndOrderFront: nil];
        
        [self.windowControllerDic setObject:windowController forKey:[NSNumber numberWithInt:screenNo]];
        if (self.listener != nil) {
            [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
        }
    }
    return windowController.window.contentView;
}

-(void)setKeyEventListener:(NSObject<DisplayKeyEventListener>*)listener {
    if (listener != nil) {
        if (self.listener == nil) {
            [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent *event) {
                if (self.listener != nil) {
                    [self.listener onKey:event.keyCode];
                }
                return event;
            }];
        }
        self.listener = listener;
        [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    } else {
        self.listener = nil;
//        disable listening
    }
}
@end
