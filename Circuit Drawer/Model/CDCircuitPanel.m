//
//  CDCircuitPanel.m
//  Circuit Drawer
//
//  Created by Programmieren on 28.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDCircuitPanel.h"

@implementation CDCircuitPanel

#pragma  mark Initialisation

- (instancetype)init{
    self = [super init];
    if (self) {
        _array = [[CDMutable2DArray alloc] init2DArrayWithX1Count: 24
                                                          x2Count: 16
                                                           object: [[CDConnectionElement alloc] init]];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(arrayChanged:)
                                                     name: CDMutable2DArrayChangedNotification
                                                   object: _array];
        [self updateCircuitObjects];
    }
    return self;
}

- (instancetype)initWithCircuitPanel: (CDCircuitPanel *)cp{
    self = [super init];
    if (self) {
        _array = [[CDMutable2DArray alloc] init2DArrayWithDeepCopied2DArray: cp.array];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(arrayChanged:)
                                                     name: CDMutable2DArrayChangedNotification
                                                   object: _array];
        [self updateCircuitObjects];
    }
    return self;
}

#pragma mark Coding

- (instancetype)initWithCoder: (NSCoder *)coder{
    self = [super init];
    if (self) {
        _array = [coder decodeObjectForKey: @"array"];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(arrayChanged:)
                                                     name: CDMutable2DArrayChangedNotification
                                                   object: _array];
        [self updateCircuitObjects];
    }
    return self;
}

- (void)encodeWithCoder: (NSCoder *)aCoder{
    [aCoder encodeObject: _array forKey: @"array"];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone{
    return [[[self class] alloc] initWithCircuitPanel: self];
}

#pragma mark Deallocation

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Notifications

- (void)arrayChanged: (NSNotification *)notification{
    [self updateCircuitObjects];
    [self postArrayChangedNotification];
}

- (void)circuitObjectChanged: (NSNotification *)notification{
    [self postCircuitObjectChangedNotificationWithCircuitObject: notification.object];
}

- (void)postArrayChangedNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDCircuitPanelArrayChangedNotification
                                                        object: self];
}

- (void)postCircuitObjectChangedNotificationWithCircuitObject: (CDCircuitObject *)object{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDCircuitPanelCircuitObjectChangedNotification
                                                        object: self
                                                      userInfo: @{@"circuitObject" : object,
                                                                  @"coordinate" : dictionaryStoringCoordinate(object.coordinate)}];
}

- (void)updateCircuitObjects{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: CDConnectionElementConnectionsChangedNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: CDConnectionElementConnectionsOnlyCrossChangedNotification
                                                  object: nil];
    
    [_array enumerateObjectsUsingBlock: ^(NSObject <NSCoding, NSCopying>*obj, CD2DCoordinate coord, BOOL *stop) {
        CDCircuitObject *circuitObject = (CDCircuitObject *)obj;
        circuitObject.coordinate = coord;
        circuitObject.isLeftMost = (coord.x1 == 0);
        circuitObject.isRightMost = (coord.x1 == _array.x1Count - 1);
        circuitObject.isBottomMost = (coord.x2 == 0);
        circuitObject.isTopMost = (coord.x2 == _array.x2Count - 1);
        
        if ([circuitObject isKindOfClass: [CDConnectionElement class]]) {
            CDConnectionElement *connectionElement = (CDConnectionElement *)circuitObject;
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(circuitObjectChanged:)
                                                         name: CDConnectionElementConnectionsChangedNotification
                                                       object: connectionElement];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(circuitObjectChanged:)
                                                         name: CDConnectionElementConnectionsOnlyCrossChangedNotification
                                                       object: connectionElement];
        }else if ([circuitObject isKindOfClass: [CDDiode class]]) {
            CDDiode *diode = (CDDiode *)circuitObject;
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(circuitObjectChanged:)
                                                         name: CDDiodeAnodeAndCathodeChangedNotification
                                                       object: diode];
        }
    }];
}

@end
