//
//  ScreenEdgeList.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ScreenEdgeList.h"

@implementation ScreenEdgeList
-(id)initWithScreen:(NSScreen*)screen {
    self = [super init];
    if (self != nil) {
        self.screen = screen;
        
        self.left = [[NSMutableArray alloc] init];
        self.top = [[NSMutableArray alloc] init];
        self.right = [[NSMutableArray alloc] init];
        self.bottom = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
