//
//  ViewScreenNoItem.h
//  whereismymouse
//
//  Created by Choi Wonjoon on 8/21/14.
//  Copyright (c) 2014 Choi Wonjoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewScreenNoItem : NSObject

@property (strong, nonatomic)NSView* view;
@property int screenNo;
- (id)initWithView:(NSView*)view screenNo:(int)screenNo;

@end
