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
#import "CursorShowView.h"

#define DISPLAY_TIME 3
#define DISPLAY_CURSOR_TIME 0.7
#define RADIUS 120

@interface HotKeyManager()

@property BOOL isDisplaying;
@property (strong, nonatomic)NSMutableArray* viewList;
@property (strong,nonatomic)NSArray *sortedArray;
@property (weak,nonatomic)NSTimer *numberShowTimer;
@property NSTimeInterval startCircleInterval;
@property CGPoint center;
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
    self.numberShowTimer = [NSTimer scheduledTimerWithTimeInterval:DISPLAY_TIME target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
    [[DisplayManager getInstance] setKeyEventListener:self];
    
}
- (void)onTimer {
    [self destroyNumberViews];
}
- (void)destroyNumberViews {
    [[DisplayManager getInstance] setKeyEventListener:self];
    NSMutableArray* tempArray = [[NSMutableArray alloc]init];
    for (ViewScreenNoItem* item in self.viewList) {
        if ([item.view isKindOfClass:ScreenNoView.class]) {
            [tempArray addObject:item];
            [[DisplayManager getInstance] removeView:item.view screenNo:item.screenNo];
        }
    }
    [self.viewList removeObjectsInArray:tempArray];
    [self.numberShowTimer invalidate];
    self.numberShowTimer = nil;
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
            NSScreen* screen = [self.sortedArray objectAtIndex:index];
            [self destroyNumberViews];
//            [self showLocaionViewWithCenter:CGPointMake(150, 150) screen:[NSScreen screens][0]];
            [self showLocaionViewWithCenter:point screen:screen];
        }
    }
}
-(void)showLocaionViewWithCenter:(CGPoint)centerInGlobal screen:(NSScreen*)screen {
    int screenNo = [[NSScreen screens] indexOfObject:screen];
    NSRect frame = screen.frame;
    NSRect rect = frame;
    rect.origin.x = rect.origin.y = 0;
    CursorShowView* view = [[CursorShowView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y];
    [[DisplayManager getInstance] addView:view screenNo:screenNo];
    self.center = CGPointMake(centerInGlobal.x, centerInGlobal.y);
    [view updateWithCenter:self.center radius:RADIUS];
    [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
    self.startCircleInterval = [[NSDate alloc] init].timeIntervalSince1970;
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(destroyLocationView) userInfo:nil repeats:NO];
}
-(void)destroyLocationView {
    
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    if (DISPLAY_CURSOR_TIME <= now - self.startCircleInterval) {
        NSMutableArray* tempArray = [[NSMutableArray alloc]init];
        for (ViewScreenNoItem* item in self.viewList) {
            if ([item.view isKindOfClass:CursorShowView.class]) {
                [tempArray addObject:item];
                [[DisplayManager getInstance] removeView:item.view screenNo:item.screenNo];
            }
        }
        [self.viewList removeObjectsInArray:tempArray];
    } else {
        for (ViewScreenNoItem* item in self.viewList) {
            if ([item.view isKindOfClass:CursorShowView.class]) {
                int radius = RADIUS * (DISPLAY_CURSOR_TIME - (now - self.startCircleInterval)) / DISPLAY_CURSOR_TIME;
                [(CursorShowView*)item.view updateWithCenter:self.center radius:radius];
            }
        }
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(destroyLocationView) userInfo:nil repeats:NO];
    }
    
}
- (void) onMoveWithEvent:(MouseEvent*) event {
    self.center = [event getPoint];
}
@end
