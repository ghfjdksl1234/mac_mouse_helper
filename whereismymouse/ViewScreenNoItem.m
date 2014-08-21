//
//  ViewScreenNoItem.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ViewScreenNoItem.h"

@implementation ViewScreenNoItem

-(id)initWithView:(NSView *)view screenNo:(int)screenNo {
    self.view = view;
    self.screenNo = screenNo;
    return self;
}
@end
