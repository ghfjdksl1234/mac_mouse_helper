//
//  DisplayEdgeGuid.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@interface DisplayEdgeGuideVertical : NSObject
- (void)didChangeScreenParameters:(NSNotification *)notification;
@end
