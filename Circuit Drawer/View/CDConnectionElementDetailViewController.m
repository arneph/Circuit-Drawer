//
//  CDConnectionElementDetailViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 02.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDConnectionElementDetailViewController.h"

@interface CDConnectionElementConnectionsBox : NSView

@property CDCircuitPanel *circuitPanel;
@property NSArray *connectionElements;

@property NSUndoManager *undoManager;

@end

@interface CDConnectionElementDetailViewController ()

@property IBOutlet NSTextField *x1Label;
@property IBOutlet NSTextField *x2Label;

@property IBOutlet CDConnectionElementConnectionsBox *connectionsBox;

@property IBOutlet NSButton *connectionsOnlyCrossCheckBox;

- (IBAction)connectionsOnlyCrossCheckBoxChanged:(id)sender;

@end

@implementation CDConnectionElementDetailViewController
@synthesize circuitPanel = _circuitPanel;
@synthesize connectionElements = _connectionElements;
@synthesize undoManager = _undoManager;

#pragma mark Life cycle

+ (CDConnectionElementDetailViewController *)connectionElementDetailViewController{
    return [[CDConnectionElementDetailViewController alloc] initWithNibName: @"CDConnectionElementDetailView"
                                                                     bundle: [NSBundle mainBundle]];
}

- (void)awakeFromNib{
    _connectionsBox.circuitPanel = _circuitPanel;
    _connectionsBox.connectionElements = _connectionElements;
    
    _connectionsBox.undoManager = _undoManager;
    
    [self updateUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Updating

- (void)updateUI{
    if (_connectionElements.count == 1) {
        [_x1Label setStringValue: @(((CDConnectionElement *)_connectionElements[0]).coordinate.x1).stringValue];
        [_x2Label setStringValue: @(((CDConnectionElement *)_connectionElements[0]).coordinate.x2).stringValue];
        
        [_connectionsOnlyCrossCheckBox setState: ((CDConnectionElement *)_connectionElements[0]).connectionsOnlyCross];
        [_connectionsOnlyCrossCheckBox setEnabled: ((CDConnectionElement *)_connectionElements[0]).canConnectionsJustCross];
    }else{
        [_x1Label setStringValue: @"Multiple"];
        [_x2Label setStringValue: @"Multiple"];
        
        BOOL connectionsCanJustCrossAppears = NO;
        BOOL connectionsOnlyCrossAppears = NO;
        BOOL connectionsDontOnlyCrossAppears = NO;
        
        for (CDConnectionElement *e in _connectionElements) {
            if (e.canConnectionsJustCross) {
                connectionsCanJustCrossAppears = YES;
            }
            if (e.connectionsOnlyCross) {
                connectionsOnlyCrossAppears = YES;
            }else{
                connectionsDontOnlyCrossAppears = YES;
            }
        }
        
        if (connectionsOnlyCrossAppears && connectionsDontOnlyCrossAppears) {
            [_connectionsOnlyCrossCheckBox setState: NSMixedState];
            [_connectionsOnlyCrossCheckBox setEnabled: YES];
        }else if (connectionsOnlyCrossAppears) {
            [_connectionsOnlyCrossCheckBox setState: NSOnState];
            [_connectionsOnlyCrossCheckBox setEnabled: YES];
        }else{
            [_connectionsOnlyCrossCheckBox setState: NSOffState];
            [_connectionsOnlyCrossCheckBox setEnabled: connectionsCanJustCrossAppears];
        }
    }
}

#pragma mark Properties

- (CDCircuitPanel *)circuitPanel{
    return _circuitPanel;
}

- (void)setCircuitPanel:(CDCircuitPanel *)circuitPanel{
    _circuitPanel = circuitPanel;
    _connectionsBox.circuitPanel = _circuitPanel;
}

- (NSArray *)connectionElements{
    return _connectionElements;
}

- (void)setConnectionElements: (NSArray *)connectionElements{
    _connectionElements = connectionElements;
    
    [self updateUI];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    for (CDConnectionElement *e in _connectionElements) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(connectionElementChanged:)
                                                     name: CDConnectionElementConnectionsChangedNotification
                                                   object: e];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(connectionElementChanged:)
                                                     name: CDConnectionElementConnectionsOnlyCrossChangedNotification
                                                   object: e];
    }
    
    _connectionsBox.connectionElements = _connectionElements;
}

