//
//  CDDiode.h
//  Circuit Drawer
//
//  Created by Programmieren on 23.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCircuitObject.h"

#define CDDiodeAnodeAndCathodeChangedNotification @"CDDiodeAnodeAndCathodeChangedNotification"

@interface CDDiode : CDCircuitObject

@property CD2DSides anode;
@property CD2DSides cathode;

- (void)rotateLeft;
- (void)rotateRight;
- (void)mirror;

@end
