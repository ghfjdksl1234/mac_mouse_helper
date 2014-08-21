//
//  ScreenEdgeList.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/20/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenEdgeList : NSObject
@property (strong, nonatomic) NSScreen* screen;

@property (strong, nonatomic) NSMutableArray* left;
@property (strong, nonatomic) NSMutableArray* top;
@property (strong, nonatomic) NSMutableArray* right;
@property (strong, nonatomic) NSMutableArray* bottom;

-(id)initWithScreen:(NSScreen*)screen;
@end
