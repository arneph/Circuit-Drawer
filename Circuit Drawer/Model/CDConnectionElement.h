//
//  CDConnectionElement.h
//  Circuit Drawer
//
//  Created by Programmieren on 31.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDCircuitObject.h"

#define CDConnectionElementConnectionsChangedNotification @"CDConnectionElementConnectionsChangedNotification"
#define CDConnectionElementConnectionsOnlyCrossChangedNotification @"CDConnectionElementConnectionsOnlyCrossChangedNotification"

@interface CDConnectionElement : CDCircuitObject <NSCoding, NSCopying>

@property (readonly) CD2DSides connections;
@property BOOL connectionsOnlyCross;

- (NSUInteger) numberOfConnections;
- (BOOL)canConnectionsJustCross;

- (BOOL)isConnected: (CD2DSides)sides;

- (void)connect: (CD2DSides)sides;
- (void)disconnect: (CD2DSides)sides;
- (void)disconnectEverything;

@end
