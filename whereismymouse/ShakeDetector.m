//
//  MotionDetector.m
//  whereismymouse
//
//  Created by Choi Wonjoon on 3/31/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import "ShakeDetector.h"
#import "MotionEventRegulator.h"

/* contrains */
#define MIN_X_DISTANCE 20
#define MAX_X_DISTANCE 1000
#define MAX_Y_DISTANCE 280

/* direction */
#define DIRECTION_UNDEFINED -1
#define DIRECTION_PLUS       0
#define DIRECTION_MINUS      1

/* Event firing condition */
#define DIRECTION_COUNT      6
#define INPUT_TIME_BOUND 0.1
#define TOTAL_TIME_BOUND 2.1

@interface EventLogObject : NSObject
@property double timestamp;
@property float x;
@property float y;
- (EventLogObject*) initWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y;
@end

@implementation EventLogObject
- (EventLogObject*) initWithTimestamp:(NSTimeInterval)timestamp posX:(CGFloat)x posY:(CGFloat)y {
    self.timestamp = timestamp;
    self.x = x;
    self.y = y;
    
    return self;
}
@end

@interface ShakeDetector()
@property (strong, nonatomic) NSMutableArray* observerList;
@property (strong, nonatomic) NSMutableArray* eventList;
@property (strong, nonatomic) MotionEventRegulator* eventRegulator;

@property NSTimeInterval lastTimestamp;
@property CGFloat lastX;
@property CGFloat lastEndX;
@property int lastDirection;
@end

@implementation ShakeDetector
-(id)init {
    self = [super init];
    if (self) {
        self.observerList = [[NSMutableArray alloc] init];
        self.eventList= [[NSMutableArray alloc] init];
        self.eventRegulator = [[MotionEventRegulator alloc] init];
        
        [self clearEvent];
    }
    return self;
}
- (void)addObserver:(NSObject<ShakeObserver> *)observer {
    [self.observerList addObject:observer];
}
- (void)fireDetectionEvent {
    for (NSObject<ShakeObserver>* observer in self.observerList) {
        [observer onShakeDetected];
    }
}
- (void)clearEvent {
    if (0 < self.eventList.count) {
        [self.eventList removeAllObjects];
    }
    self.lastTimestamp = 0;
    self.lastX = -100000;
    self.lastEndX = -100000;
    self.lastDirection = DIRECTION_UNDEFINED;
}

- (void)onMoveWithEvent:(MouseEvent *)event {
    CGPoint point;
    NSTimeInterval timestamp = [event getTimestamp];
    CGFloat x = [event getX];
    CGFloat y = [event getY];
    
    if (INPUT_TIME_BOUND < (timestamp-self.lastTimestamp)) {
        [self clearEvent];
        self.lastEndX = x;
        self.lastX = x;
    }
    if ([self.eventRegulator nextWithMouseEvent:event pointObject:&point]) {
//        printf("(%10.4f) : x(%.2f), y(%.2f)\n", timestamp, x, y);
        int newDirection = DIRECTION_UNDEFINED;
        if (MIN_X_DISTANCE < fabs(self.lastEndX - x)) {
            if (self.lastX < x) {
                newDirection = DIRECTION_PLUS;
            } else if (x < self.lastX) {
                newDirection = DIRECTION_MINUS;
            }
        }
        if (newDirection != DIRECTION_UNDEFINED && self.lastDirection != newDirection) {
            self.lastDirection = newDirection;
            self.lastEndX = x;
            //                NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            //                    BOOL retVal = YES;
            //                    NSNumber* number = (NSNumber*) evaluatedObject;
            //                    if (TIME_BOUND<timestamp-[number doubleValue]) {
            //                        retVal = NO;
            //                    }
            //                    return retVal;
            //                }];
            //                [self.eventList filterUsingPredicate:predicate];
            //                [self.eventList addObject:[NSNumber numberWithDouble:timestamp]];
            int index;
            for (index = self.eventList.count - 1 ; 0 <= index ; index--) {
                EventLogObject *event = self.eventList[index];
                if (TOTAL_TIME_BOUND < (timestamp - event.timestamp) || MAX_X_DISTANCE < fabs(event.x - x)) {
                    break;
                }
            }
            while (0 <= index) {
                [self.eventList removeObjectAtIndex:index];
                index--;
            }
            [self.eventList addObject:[[EventLogObject alloc] initWithTimestamp:timestamp posX:x posY:y] ];
            
            //printf("\"loged %d\" : (%10.4f) : x(%.2f), y(%.2f)\n", self.eventList.count, timestamp, x, y);
            
            if (DIRECTION_COUNT <= self.eventList.count) {
                [self printLogs];
                [self fireDetectionEvent];
            }
        }
    }
    self.lastX = x;
    self.lastTimestamp = timestamp;
}
- (void)printLogs {
    NSMutableString* string = [[NSMutableString alloc] initWithString:@""];
    for (EventLogObject* object in self.eventList) {
        [string appendFormat:@"\"%6.3lf\" : (%4.2lf  /  %4.2lf)  ", object.timestamp, object.x, object.y];
    }
//    printf("-------------------event log-------------------\n%s", [string UTF8String]);
}
@end
