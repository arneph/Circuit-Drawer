//
//  CDDiode.m
//  Circuit Drawer
//
//  Created by Programmieren on 23.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDDiode.h"

@implementation CDDiode
@synthesize anode = _anode;
@synthesize cathode = _cathode;

#pragma mark Initialisation

- (instancetype)init{
    self = [super init];
    if (self) {
        _anode = CD2DSideLeft;
        _cathode = CD2DSideRight;
    }
    return self;
}

- (instancetype)initWithCoordinate: (CD2DCoordinate)c{
    self = [super initWithCoordinate: c];
    if (self) {
        _anode = CD2DSideLeft;
        _cathode = CD2DSideRight;
    }
    return self;
}

- (instancetype)initWithAnode:(CD2DSides)anode{
    self = [super init];
    if (self) {
        _anode = CD2DSideLeft;
        _cathode = CD2DSideRight;
        
        [self setAnode: anode];
    }
    return self;
}

- (instancetype)initWithCathode:(CD2DSides)cathode{
    self = [super init];
    if (self) {
        _anode = CD2DSideLeft;
        _cathode = CD2DSideRight;
        
        [self setCathode: cathode];
    }
    return self;
}

- (instancetype)initWithCoder: (NSCoder *)aDecoder{
    self = [super initWithCoder: aDecoder];
    if (self) {
        _anode = (CD2DSides)[aDecoder decodeIntegerForKey: @"anode"];
        _cathode = (CD2DSides)[aDecoder decodeIntegerForKey: @"cathode"];
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder{
    [aCoder encodeInteger: _anode forKey: @"anode"];
    [aCoder encodeInteger: _cathode forKey: @"cathode"];
}

- (instancetype)copyWithZone:(NSZone *)zone{
    CDDiode *diode = [super copyWithZone: nil];
    diode.anode = _anode;
    diode.cathode = _cathode;
    return diode;
}

#pragma mark Notifications

- (void)postAnodeAndCathodeChangedNotificationOldAnode: (CD2DSides)oldAnode oldCathode: (CD2DSides)oldCathode{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDDiodeAnodeAndCathodeChangedNotification
                                                        object: self
                                                      userInfo: @{@"oldAnode": @(oldAnode),
                                                                  @"oldCathode" : @(oldCathode)}];
}

#pragma mark Properties

- (CD2DSides)anode{
    return _anode;
}

- (void)setAnode: (CD2DSides)anode{
    if (anode == _anode) return;
    if (numberOfSides(anode) != 1) return;
    
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides s = (1 << i);
        if (s == anode) {
            CD2DSides os = (1 << ((i + 4) % 8));
            
            CD2DSides oldAnode = _anode;
            CD2DSides oldCathode = _cathode;
            
            _anode = s;
            _cathode = os;
            
            [self postAnodeAndCathodeChangedNotificationOldAnode: oldAnode
                                                      oldCathode: oldCathode];
            return;
        }
    }
}

- (CD2DSides)cathode{
    return _cathode;
}

- (void)setCathode:(CD2DSides)cathode{
    if (cathode == _cathode) return;
    if (numberOfSides(cathode) != 1) return;
    
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides s = (1 << i);
        if (s == cathode) {
            CD2DSides os = (1 << ((i + 4) % 8));
            
            CD2DSides oldAnode = _anode;
            CD2DSides oldCathode = _cathode;
            
            _anode = os;
            _cathode = s;
            
            [self postAnodeAndCathodeChangedNotificationOldAnode: oldAnode
                                                      oldCathode: oldCathode];
            return;
        }
    }
}

#pragma mark Public Methods

- (NSUInteger)numberOfConnectableSides{
    return 2;
}

- (BOOL)canConnectToSide: (CD2DSides)side{
    if (side & _anode || side & _cathode) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)hasConnectionToSide: (CD2DSides)side{
    if (side & _anode || side & _cathode) {
        return YES;
    }else{
        return NO;
    }
}

- (void)rotateLeft{
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides s = (1 << i);
        if (s == _anode) {
            CD2DSides ns = (1 << ((i + 1) % 8));
            CD2DSides nos = (1 << ((i + 5) % 8));
            
            CD2DSides oldAnode = _anode;
            CD2DSides oldCathode = _cathode;
            
            _anode = ns;
            _cathode = nos;
            
            [self postAnodeAndCathodeChangedNotificationOldAnode: oldAnode
                                                      oldCathode: oldCathode];
            return;
        }
    }
}

- (void)rotateRight{
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides s = (1 << i);
        if (s == _anode) {
            CD2DSides ns = (1 << ((i + 7) % 8));
            CD2DSides nos = (1 << ((i + 3) % 8));
            
            CD2DSides oldAnode = _anode;
            CD2DSides oldCathode = _cathode;
            
            _anode = ns;
            _cathode = nos;
            
            [self postAnodeAndCathodeChangedNotificationOldAnode: oldAnode
                                                      oldCathode: oldCathode];
            return;
        }
    }
}

- (void)mirror{
    CD2DSides oldAnode = _anode;
    CD2DSides oldCathode = _cathode;
    
    _anode = oldCathode;
    _cathode = oldAnode;
    
    [self postAnodeAndCathodeChangedNotificationOldAnode: oldAnode
                                              oldCathode: oldCathode];
}

@end
