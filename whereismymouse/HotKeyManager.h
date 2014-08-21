//
//  HotKeyManager.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayManager.h"

@interface HotKeyManager : NSObject<DisplayKeyEventListener>
-(BOOL)setEnable:(BOOL)enable;
@end