- (NSUndoManager *)undoManager{
    return _undoManager;
}

- (void)setUndoManager:(NSUndoManager *)undoManager{
    if (undoManager == _undoManager) return;
    
    _undoManager = undoManager;
    _connectionsBox.undoManager = _undoManager;
}

#pragma mark Notifications

- (void)connectionElementChanged: (NSNotification*)notification{
    [self updateUI];
}

#pragma mark Actions

- (void)connectionsOnlyCrossCheckBoxChanged: (id)sender{
    BOOL connectionsCanAllJustCross = YES;
    BOOL connectionsOnlyCrossAppears = NO;
    BOOL connectionsDontOnlyCrossAppears = NO;
    for (CDConnectionElement *e in _connectionElements) {
        if (!e.canConnectionsJustCross) {
            connectionsCanAllJustCross = NO;
        }
        if (e.connectionsOnlyCross) {
            connectionsOnlyCrossAppears = YES;
        }else{
            connectionsDontOnlyCrossAppears = YES;
        }
    }
    
    BOOL shouldOnlyCross;
    if (connectionsCanAllJustCross) {
        if (!connectionsOnlyCrossAppears) {
            shouldOnlyCross = YES;
        }else{
            shouldOnlyCross = NO;
        }
    }else{
        if (connectionsOnlyCrossAppears) {
            shouldOnlyCross = NO;
        }else{
            shouldOnlyCross = YES;
        }
    }
    
    [_undoManager beginUndoGrouping];
    for (CDConnectionElement *e in _connectionElements) {
        [self undoableSetConnectionsOnlyCross: @{@"coordinate" : dictionaryStoringCoordinate(e.coordinate),
                                                 @"connectionsOnlyCross" : @(shouldOnlyCross)}];
    }
    [_undoManager endUndoGrouping];
    [_undoManager setActionName: @"Changing Connection"];
}

- (void)undoableSetConnectionsOnlyCross: (NSDictionary *)info{
    NSDictionary *coordinateDict = info[@"coordinate"];
    BOOL connectionsOnlyCross = ((NSNumber *)info[@"connectionsOnlyCross"]).boolValue;
    CDCircuitObject *object = (CDCircuitObject *)[_circuitPanel.array objectAtCoordinate: coordinateFromDictionary(coordinateDict)];
    
    if (![object isKindOfClass: [CDConnectionElement class]]) return;
    
    CDConnectionElement *connectionElement = (CDConnectionElement *)object;
    
    if (!connectionElement) return;
    
    BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
    
    connectionElement.connectionsOnlyCross = connectionsOnlyCross;
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetConnectionsOnlyCross:)
                                  object: @{@"coordinate" : coordinateDict,
                                            @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
}

@end

@implementation CDConnectionElementConnectionsBox
@synthesize connectionElements = _connectionElements;

#pragma mark Deallocation

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Undo / Redo

- (void)undoableConnect: (NSDictionary *)info{
    NSDictionary *coordinateDict = info[@"coordinate"];
    CD2DSides sidesToConnect = ((NSNumber *)info[@"sidesToConnect"]).intValue;
    BOOL connectionsOnlyCross = ((NSNumber *)info[@"connectionsOnlyCross"]).boolValue;
    CDCircuitObject *object = (CDCircuitObject *)[_circuitPanel.array objectAtCoordinate: coordinateFromDictionary(coordinateDict)];
    
    if (![object isKindOfClass: [CDConnectionElement class]]) return;
    
    CDConnectionElement *connectionElement = (CDConnectionElement *)object;
    
    if (!connectionElement) return;
    
    CD2DSides alreadyConnectedSides = connectionElement.connections;
    BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
    
    [connectionElement connect: sidesToConnect];
    [connectionElement setConnectionsOnlyCross: connectionsOnlyCross];
    
    CD2DSides sidesToDisconnect = connectionElement.connections & ~alreadyConnectedSides;
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableDisconnect:)
                                  object: @{@"coordinate" : coordinateDict,
                                            @"sidesToDisconnect" : @(sidesToDisconnect),
                                            @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
}

