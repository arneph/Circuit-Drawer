//
//  CDConnectionElement.m
//  Circuit Drawer
//
//  Created by Programmieren on 31.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDConnectionElement.h"

@implementation CDConnectionElement
@synthesize connectionsOnlyCross = _connectionsOnlyCross;

#pragma mark Initialisation

- (instancetype)init{
    self = [super init];
    if (self) {
        _connections = 0;
        _connectionsOnlyCross = NO;
    }
    return self;
}

- (instancetype)initWithCoordinate: (CD2DCoordinate)c{
    self = [super initWithCoordinate: c];
    if (self) {
        _connections = 0;
        _connectionsOnlyCross = NO;
    }
    return self;
}

- (instancetype)initWithCoder: (NSCoder *)coder{
    self = [super initWithCoder: coder];
    if (self) {
        _connections = [coder decodeIntForKey: @"connections"];
        _connectionsOnlyCross = [coder decodeBoolForKey: @"connectionsOnlyCross"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder: aCoder];
    [aCoder encodeInt: _connections forKey: @"connections"];
    [aCoder encodeBool: _connectionsOnlyCross forKey: @"connectionsOnlyCross"];
}

- (id)copyWithZone:(NSZone *)zone{
    CDConnectionElement *copy = [super copyWithZone: zone];
    [copy connect: _connections];
    [copy setConnectionsOnlyCross: _connectionsOnlyCross];
    return copy;
}

#pragma mark Notifications

- (void)postConnectionsChangedNotificationWithOldConnections: (CD2DSides)oldConnections{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDConnectionElementConnectionsChangedNotification
                                                        object: self
                                                      userInfo: @{@"oldConnections" : @(oldConnections)}];
}

- (void)postConnectionsOnlyCrossChangedNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDConnectionElementConnectionsOnlyCrossChangedNotification
                                                        object:self];
}

#pragma mark Properties

- (BOOL)connectionsOnlyCross{
    return _connectionsOnlyCross;
}

- (void)setConnectionsOnlyCross:(BOOL)connectionsOnlyCross{
    if (connectionsOnlyCross == _connectionsOnlyCross) return;
    if (![self canConnectionsJustCross]) return;
    
    _connectionsOnlyCross = connectionsOnlyCross;
    
    [self postConnectionsOnlyCrossChangedNotification];
}

- (void)updateConnectionsOnlyCross{
    if (![self canConnectionsJustCross] && _connectionsOnlyCross) {
        _connectionsOnlyCross = NO;
        
        [self postConnectionsOnlyCrossChangedNotification];
    }
}

#pragma mark Public Methods

- (NSUInteger)numberOfConnections{
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < 8; i++) {
        if (_connections & (1 << i)) {
            count++;
        }
    }
    return count;
}

- (BOOL)canConnectionsJustCross{
    if (self.numberOfConnections != 4) {
        return NO;
    }
    for (NSUInteger i = 0; i < 8; i++) {
        if ([self isConnected: (1 << i)] &&
            ![self isConnected:1 << ((i + 4) % 8)]) {
            return NO;
        }
    }
    return YES;
}


- (BOOL)isConnected:(CD2DSides)sides{
    return (_connections & sides) == sides;
}

- (BOOL)hasConnectionToSide:(CD2DSides)side{
    return [self isConnected: side];
}

- (void)connect:(CD2DSides)sides{
    CD2DSides oldConnections = _connections;
    
    _connections = _connections | sides;
    
    [self postConnectionsChangedNotificationWithOldConnections: oldConnections];
    [self updateConnectionsOnlyCross];
}

- (void)disconnect:(CD2DSides)sides{
    CD2DSides oldConnections = _connections;
    
    _connections = _connections & ~sides;
    
    [self postConnectionsChangedNotificationWithOldConnections: oldConnections];
    [self updateConnectionsOnlyCross];
}

- (void)disconnectEverything{
    CD2DSides oldConnections = _connections;
    
    _connections = 0;
    
    [self postConnectionsChangedNotificationWithOldConnections: oldConnections];
    [self updateConnectionsOnlyCross];
}

@end
