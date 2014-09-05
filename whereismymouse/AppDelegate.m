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

#define PREF_KEY_EDGE @"key_edge"

@interface AppDelegate()
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.menuEnableShake setState:NSOnState];
    [self.menuEnableCross setState:NSOnState];
    [self setStartAtLogin:YES];
    
    self.applicationManager = [[ApplicationManager alloc] init];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = preferences.dictionaryRepresentation;
    NSNumber *number = [dict objectForKey:PREF_KEY_EDGE];
    if (number != nil) {
        if ([number boolValue] == NO) {
            [self onEnableCross:NO];
        }
    }
}
- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {
    if (self.applicationManager != nil) {
        [self.applicationManager didChangeScreenParameters:notification];
    }
}
- (void)awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.image = [NSImage imageNamed:@"statusbarmenu_icon.png"];
//    self.statusBar.title = @"WMouse";
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
}
- (IBAction)onHelp:(id)sender {[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://inbedsoft.blogspot.kr/2014/09/where-is-my-mouse.html"]];
}
- (IBAction)onEnableShake:(id)sender {
    BOOL enable = YES;
    switch (self.menuEnableShake.state) {
        case NSOnState:
            [self.menuEnableShake setState:NSOffState];
            enable = NO;
            break;
        case NSOffState:
            [self.menuEnableShake setState:NSOnState];
            enable = YES;
            break;
    }
    [self.applicationManager setEnableShake:enable];
}

- (IBAction)onEnableCross:(id)sender {
    BOOL enable = YES;
    switch (self.menuEnableCross.state) {
        case NSOnState:
            [self.menuEnableCross setState:NSOffState];
            enable = NO;
            break;
        case NSOffState:
            [self.menuEnableCross setState:NSOnState];
            enable = YES;
            break;
    }
    [self.applicationManager setEnableCross:enable];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:enable],  PREF_KEY_EDGE, nil];
    [preferences setBool:enable forKey:PREF_KEY_EDGE];
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
@end