- (void)undoableDisconnect: (NSDictionary *)info{
    NSDictionary *coordinateDict = info[@"coordinate"];
    CD2DSides sidesToDisconnect = ((NSNumber *)info[@"sidesToDisconnect"]).intValue;
    BOOL connectionsOnlyCross = ((NSNumber *)info[@"connectionsOnlyCross"]).boolValue;
    CDCircuitObject *object = (CDCircuitObject *)[_circuitPanel.array objectAtCoordinate: coordinateFromDictionary(coordinateDict)];
    
    if (![object isKindOfClass: [CDConnectionElement class]]) return;
    
    CDConnectionElement *connectionElement = (CDConnectionElement *)object;
    
    if (!connectionElement) return;
    
    CD2DSides alreadyConnectedSides = connectionElement.connections;
    BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
    
    [connectionElement disconnect: sidesToDisconnect];
    [connectionElement setConnectionsOnlyCross: connectionsOnlyCross];
    
    CD2DSides sidesToConnect = ~connectionElement.connections & alreadyConnectedSides;
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableConnect:)
                                  object: @{@"coordinate" : coordinateDict,
                                            @"sidesToConnect" : @(sidesToConnect),
                                            @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
}


#pragma mark Properties

- (NSArray *)connectionElements{
    return _connectionElements;
}

- (void)setConnectionElements: (NSArray *)connectionElements{
    if (connectionElements == _connectionElements) return;
    
    _connectionElements = connectionElements;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    for (CDConnectionElement *e in _connectionElements) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(connectionElementChanged:)
                                                     name: CDConnectionElementConnectionsChangedNotification
                                                   object: e];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(connectionElementChanged:)
                                                     name: CDConnectionElementConnectionsOnlyCrossChangedNotification
                                                   object: e];
    }
}

#pragma mark Notifications

- (void)connectionElementChanged: (NSNotification *)notification{
    [self setNeedsDisplay: YES];
}

#pragma mark Event Handling

