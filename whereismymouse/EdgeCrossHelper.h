//
//  EdgeCrossHelper.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/7/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@interface EdgeCrossHelper : NSObject<MouseEventObserver>
- (void)didChangeScreenParameters:(NSNotification *)notification;
@end
