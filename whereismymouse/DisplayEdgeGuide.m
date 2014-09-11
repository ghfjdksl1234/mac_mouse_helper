//
//  DisplayEdgeGuid.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "DisplayEdgeGuide.h"
#import "ConnectedScreen.h"
#import "ViewScreenNoItem.h"
#import "DisplayManager.h"
//#import "EdgeGuideView.h"
#import "EdgeGuideView2.h"
#import "ViewScreenNoItem.h"

#define DISTANCE 200

@interface DisplayEdgeGuide()
//@property (strong, nonatomic) NSScreen* prevScreen;
//@property (strong, nonatomic) NSMutableArray* connectedSList;
@property (strong, nonatomic)NSMutableArray* viewList;
@property CGFloat widthDistance, heightDistance;
@end

@implementation DisplayEdgeGuide
-(id)init {
//    int maxWidth, maxHeight;
    self = [super init];
    if (self) {
//        self.prevScreen = nil;
//        self.connectedSList = [[NSMutableArray alloc] init];
        self.viewList = [[NSMutableArray alloc] init];
        
//        maxWidth = maxHeight = -1;
        
//        for (NSScreen* screen in [NSScreen screens]) {
//            ConnectedScreen* connected = [[ConnectedScreen alloc] init];
//            connected.screen = screen;
//            for (NSScreen* other in [NSScreen screens]) {
//                if (screen == other) {
//                    continue;
//                }
//                if (screen.frame.origin.x + screen.frame.size.width == other.frame.origin.x) {
//                    [connected.right addObject:other];
//                } else if (screen.frame.origin.y + screen.frame.size.height == other.frame.origin.y) {
//                    [connected.bottom addObject:other];
//                } else if (other.frame.origin.x + other.frame.size.width == screen.frame.origin.x) {
//                    [connected.left addObject:other];
//                } else if (other.frame.origin.y + other.frame.size.height == screen.frame.origin.y) {
//                    [connected.top addObject:other];
//                }
//            }
//            [self.connectedSList addObject:connected];
////            if (maxWidth < screen.frame.size.width) {
////                maxWidth = screen.frame.size.width;
////            }
////            if (maxHeight < screen.frame.size.height) {
////                maxHeight = screen.frame.size.height;
////            }
//        }
//        self.widthDistance = maxWidth / (CGFloat)(EdgeGuideView2.VERTICAL_GUIDE_COLORS + 1);
//        self.heightDistance = maxHeight / (CGFloat)(EdgeGuideView2.HORIZONTAL_GUIDE_COLORS + 1);
        self.widthDistance = DISTANCE;
        self.heightDistance = DISTANCE;
        int index = 0;
        for (NSScreen* screen in NSScreen.screens) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            
            EdgeGuideView2* view = [[EdgeGuideView2 alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y colorDistance:self.heightDistance];
            [[DisplayManager getInstance] addView:view screenNo:index];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:index]];
            index++;
        }
    }
    return self;
}
/*
-(void)onMoveWithEvent:(MouseEvent *)event {
    for (ConnectedScreen* connected in self.connectedSList) {
        if (NSPointInRect([event getPoint], connected.screen.frame)) {
            [self refreshWith:connected mouseEvent:event];
        }
    }
}
-(void)refreshWith:(ConnectedScreen*)connected mouseEvent:(MouseEvent*)event{
    if (self.prevScreen == connected.screen) {
        //update
//        for (ViewScreenNoItem* item in self.viewList) {
//            EdgeGuideView* view = item.view;
//            [view updateWith:[event getPoint]];
//        }
    } else {
        self.prevScreen = connected.screen;
        //destroy previous views
        [self removeAllViews];
        //create new views;
        [self addViewForLeftWith:connected];
        [self addViewForTopWith:connected];
        [self addViewForRightWith:connected];
        [self addViewForBottomWith:connected];

    }
}
- (void) addViewForLeftWith:(ConnectedScreen*)connected {
    if (0 < connected.left.count) {
        NSRect frame = connected.screen.frame;
        NSRect rect = NSMakeRect(0, 0, WIDTH, frame.size.height);
        
        EdgeGuideView2* view = [[EdgeGuideView2 alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y verticalGuide:YES colorDistance:self.heightDistance];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        for (NSScreen* screen in connected.left) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            
            EdgeGuideView2* view = [[EdgeGuideView2 alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y verticalGuide:YES colorDistance:self.heightDistance];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
}
- (void) addViewForTopWith:(ConnectedScreen*)connected {
}
- (void) addViewForRightWith:(ConnectedScreen*)connected {
    if (0 < connected.right.count) {
        NSRect frame = connected.screen.frame;
        NSRect rect = NSMakeRect(frame.size.width - WIDTH, 0, WIDTH, frame.size.height);
        
        EdgeGuideView2* view = [[EdgeGuideView2 alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y verticalGuide:YES colorDistance:self.heightDistance];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        for (NSScreen* screen in connected.right) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            
            EdgeGuideView2* view = [[EdgeGuideView2 alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y verticalGuide:YES colorDistance:self.heightDistance];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
}
- (void) addViewForBottomWith:(ConnectedScreen*)connected {
}
// Not good. Makes the user confused
- (void) addViewForLeftWith:(ConnectedScreen*)connected {
    if (0 < connected.left.count) {
        NSRect frame = connected.screen.frame;
//        NSRect rect = NSMakeRect(0, 0, EdgeGuideView.WIDTH, frame.size.height);
        
        NSRect rect = NSMakeRect(0, 0, frame.origin.x + frame.size.width, frame.size.height);
        EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:NO alpha:0.05];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        
        for (NSScreen* screen in connected.left) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:NO];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
    
}
- (void) addViewForTopWith:(ConnectedScreen*)connected {
    if (0 < connected.top.count) {
        NSRect frame = connected.screen.frame;
        NSRect rect = NSMakeRect(0, 0, frame.size.width, EdgeGuideView.HEIGHT);
        EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:YES];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        
        for (NSScreen* screen in connected.top) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:YES];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
    
}
- (void) addViewForRightWith:(ConnectedScreen*)connected {
    if (0 < connected.right.count) {
        NSRect frame = connected.screen.frame;
//        NSRect rect = NSMakeRect(frame.origin.x + frame.size.width - EdgeGuideView.WIDTH, 0, frame.origin.x + frame.size.width, frame.size.height);
        NSRect rect = NSMakeRect(0, 0, frame.origin.x + frame.size.width, frame.size.height);
        EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:NO alpha:0.05];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        
        for (NSScreen* screen in connected.right) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:NO];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
}
- (void) addViewForBottomWith:(ConnectedScreen*)connected {
    if (0 < connected.bottom.count) {
        NSRect frame = connected.screen.frame;
        NSRect rect = NSMakeRect(0, frame.size.height - EdgeGuideView.HEIGHT, frame.size.width, frame.size.height);
        EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:YES];
        int screenNo = [[NSScreen screens] indexOfObject:connected.screen];
        [[DisplayManager getInstance] addView:view screenNo:screenNo];
        [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        
        
        for (NSScreen* screen in connected.bottom) {
            NSRect frame = screen.frame;
            NSRect rect = NSMakeRect(0, 0, frame.size.width, frame.size.height);
            EdgeGuideView* view = [[EdgeGuideView alloc] initWithFrame:rect orgX:frame.origin.x orgY:frame.origin.y vertical:YES];
            int screenNo = [[NSScreen screens] indexOfObject:screen];
            [[DisplayManager getInstance] addView:view screenNo:screenNo];
            [self.viewList addObject:[[ViewScreenNoItem alloc] initWithView:view screenNo:screenNo]];
        }
    }
}
 */
- (void)removeAllViews {
    for (ViewScreenNoItem* item in self.viewList) {
        [[DisplayManager getInstance] removeView:item.view screenNo:item.screenNo];
    }
}
- (void)didChangeScreenParameters:(NSNotification *)notification {
    [self removeAllViews];
    [self init];
}
- (void)dealloc {
    [self removeAllViews];
}
@end
