//
//  MouseEventDistributor.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 7/1/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "MouseEventDistributor.h"

@interface MouseEventDistributor()
@property (strong, nonatomic) NSMutableArray* observers;
@end

@implementation MouseEventDistributor
- (id) init {
    self.observers = [[NSMutableArray alloc] init];
    return self;
}

- (void) addObserver:(NSObject<MouseEventObserver>*)observer {
    [self.observers addObject:observer];
}
- (void) removeObserver:(NSObject<MouseEventObserver>*)observer {
    [self.observers removeObject:observer];
}

- (void)onMoveWithEvent:(MouseEvent *)event {
    for (NSObject<MouseEventObserver>* observer in self.observers) {
        [observer onMoveWithEvent:event];
    }
}
@end
