//
//  AppDelegate.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/30/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MotionEventRouter.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusBar;
@property (strong, nonatomic) MotionEventRouter* mouseEventRouter;
@property (weak) IBOutlet NSMenuItem *menuEnableShake;

@end
