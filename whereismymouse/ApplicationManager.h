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
@end
