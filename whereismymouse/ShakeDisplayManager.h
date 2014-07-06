//
//  DisplayManager.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@protocol DisplayEventObserver <NSObject>
- (void)onStartDisplay;
- (void)onEndDisplay;
@end

@interface ShakeDisplayManager : NSObject<MouseEventObserver>
- (void)addObserver:(NSObject<DisplayEventObserver>*)observer;
@end
