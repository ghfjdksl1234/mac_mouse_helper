//
//  AppDelegate.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/30/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ApplicationManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusBar;
@property (strong, nonatomic) ApplicationManager* applicationManager;
@property (weak) IBOutlet NSMenuItem *menuEnableShake;
@property (weak) IBOutlet NSMenuItem *menuEnableCross;
@property (weak) IBOutlet NSMenuItem *menuShowAlighGuideHorLine;
@property (weak) IBOutlet NSMenuItem *menuShowAlignGuideVertLine;

@end