- (BOOL)acceptsFirstResponder{
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint: theEvent.locationInWindow
                               fromView: nil];
    if (!NSPointInRect(point, self.bounds)) return;
    
    CGFloat dX = point.x - 48;
    CGFloat dY = point.y - 48;
    CGFloat d = sqrt((dX * dX) + (dY * dY));
    
    if (d <= 6.0) {
        BOOL everythingPossibleIsConnected = YES;
        for (CDConnectionElement *e in _connectionElements) {
            if (e.numberOfConnections == e.numberOfConnectableSides) {
                continue;
            }
            
            for (NSUInteger i = 0; i < 8; i++) {
                CD2DSides side = (1 << i);
                CD2DSides oppositeSide = (1 << ((i + 4) % 8));
                NSInteger oX1 = 0;
                NSInteger oX2 = 0;
                if (i == 0 || i == 1 || i == 7) {
                    oX1 = 1;
                }else if (i >= 3 && i <= 5) {
                    oX1 = -1;
                }
                if (i >= 1 && i <= 3) {
                    oX2 = 1;
                }else if (i >= 5 && i <= 7) {
                    oX2 = -1;
                }
                
                if (![e canConnectToSide: side]) {
                    continue;
                }
                
                CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: e.coordinate.x1 + oX1
                                                                                                   x2: e.coordinate.x2 + oX2];
                if (![oppositeObject canConnectToSide: oppositeSide]) {
                    continue;
                }
                
                everythingPossibleIsConnected = NO;
            }
        }
        
        [_undoManager beginUndoGrouping];
        for (CDConnectionElement *e in _connectionElements) {
            for (NSUInteger i = 0; i < 8; i++) {
                CD2DSides side = (1 << i);
                CD2DSides oppositeSide = (1 << ((i + 4) % 8));
                
                if (![e canConnectToSide: side]) {
                    continue;
                }
                
                NSInteger oX1 = 0;
                NSInteger oX2 = 0;
                if (i == 0 || i == 1 || i == 7) {
                    oX1 = 1;
                }else if (i >= 3 && i <= 5) {
                    oX1 = -1;
                }
                if (i >= 1 && i <= 3) {
                    oX2 = 1;
                }else if (i >= 5 && i <= 7) {
                    oX2 = -1;
                }
                CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: e.coordinate.x1 + oX1
                                                                                                   x2: e.coordinate.x2 + oX2];
                if (![oppositeObject canConnectToSide: oppositeSide]) {
                    continue;
                }
                
                CDConnectionElement *oppositeConnectionElement = nil;
                if ([oppositeObject isKindOfClass: [CDConnectionElement class]]) {
                    oppositeConnectionElement = (CDConnectionElement *)oppositeObject;
                }
                
                if (!everythingPossibleIsConnected) {
                    [self undoableConnect: @{@"coordinate" : dictionaryStoringCoordinate(e.coordinate),
                                             @"sidesToConnect" : @(side),
                                             @"connectionsOnlyCross" : @NO}];
                    [self undoableConnect: @{@"coordinate" : dictionaryStoringCoordinate(oppositeConnectionElement.coordinate),
                                             @"sidesToConnect" : @(oppositeSide),
                                             @"connectionsOnlyCross" : @NO}];
                }else{
                    [self undoableDisconnect: @{@"coordinate" : dictionaryStoringCoordinate(e.coordinate),
                                                @"sidesToDisconnect" : @(side),
                                                @"connectionsOnlyCross" : @NO}];
                    [self undoableDisconnect: @{@"coordinate" : dictionaryStoringCoordinate(oppositeConnectionElement.coordinate),
                                                @"sidesToDisconnect" : @(oppositeSide),
                                                @"connectionsOnlyCross" : @NO}];
                }
            }
        }
        [_undoManager endUndoGrouping];
        
    }else{
        CGFloat angle = -(atan2(dX, dY) * 180.0 / M_PI) + 90.0;
        NSUInteger i = ((int)(angle + 382.5) % 360) / 45.0;
        CD2DSides side = (1 << i);
        CD2DSides oppositeSide = (1 << ((i + 4) % 8));
        
        BOOL everythingPossibleIsConnected = YES;
        for (CDConnectionElement *e in _connectionElements) {
            if (![e canConnectToSide: side] || [e isConnected: side]) {
                continue;
            }
            
            NSInteger oX1 = 0;
            NSInteger oX2 = 0;
            if (i == 0 || i == 1 || i == 7) {
                oX1 = 1;
            }else if (i >= 3 && i <= 5) {
                oX1 = -1;
            }
            if (i >= 1 && i <= 3) {
                oX2 = 1;
            }else if (i >= 5 && i <= 7) {
                oX2 = -1;
            }
            CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: e.coordinate.x1 + oX1
                                                                                               x2: e.coordinate.x2 + oX2];
            if (![oppositeObject canConnectToSide: oppositeSide]) {
                continue;
            }
            everythingPossibleIsConnected = NO;
        }
        
        [_undoManager beginUndoGrouping];
        for (CDConnectionElement *e in _connectionElements) {
            if (![e canConnectToSide: side]) {
                continue;
            }
            
            NSInteger oX1 = 0;
            NSInteger oX2 = 0;
            if (i == 0 || i == 1 || i == 7) {
                oX1 = 1;
            }else if (i >= 3 && i <= 5) {
                oX1 = -1;
            }
            if (i >= 1 && i <= 3) {
                oX2 = 1;
            }else if (i >= 5 && i <= 7) {
                oX2 = -1;
            }
            CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: e.coordinate.x1 + oX1
                                                                                               x2: e.coordinate.x2 + oX2];
            if (![oppositeObject canConnectToSide: oppositeSide]) {
                continue;
            }
            
            CDConnectionElement *oppositeConnectionElement = nil;
            if ([oppositeObject isKindOfClass: [CDConnectionElement class]]) {
                oppositeConnectionElement = (CDConnectionElement *)oppositeObject;
            }else{
                continue;
            }
            
            if (!everythingPossibleIsConnected) {
                [self undoableConnect: @{@"coordinate" : dictionaryStoringCoordinate(e.coordinate),
                                         @"sidesToConnect" : @(side),
                                         @"connectionsOnlyCross" : @NO}];
                [self undoableConnect: @{@"coordinate" : dictionaryStoringCoordinate(oppositeConnectionElement.coordinate),
                                         @"sidesToConnect" : @(oppositeSide),
                                         @"connectionsOnlyCross" : @NO}];
            }else{
                [self undoableDisconnect: @{@"coordinate" : dictionaryStoringCoordinate(e.coordinate),
                                            @"sidesToDisconnect" : @(side),
                                            @"connectionsOnlyCross" : @NO}];
                [self undoableDisconnect: @{@"coordinate" : dictionaryStoringCoordinate(oppositeConnectionElement.coordinate),
                                            @"sidesToDisconnect" : @(oppositeSide),
                                            @"connectionsOnlyCross" : @NO}];
            }
        }
        [_undoManager endUndoGrouping];
    }
    
    [_undoManager setActionName: @"Changing Connection"];
}

