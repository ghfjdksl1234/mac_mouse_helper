//
//  ApplicationManager.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/1/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@interface ApplicationManager : NSObject<MouseEventObserver>
- (id) init;
- (void) setEnableShake:(BOOL)enable;
- (void) setEnableCross:(BOOL)enable;
- (void) setShowEdgeAlignGuide:(BOOL)enable;
//- (void) setEnableCenterAtWakeup:(BOOL)enable;

+ (void) moveMouseToGlobalPos:(CGPoint)point;

- (void)didChangeScreenParameters:(NSNotification *)notification;
@end
