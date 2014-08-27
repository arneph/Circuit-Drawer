//
//  CDCircuitObject.m
//  Circuit Drawer
//
//  Created by Programmieren on 31.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDCircuitObject.h"

@implementation CDCircuitObject
@synthesize coordinate = _coordinate;

#pragma mark Initialisation

- (instancetype)init{
    self = [super init];
    if (self) {
        _coordinate = make2DCoordinate(0, 0);
    }
    return self;
}

- (instancetype)initWithCoordinate: (CD2DCoordinate)c{
    if (c.x1 < 0 || c.x2 < 0) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        _coordinate = c;
    }
    return self;
}

- (instancetype)initWithCoder: (NSCoder *)coder{
    self = [super init];
    if (self) {
        NSInteger x1 = [coder decodeIntegerForKey: @"x1"];
        NSInteger x2 = [coder decodeIntegerForKey: @"x2"];
        _coordinate = make2DCoordinate(x1, x2);
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder{
    [aCoder encodeInteger: _coordinate.x1 forKey: @"x1"];
    [aCoder encodeInteger: _coordinate.x2 forKey: @"x2"];
}

- (instancetype)copyWithZone:(NSZone *)zone{
    return [[[self class] alloc] initWithCoordinate: _coordinate];
}

#pragma mark Properties

- (CD2DCoordinate)coordinate{
    return _coordinate;
}

- (void)setCoordinate:(CD2DCoordinate)coordinate{
    if (coordinate.x1 < 0 || coordinate.x2 < 0) {
        @throw NSInvalidArgumentException;
        return;
    }
    CD2DCoordinate oldCooridnate = _coordinate;
    _coordinate = coordinate;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: CDCircuitObjectCoordinateChangedNotification
                                                        object: self
                                                      userInfo: @{@"oldCoordinate" : dictionaryStoringCoordinate(oldCooridnate)}];
}

#pragma mark Public Methods

- (NSUInteger)numberOfConnectableSides{
    NSUInteger c = 0;
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides side = (1 << i);
        if ([self canConnectToSide: side]) {
            c++;
        }
    }
    return c;
}

- (BOOL)canConnectToSide: (CD2DSides)side{
    if (_isLeftMost && (side & CD2DSideTopLeft || side & CD2DSideLeft || side & CD2DSideBottomLeft)) {
        return NO;
    }else if (_isRightMost && (side & CD2DSideTopRight || side & CD2DSideRight || side & CD2DSideBottomRight)) {
        return NO;
    }else if (_isBottomMost && (side & CD2DSideBottomLeft || side & CD2DSideBottom || side & CD2DSideBottomRight)) {
        return NO;
    }else if (_isTopMost && (side & CD2DSideTopLeft || side & CD2DSideTop || side & CD2DSideTopRight)) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)hasConnectionToSide:(CD2DSides)side{
    return NO;
}

@end
