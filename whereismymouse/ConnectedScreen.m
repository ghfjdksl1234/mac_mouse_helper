//
//  ConnectedScreen.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ConnectedScreen.h"

@implementation ConnectedScreen
-(id)init {
    self = [super init];
    if (self) {
        self.left = [[NSMutableArray alloc] init];
        self.top = [[NSMutableArray alloc] init];
        self.right = [[NSMutableArray alloc] init];
        self.bottom = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
