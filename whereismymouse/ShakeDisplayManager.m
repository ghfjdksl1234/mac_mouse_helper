//
//  DisplayManager.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ShakeDisplayManager.h"
#import "OverlayWindow.h"
#import "GrandCircleView.h"
#import "DisplayManager.h"

#define STATUS_SLEEP 0
#define STATUS_DISPLAY 1

#define TIME_DISPLAY_IN_SEC (1.5)

@interface ShakeDisplayManager()
@property NSTimeInterval startInterval;
@property NSPoint center;
@property CGFloat maxRadius;
@property (strong, nonatomic)NSMutableArray* viewList;
@property int status;
@end

@interface LocalItem : NSObject
@property (strong, nonatomic)GrandCircleView* view;
@property int screenNo;
- (id)initWithView:(NSView*)view screenNo:(int)screenNo;
@end

@implementation ShakeDisplayManager
-(id)init {
    self = [super init];
    if (self) {
        self.viewList = [[NSMutableArray alloc] init];

        self.status = STATUS_SLEEP;
    }
    return self;
}
-(void)fireEventStartDisplay {
    [self.observer onStartDisplay];
}
-(void)fireEventEndDisplay {
    [self.observer onEndDisplay];
}

-(void)onMoveWithEvent:(MouseEvent *)event {
    CGFloat x = [event getX];
    CGFloat y = [event getY];
    switch (self.status) {
        case STATUS_SLEEP:
            self.startInterval = [[NSDate alloc] init].timeIntervalSince1970;
            [self createViewsWithCenter:NSMakePoint(x, y)];
            [self setTimer];
            [self fireEventStartDisplay];
            self.status = STATUS_DISPLAY;
        case STATUS_DISPLAY:
            self.center = NSMakePoint(x, y);
            NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
            [self updateWithNow:now];
            break;
    }
}
-(void)updateWithNow:(NSTimeInterval)now {
    CGFloat radius = self.maxRadius * (TIME_DISPLAY_IN_SEC - (now - self.startInterval)) / TIME_DISPLAY_IN_SEC;

    for(LocalItem* item in self.viewList) {
        [item.view updateWithCenter:self.center radius:radius];
    }
}
- (void)createViewsWithCenter:(NSPoint) center {
    NSPoint origin, end;
    int index = 0;
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
        
        NSRect rect = NSMakeRect(0, 0, frame.size.width,  frame.size.height);
        GrandCircleView* view = [[GrandCircleView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y];
        [[DisplayManager getInstance] addView:view screenNo:index];
        [self.viewList addObject:[[LocalItem alloc] initWithView:view screenNo:index]];
        index++;
    }
    CGFloat xDist = MAX(ABS(center.x - origin.x), ABS(center.x - end.x));
    CGFloat yDist = MAX(ABS(center.y - origin.y), ABS(center.y - end.y));
    self.maxRadius = sqrt(xDist*xDist + yDist*yDist);
}
- (void)onTimer {
    NSTimeInterval now = [[NSDate alloc] init].timeIntervalSince1970;
    if (TIME_DISPLAY_IN_SEC <= now - self.startInterval) {
        [self destroyViews];
        [self fireEventEndDisplay];
        self.status = STATUS_SLEEP;
    } else {
        [self updateWithNow:now];
        [self setTimer];
    }
}
- (void)destroyViews {
    for (LocalItem* item in self.viewList) {
        [[DisplayManager getInstance] removeView:item.view screenNo:item.screenNo];
    }
    [self.viewList removeAllObjects];
}
- (void)setTimer {
    [NSTimer scheduledTimerWithTimeInterval:0.00001 target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
}
@end

@implementation LocalItem
-(id)initWithView:(GrandCircleView *)view screenNo:(int)screenNo {
    self.view = view;
    self.screenNo = screenNo;
    return self;
}

@end