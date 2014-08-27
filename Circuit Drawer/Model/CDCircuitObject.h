//
//  CDCircuitObject.h
//  Circuit Drawer
//
//  Created by Programmieren on 31.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CD2DBaseTypes.h"

#define CDCircuitObjectCoordinateChangedNotification @"CDCircuitObjectCoordinateChangedNotification"

@interface CDCircuitObject : NSObject <NSCoding, NSCopying>

@property CD2DCoordinate coordinate;
@property BOOL isLeftMost;
@property BOOL isRightMost;
@property BOOL isBottomMost;
@property BOOL isTopMost;

- (instancetype)initWithCoordinate: (CD2DCoordinate)c;

- (NSUInteger)numberOfConnectableSides;
- (BOOL)canConnectToSide: (CD2DSides)side;
- (BOOL)hasConnectionToSide: (CD2DSides)side;

@end