#pragma mark Drawing

- (BOOL)isOpaque{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect: dirtyRect];
    
    CGFloat squareWidth = 96;
    
    //Draw the Base Grid:
    [self drawBaseGrid];
    
    BOOL connectionsWhichOnlyCrossAppear = NO;
    BOOL connectionsWhichNotOnlyCrossAppear = NO;
    BOOL connectionsWithMoreThanTwoConnectionsWhichNotOnlyCrossAppear = NO;
    BOOL connectionsWithMoreThanTwoConnectionsAppear = NO;
    
    CD2DSides sidesToWhichConnectionElementsConnect = 0;
    CD2DSides sidesToWhichAllConnectionElementsConnect = ((CDConnectionElement *)_connectionElements[0]).connections;
    CD2DSides sidesFromWhichOnlyCrossingConnectionsCome = 0;
    
    for (CDConnectionElement *e in _connectionElements) {
        if (e.connectionsOnlyCross) {
            connectionsWhichOnlyCrossAppear = YES;
            
            sidesFromWhichOnlyCrossingConnectionsCome = sidesFromWhichOnlyCrossingConnectionsCome | e.connections;
        }else{
            connectionsWhichNotOnlyCrossAppear = YES;
        }
        if (e.numberOfConnections > 2) {
            connectionsWithMoreThanTwoConnectionsAppear = YES;
        }
        if (e.numberOfConnections > 2 && !e.connectionsOnlyCross) {
            connectionsWithMoreThanTwoConnectionsWhichNotOnlyCrossAppear = YES;
        }
        
        sidesToWhichConnectionElementsConnect = sidesToWhichConnectionElementsConnect | e.connections;
        sidesToWhichAllConnectionElementsConnect = sidesToWhichAllConnectionElementsConnect & e.connections;
    }
    
    if (connectionsWhichNotOnlyCrossAppear) {
        NSBezierPath *circle = [[NSBezierPath alloc] init];
        [circle appendBezierPathWithOvalInRect: NSMakeRect(0.5 * squareWidth - (squareWidth / 16),
                                                           0.5 * squareWidth - (squareWidth / 16),
                                                           squareWidth / 8, squareWidth / 8)];
        
        if (connectionsWithMoreThanTwoConnectionsWhichNotOnlyCrossAppear) {
            [[NSColor blackColor] set];
        }else{
            [[NSColor lightGrayColor] set];
        }
        [circle fill];
    }
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    
    if (sidesToWhichConnectionElementsConnect & CD2DSideRight) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideRight) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(squareWidth,
                                       0.5 * squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideTopRight) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideTopRight) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(squareWidth,
                                       squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideTop) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideTop) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0.5 * squareWidth,
                                       squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideTopLeft) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideTopLeft) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0,
                                       squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideLeft) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideLeft) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0,
                                       0.5 * squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideBottomLeft) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideBottomLeft) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0,
                                       0)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideBottom) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideBottom) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0.5 * squareWidth,
                                       0)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (sidesToWhichConnectionElementsConnect & CD2DSideBottomRight) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (~sidesToWhichAllConnectionElementsConnect & CD2DSideBottomRight) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(squareWidth,
                                       0)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    
    if (sidesFromWhichOnlyCrossingConnectionsCome == 0) {
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth: 3];
        [NSBezierPath strokeRect: self.bounds];
        
        return;
    }
    
    NSUInteger numberOfSidesFromWhichOnlyCrossingConnectionsCome = 0;
    for (NSUInteger i = 0; i < 4; i++) {
        CD2DSides side = (1 << i);
        if (sidesFromWhichOnlyCrossingConnectionsCome & side) {
            numberOfSidesFromWhichOnlyCrossingConnectionsCome++;
        }
    }
    
    if (numberOfSidesFromWhichOnlyCrossingConnectionsCome == 2) {
        if (sidesFromWhichOnlyCrossingConnectionsCome & CD2DSideRight) {
            [[NSColor colorWithWhite:1 alpha:0.75] set];
            [NSBezierPath setDefaultLineWidth: 8];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.3 * squareWidth,
                                                           0.5 * squareWidth)
                                      toPoint: NSMakePoint(0.7 * squareWidth,
                                                           0.5 * squareWidth)];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth: 1.5];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.3 * squareWidth,
                                                           0.5 * squareWidth)
                                      toPoint: NSMakePoint(0.7 * squareWidth,
                                                           0.5 * squareWidth)];
        }else if (sidesFromWhichOnlyCrossingConnectionsCome & CD2DSideTopRight) {
            [[NSColor colorWithWhite:1 alpha:0.75] set];
            [NSBezierPath setDefaultLineWidth: 8];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.3 * squareWidth,
                                                           0.3 * squareWidth)
                                      toPoint: NSMakePoint(0.7 * squareWidth,
                                                           0.7 * squareWidth)];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth: 1.5];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.3 * squareWidth,
                                                           0.3 * squareWidth)
                                      toPoint: NSMakePoint(0.7 * squareWidth,
                                                           0.7 * squareWidth)];
        }else if (sidesFromWhichOnlyCrossingConnectionsCome & CD2DSideTop) {
            [[NSColor colorWithWhite:1 alpha:0.75] set];
            [NSBezierPath setDefaultLineWidth: 8];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.5 * squareWidth,
                                                           0.3 * squareWidth)
                                      toPoint: NSMakePoint(0.5 * squareWidth,
                                                           0.7 * squareWidth)];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth: 1.5];
            [NSBezierPath strokeLineFromPoint: NSMakePoint(0.5 * squareWidth,
                                                           0.3 * squareWidth)
                                      toPoint: NSMakePoint(0.5 * squareWidth,
                                                           0.7 * squareWidth)];
        }
    }else{
        [[NSColor whiteColor] set];
        NSBezierPath *circle = [[NSBezierPath alloc] init];
        [circle appendBezierPathWithOvalInRect: NSMakeRect(0.5 * squareWidth - (squareWidth / 20),
                                                           0.5 * squareWidth - (squareWidth / 20),
                                                           squareWidth / 10, squareWidth / 10)];
        [circle fill];
        
        [[NSColor blackColor] set];
        circle = [[NSBezierPath alloc] init];
        [circle appendBezierPathWithOvalInRect: NSMakeRect(0.5 * squareWidth - (squareWidth / 40),
                                                           0.5 * squareWidth - (squareWidth / 40),
                                                           squareWidth / 20, squareWidth / 20)];
        [circle fill];
    }
        
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 3];
    [NSBezierPath strokeRect: self.bounds];
}

