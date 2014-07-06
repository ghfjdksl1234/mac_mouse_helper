//
//  DisplayManager.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/6/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayManager : NSObject
+(DisplayManager*)getInstance;
-(void)addView:(NSView*)view screenNo:(int)screenNo;
-(void)removeView:(NSView*)view screenNo:(int)screenNo;
@end