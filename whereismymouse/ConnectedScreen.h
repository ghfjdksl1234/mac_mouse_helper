//
//  ConnectedScreen.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 9/10/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectedScreen : NSObject
@property (strong, nonatomic) NSScreen* screen;
@property (strong, nonatomic) NSMutableArray* left;
@property (strong, nonatomic) NSMutableArray* top;
@property (strong, nonatomic) NSMutableArray* right;
@property (strong, nonatomic) NSMutableArray* bottom;
@end