- (void)drawBaseGrid{
    CGFloat squareWidth = 96;
    
    BOOL leftMostConnectionElementAppears = NO;
    BOOL notLeftMostConnectionElementAppears = NO;
    BOOL rightMostConnectionElementAppears = NO;
    BOOL notRightMostConnectionElementAppears = NO;
    BOOL bottomMostConnectionElementAppears = NO;
    BOOL notBottomMostConnectionElementAppears = NO;
    BOOL topMostConnectionElementAppears = NO;
    BOOL notTopMostConnectionElementAppears = NO;
    
    for (CDConnectionElement *e in _connectionElements) {
        if (e.isLeftMost) {
            leftMostConnectionElementAppears = YES;
        }else{
            notLeftMostConnectionElementAppears = YES;
        }
        if (e.isRightMost) {
            rightMostConnectionElementAppears = YES;
        }else{
            notRightMostConnectionElementAppears = YES;
        }
        if (e.isBottomMost) {
            bottomMostConnectionElementAppears = YES;
        }else{
            notBottomMostConnectionElementAppears = YES;
        }
        if (e.isTopMost) {
            topMostConnectionElementAppears = YES;
        }else{
            notTopMostConnectionElementAppears = YES;
        }
    }
    
    [[NSColor lightGrayColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    [NSBezierPath setDefaultLineCapStyle: NSButtLineCapStyle];
    
    if (notRightMostConnectionElementAppears == YES) {
        NSBezierPath *defaultPath = [[NSBezierPath alloc] init];
        if (rightMostConnectionElementAppears == YES) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [defaultPath setLineDash: array count: 2 phase: 0.0];
        }
        NSBezierPath *path = defaultPath.copy;
        [path moveToPoint: NSMakePoint(squareWidth,
                                       0.5 * squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
        
        if (notTopMostConnectionElementAppears == YES) {
            path = defaultPath.copy;
            if (topMostConnectionElementAppears == YES) {
                CGFloat array[2];
                array[0] = 5.0;
                array[1] = 5.0;
                [path setLineDash: array count: 2 phase: 0.0];
            }
            
            [path moveToPoint: NSMakePoint(squareWidth,
                                           squareWidth)];
            [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                           0.5 * squareWidth)];
            [path stroke];
        }
        if (notBottomMostConnectionElementAppears == YES) {
            path = defaultPath.copy;
            if (bottomMostConnectionElementAppears) {
                CGFloat array[2];
                array[0] = 5.0;
                array[1] = 5.0;
                [path setLineDash: array count: 2 phase: 0.0];
            }
            
            [path moveToPoint: NSMakePoint(squareWidth,
                                           0)];
            [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                           0.5 * squareWidth)];
            [path stroke];
        }
    }
    if (notTopMostConnectionElementAppears == YES) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (topMostConnectionElementAppears == YES) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        
        [path moveToPoint: NSMakePoint(0.5 * squareWidth,
                                       squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
    if (notLeftMostConnectionElementAppears == YES) {
        NSBezierPath *defaultPath = [[NSBezierPath alloc] init];
        if (leftMostConnectionElementAppears == YES) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [defaultPath setLineDash: array count: 2 phase: 0.0];
        }
        NSBezierPath *path = defaultPath.copy;
        [path moveToPoint: NSMakePoint(0,
                                       0.5 * squareWidth)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
        
        if (notTopMostConnectionElementAppears == YES) {
            path = defaultPath.copy;
            if (topMostConnectionElementAppears == YES) {
                CGFloat array[2];
                array[0] = 5.0;
                array[1] = 5.0;
                [path setLineDash: array count: 2 phase: 0.0];
            }
            [path moveToPoint: NSMakePoint(0,
                                           squareWidth)];
            [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                           0.5 * squareWidth)];
            [path stroke];
        }
        if (notBottomMostConnectionElementAppears == YES) {
            path = defaultPath.copy;
            if (bottomMostConnectionElementAppears == YES) {
                CGFloat array[2];
                array[0] = 5.0;
                array[1] = 5.0;
                [path setLineDash: array count: 2 phase: 0.0];
            }
            [path moveToPoint: NSMakePoint(0,
                                           0)];
            [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                           0.5 * squareWidth)];
            [path stroke];
        }
    }
    if (notBottomMostConnectionElementAppears == YES) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (bottomMostConnectionElementAppears == YES) {
            CGFloat array[2];
            array[0] = 5.0;
            array[1] = 5.0;
            [path setLineDash: array count: 2 phase: 0.0];
        }
        [path moveToPoint: NSMakePoint(0.5 * squareWidth,
                                       0)];
        [path lineToPoint: NSMakePoint(0.5 * squareWidth,
                                       0.5 * squareWidth)];
        [path stroke];
    }
}

@end
