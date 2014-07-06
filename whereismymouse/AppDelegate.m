//
//  AppDelegate.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/30/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "AppDelegate.h"
#import "MouseEvent.h"
//#import "testinput.h"

@interface AppDelegate()
@property BOOL isEnabledShake;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.menuEnableShake setState:NSOnState];
    self.isEnabledShake = YES;
    [self setStartAtLogin:YES];
    self.applicationManager = [[ApplicationManager alloc] init];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent* event) {
        NSPoint position = [NSEvent mouseLocation];
        if (self.isEnabledShake) {
            MouseEvent* mouseEvent = [[MouseEvent alloc] initWithTimestamp:event.timestamp posX:position.x posY:position.y];
            [self.applicationManager onMoveWithEvent:mouseEvent];
        }
    }];
    /*/
    for (int i = 0 ; i < sizeof(testInput) / sizeof(testInput[0]) ; i++) {
        double* input = testInput[i];
        [self.mouseEventRouter onMoveWithTimestamp:input[0] posX:input[1] posY:input[2]];
    }
    /**/
}
- (void)awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"WMouse";
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}
- (IBAction)onEnableShake:(id)sender {
    switch (self.menuEnableShake.state) {
        case NSOnState:
            [self.menuEnableShake setState:NSOffState];
            self.isEnabledShake = NO;
            break;
        case NSOffState:
            [self.menuEnableShake setState:NSOnState];
            self.isEnabledShake = YES;
            break;
    }
    
}

+ (BOOL) willStartAtLogin:(NSURL *)itemURL
{
    Boolean foundIt=false;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(loginItems, &seed);
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)CFBridgingRetain(itemObject);
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                foundIt = CFEqual(URL, CFBridgingRetain(itemURL));
                CFRelease(URL);
                
                if (foundIt)
                    break;
            }
        }
        CFRelease(loginItems);
    }
    return (BOOL)foundIt;
}

+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled
{
    LSSharedFileListItemRef existingItem = NULL;
    
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) {
        UInt32 seed = 0U;
        NSArray *currentLoginItems = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(loginItems, &seed);
        for (id itemObject in currentLoginItems) {
            LSSharedFileListItemRef item = (LSSharedFileListItemRef)CFBridgingRetain(itemObject);
            
            UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
            CFURLRef URL = NULL;
            OSStatus err = LSSharedFileListItemResolve(item, resolutionFlags, &URL, /*outRef*/ NULL);
            if (err == noErr) {
                Boolean foundIt = CFEqual(URL, CFBridgingRetain(itemURL));
                CFRelease(URL);
                
                if (foundIt) {
                    existingItem = item;
                    break;
                }
            }
        }
        
        if (enabled && (existingItem == NULL)) {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst,
                                          NULL, NULL, (CFURLRef)CFBridgingRetain(itemURL), NULL, NULL);
            
        } else if (!enabled && (existingItem != NULL))
            LSSharedFileListItemRemove(loginItems, existingItem);
        
        CFRelease(loginItems);
    }       
}
- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)startAtLogin
{
    return [AppDelegate willStartAtLogin:[self appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [AppDelegate setStartAtLogin:[self appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}
- (IBAction)menuEnableShake:(NSMenuItem *)sender {
}
@end
