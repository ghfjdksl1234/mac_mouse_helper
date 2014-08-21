//
//  HotKeyManager.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "HotKeyManager.h"
#import "DDHotKeyCenter.h"
#import <Carbon/Carbon.h>
#import "ScreenNoView.h"
#import "DisplayManager.h"
#import "ViewScreenNoItem.h"
#import "ApplicationManager.h"

#define DISPLAY_TIME 3

@interface HotKeyManager()

@property BOOL isDisplaying;
@property (strong, nonatomic)NSMutableArray* viewList;
@property (strong,nonatomic)NSArray *sortedArray;
@property (weak,nonatomic)NSTimer *timer;
@end

@implementation HotKeyManager
-(id)init {
    self = [super init];
    if (self != nil) {
        self.viewList = [[NSMutableArray alloc] init];
        self.isDisplaying = NO;
    }
    return self;
}
-(BOOL)setEnable:(BOOL)enable {
    BOOL success = NO;
    if (enable) {
        success = [self registerHotKey];
    } else {
        success = [self unregisterHotKey];
    }
    return success;
}
-(BOOL)registerHotKey {
    BOOL success = NO;
    DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	if ([c registerHotKeyWithKeyCode:kVK_ANSI_M modifierFlags:NSFunctionKeyMask|NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask target:self action:@selector(hotkeyWithEvent:) object:nil]) {
        success = YES;
	}
    return success;
}
-(BOOL)unregisterHotKey {
    DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	[c unregisterHotKeyWithKeyCode:kVK_ANSI_M modifierFlags:NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask ];
    return YES;
}
-(void)hotkeyWithEvent:(NSEvent *)hkEvent {
    if (self.isDisplaying == NO) {
        [self startDisplay];
        self.isDisplaying = YES;
    }
}
-(void)startDisplay {
    NSArray *sortedArray = [[NSScreen screens] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult order = NSOrderedSame;
        
        NSScreen* screen1 = obj1;
        NSScreen* screen2 = obj2;
        
//        if (screen1.frame.origin.y < screen2.frame.origin.y) {
//            order = NSOrderedDescending;
//        } else if (screen2.frame.origin.y < screen1.frame.origin.y) {
//            order = NSOrderedAscending;
//        } else if (screen1.frame.origin.x < screen2.frame.origin.x) {
//            order = NSOrderedDescending;
//        } else if (screen2.frame.origin.x < screen1.frame.origin.x) {
//            order = NSOrderedAscending;
//        }
        if (screen1.frame.origin.x < screen2.frame.origin.x) {
            order = NSOrderedAscending;
        } else if (screen2.frame.origin.x < screen1.frame.origin.x) {
            order = NSOrderedDescending;
        }
        return order;
    }];
    self.sortedArray = sortedArray;
    
    int index = 0;
    for (NSScreen* screen in sortedArray) {
        if (index == 10) {
            break;
        }
        int screenNo = [[NSScreen screens] indexOfObject:screen];
        CGFloat left = (NSWidth(screen.frame) - SCREEN_NO_WIDTH)/2;
        CGFloat top = (NSHeight(screen.frame) - SCREEN_NO_HEIGHT)/2;
        ScreenNoView* view = [[ScreenNoView alloc] initWithFrame:NSMakeRect(left, top, SCREEN_NO_WIDTH, SCREEN_NO_HEIGHT) screenNo:index+1];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        index++;
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:DISPLAY_TIME target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
    [[DisplayManager getInstance] setKeyEventListener:self];
    
}
- (void)onTimer {
//    [[DisplayManager getInstance] setKeyEventListener:nil];
    [self destroyViews];
//    [[DisplayManager getInstance] setKeyEnable:NO];
}
- (void)destroyViews {
    for (ViewScreenNoItem* item in self.viewList) {
        [[DisplayManager getInstance] removeView:item.view screenNo:item.screenNo];
    }
    [self.viewList removeAllObjects];
    [self.timer invalidate];
    self.timer = nil;
    self.sortedArray = nil;
    self.isDisplaying = NO;
}
-(void)onKey:(unsigned short) keycode {
    if (kVK_ANSI_1 <= keycode && keycode <= kVK_ANSI_0) {
        int index = keycode - kVK_ANSI_1;
        if (index < self.sortedArray.count) {
            NSRect frame = ((NSScreen*)[self.sortedArray objectAtIndex:index]).frame;
            CGPoint origin = frame.origin;
            CGSize size = frame.size;
            CGPoint point = CGPointMake(origin.x + size.width/2, origin.y + size.height/2);
            [ApplicationManager moveMouseToGlobalPos:point];
            [self destroyViews];
        }
    }
}
@end
