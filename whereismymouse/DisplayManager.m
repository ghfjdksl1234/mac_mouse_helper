//
//  DisplayManager.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "DisplayManager.h"
#import "OverlayWindow.h"

#define STATUS_SLEEP 0
#define STATUS_DISPLAY 1

#define TIME_DISPLAY_IN_SEC (1.5)

@interface DisplayManager()
@property NSTimeInterval startInterval;
@property NSPoint center;
@property CGFloat maxRadius;
@property (strong, nonatomic)NSMutableArray* windowControllerList;
@property (strong, nonatomic)NSMutableArray* observerList;
@property int status;
@end

@implementation DisplayManager
-(id)init {
    self = [super init];
    if (self) {
        self.observerList = [[NSMutableArray alloc] init];
        self.windowControllerList = [[NSMutableArray alloc] init];

        self.status = STATUS_SLEEP;
    }
    return self;
}
-(void)addObserver:(NSObject<DisplayEventObserver> *)observer {
    [self.observerList addObject:observer];
}
-(void)fireEventStartDisplay {
    for (NSObject<DisplayEventObserver> *observer in self.observerList) {
        [observer onStartDisplay];
    }
}
-(void)fireEventEndDisplay {
    for (NSObject<DisplayEventObserver> *observer in self.observerList) {
        [observer onEndDisplay];
    }
}

-(void)onMoveWithEvent:(MouseEvent *)event {
    NSTimeInterval timestamp = [event getTimestamp];
    CGFloat x = [event getX];
    CGFloat y = [event getY];
    switch (self.status) {
        case STATUS_SLEEP:
            self.startInterval = [[NSDate alloc] init].timeIntervalSince1970;
            [self createWindowsWithCenter:NSMakePoint(x, y)];
            [self setTimer];
            [self fireEventStartDisplay];
            self.status = STATUS_DISPLAY;
        case STATUS_DISPLAY:
            self.center = NSMakePoint(x, y);
            [self update];
            break;
    }
}
-(void)update {
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    CGFloat radius = self.maxRadius * (TIME_DISPLAY_IN_SEC - (now - self.startInterval)) / TIME_DISPLAY_IN_SEC;
    for(NSWindowController* controller in self.windowControllerList) {
        OverlayWindow* window = (OverlayWindow*) controller.window;
        [window updateWithCenter:self.center radius:radius];
    }
    
}
- (void)createWindowsWithCenter:(NSPoint) center {
//    [NSStatusBar systemStatusBar]
    NSPoint origin, end;
    for(NSScreen* screen in [NSScreen screens]) {
//        NSRect frame = screen.visibleFrame;
        NSRect frame = screen.frame;
        
        if (frame.origin.x < origin.x) {
            origin.x = frame.origin.x;
        }
        if (frame.origin.y < origin.y) {
            origin.y = frame.origin.y;
        }
        
        if (end.x < frame.origin.x+frame.size.width) {
            end.x = frame.origin.x+frame.size.width;
        }
        if (end.y < frame.origin.y+frame.size.height) {
            end.y = frame.origin.y+frame.size.height;
        }
        
        NSRect rect = NSMakeRect(frame.origin.x, frame.origin.y, frame.size.width,  frame.size.height);
        
        NSWindowController *windowController = [[NSWindowController alloc] initWithWindowNibName:@"OverlayWindow"];
        OverlayWindow *window = (OverlayWindow*)windowController.window;
        [window setFrame:rect display:YES];
        [window makeKeyAndOrderFront: nil];
        [window initOriginWithPosX:frame.origin.x posY:frame.origin.y];
        
        [self.windowControllerList addObject:windowController];
    }
    CGFloat xDist = MAX(ABS(center.x - origin.x), ABS(center.x - end.x));
    CGFloat yDist = MAX(ABS(center.y - origin.y), ABS(center.y - end.y));
    self.maxRadius = sqrt(xDist*xDist + yDist*yDist);
}
- (void)onTimer {
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    if (TIME_DISPLAY_IN_SEC <= now - self.startInterval) {
        [self destroyWindows];
        [self fireEventEndDisplay];
        self.status = STATUS_SLEEP;
    } else {
        [self update];
        [NSTimer scheduledTimerWithTimeInterval:0.00001 target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
    }
}
- (void)destroyWindows {
    for (NSWindowController* controller in self.windowControllerList) {
        [controller close];
    }
    [self.windowControllerList removeAllObjects];
}
- (void)setTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.00001 target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
}
@end
