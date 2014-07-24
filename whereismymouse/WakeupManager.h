//
//  MouseRelocator.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/24/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"
#import "ShakeDisplayManager.h"

@interface WakeupManager : NSObject<MouseEventObserver, DisplayEventObserver>
-(id)init;
-(void)onMoveWithEvent:(MouseEvent *)event;
-(void)onStartDisplay;
-(void)onEndDisplay;
@end
