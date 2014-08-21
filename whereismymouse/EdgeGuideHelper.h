//
//  EdgeGuideHelper.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MouseEventObserver.h"

@interface EdgeGuideHelper : NSObject<MouseEventObserver>
- (void)didChangeScreenParameters:(NSNotification *)notification;@end
