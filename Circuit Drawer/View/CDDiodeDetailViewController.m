//
//  CDDiodeDetailViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 25.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDDiodeDetailViewController.h"

@interface CDDiodesView : NSView

@property NSArray * diodes;

@end

@interface CDDiodeDetailViewController ()

@property IBOutlet NSTextField *x1Label;
@property IBOutlet NSTextField *x2Label;

@property IBOutlet CDDiodesView *diodesView;

- (IBAction)pushedRotateLeft: (id)sender;
- (IBAction)pushedRotateRight: (id)sender;
- (IBAction)pushedMirror: (id)sender;

@end

@implementation CDDiodeDetailViewController
@synthesize diodes = _diodes;

#pragma mark Life cycle

+ (CDDiodeDetailViewController *)diodeDetailViewController{
    return [[CDDiodeDetailViewController alloc] initWithNibName: @"CDDiodeDetailView"
                                                         bundle: [NSBundle mainBundle]];
}

- (void)awakeFromNib{
    _diodesView.diodes = _diodes;
    
    [self updateUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Notifications
//
//- (void)updateNotifications{
//    [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                    name: CDDiodeAnodeAndCathodeChangedNotification
//                                                  object: nil];
//    if (!_diodes || _diodes.count == 0) {
//        return;
//    }
//    
//    for (CDDiode *diode in _diodes) {
//        [[NSNotificationCenter defaultCenter] addObserver: self
//                                                 selector: @selector(diodeChanged:)
//                                                     name: CDDiodeAnodeAndCathodeChangedNotification
//                                                   object: diode];
//    }
//}
//
//- (void)diodeChanged: (NSNotification *)notification{
//    
//}

#pragma mark Undo / Redo

- (void)undoableSetAnode: (NSDictionary *)info{
    NSDictionary *coordinateDict = info[@"coordinate"];
    CD2DSides anode = (CD2DSides)((NSNumber *)info[@"anode"]).integerValue;
    CDCircuitObject *object = (CDCircuitObject *)[_circuitPanel.array objectAtCoordinate: coordinateFromDictionary(coordinateDict)];
    
    if (!object || ![object isKindOfClass: [CDDiode class]]) return;
    
    CDDiode *diode = (CDDiode *)object;
    CD2DSides oldAnode = diode.anode;
    
    [diode setAnode: anode];
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetAnode:)
                                  object: @{@"coordinate" : coordinateDict,
                                            @"anode" : @(oldAnode)}];
}

#pragma mark Properties

- (NSArray *)diodes{
    return _diodes;
}

- (void)setDiodes: (NSArray *)diodes{
    _diodes = diodes;
    
    [self updateUI];
    
    _diodesView.diodes = _diodes;
}

#pragma mark Updating

- (void)updateUI{
    if (_diodes.count == 1) {
        [_x1Label setStringValue: @(((CDDiode *)_diodes[0]).coordinate.x1).stringValue];
        [_x2Label setStringValue: @(((CDDiode *)_diodes[0]).coordinate.x2).stringValue];
        
    }else{
        [_x1Label setStringValue: @"Multiple"];
        [_x2Label setStringValue: @"Multiple"];
    }
    
    _diodesView.diodes = _diodes;
}

#pragma mark Actions

- (void)pushedRotateLeft: (id)sender{
    if (!_diodes || _diodes.count == 0) {
        return;
    }
    
    [_undoManager beginUndoGrouping];
    for (CDDiode *diode in _diodes) {
        CD2DSides anode = diode.anode;
        CD2DSides newAnode = 0;
        
        for (NSUInteger i = 0; i < 8; i++) {
            CD2DSides s = (1 << i);
            if (s == anode) {
                newAnode = (1 << ((i + 1) % 8));
            }
        }
        
        [self undoableSetAnode: @{@"coordinate" : dictionaryStoringCoordinate(diode.coordinate),
                                  @"anode" : @(newAnode)}];
    }
    [_undoManager endUndoGrouping];
    [_undoManager setActionName: @"Rotate Left"];
}

- (void)pushedRotateRight: (id)sender{
    if (!_diodes || _diodes.count == 0) {
        return;
    }
    
    [_undoManager beginUndoGrouping];
    for (CDDiode *diode in _diodes) {
        CD2DSides anode = diode.anode;
        CD2DSides newAnode = 0;
        
        for (NSUInteger i = 0; i < 8; i++) {
            CD2DSides s = (1 << i);
            if (s == anode) {
                newAnode = (1 << ((i + 7) % 8));
            }
        }
        
        [self undoableSetAnode: @{@"coordinate" : dictionaryStoringCoordinate(diode.coordinate),
                                  @"anode" : @(newAnode)}];
    }
    [_undoManager endUndoGrouping];
    [_undoManager setActionName: @"Rotate Right"];
}

- (void)pushedMirror: (id)sender{
    if (!_diodes || _diodes.count == 0) {
        return;
    }
    
    [_undoManager beginUndoGrouping];
    for (CDDiode *diode in _diodes) {
        CD2DSides anode = diode.anode;
        CD2DSides newAnode = 0;
        
        for (NSUInteger i = 0; i < 8; i++) {
            CD2DSides s = (1 << i);
            if (s == anode) {
                newAnode = (1 << ((i + 4) % 8));
            }
        }
        
        [self undoableSetAnode: @{@"coordinate" : dictionaryStoringCoordinate(diode.coordinate),
                                  @"anode" : @(newAnode)}];
    }
    [_undoManager endUndoGrouping];
    [_undoManager setActionName: @"Mirror"];
}

@end

@implementation CDDiodesView
@synthesize diodes = _diodes;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Notifications

- (void)updateNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: CDDiodeAnodeAndCathodeChangedNotification
                                                  object: nil];
    if (!_diodes || _diodes.count == 0) {
        return;
    }
    
    for (CDDiode *diode in _diodes) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(diodeChanged:)
                                                     name: CDDiodeAnodeAndCathodeChangedNotification
                                                   object: diode];
    }
}

- (void)diodeChanged: (NSNotification *)notification{
    [self setNeedsDisplay: YES];
}

#pragma mark Properties

- (NSArray *)diodes{
    return _diodes;
}

- (void)setDiodes:(NSArray *)diodes{
    _diodes = diodes;
    [self updateNotifications];
    [self setNeedsDisplay: YES];
}

#pragma mark Drawing

- (BOOL)isOpaque{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect: dirtyRect];
    
    if (!_diodes || _diodes.count == 0) {
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth: 3];
        [NSBezierPath strokeRect: self.bounds];
        
        return;
    }
    
    CGFloat squareWidth = 96;
    
    if (_diodes.count == 1) {
        [[NSColor blackColor] set];
    }else{
        [[NSColor colorWithCalibratedWhite: 0.5
                                     alpha: 0.5] set];
    }    
    [NSBezierPath setDefaultLineWidth: 1.5];
    
    for (CDDiode *diode in _diodes) {
        
        NSBezierPath *baseLine = [[NSBezierPath alloc] init];
        NSBezierPath *triangle = [[NSBezierPath alloc] init];
        NSBezierPath *limitLine = [[NSBezierPath alloc] init];
        
        if ([diode hasConnectionToSide: CD2DSideRight]) {
            [baseLine moveToPoint: NSMakePoint(0,
                                               0.5 * squareWidth)];
            [baseLine lineToPoint: NSMakePoint(squareWidth,
                                               0.5 * squareWidth)];
            
            if (diode.anode == CD2DSideLeft) {
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(0.0 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(0.0 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(-0.25 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(-0.25 * M_PI)))];
            }else{
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(-0.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(-0.25 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(1 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(1 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
            }
        }else if ([diode hasConnectionToSide: CD2DSideTopRight]) {
            [baseLine moveToPoint: NSMakePoint(0,
                                               0)];
            [baseLine lineToPoint: NSMakePoint(squareWidth,
                                               squareWidth)];
            
            if (diode.anode == CD2DSideBottomLeft) {
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(0.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(0.25 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
            }else{
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(1.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(1.25 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
            }
        }else if ([diode hasConnectionToSide: CD2DSideTop]) {
            [baseLine moveToPoint: NSMakePoint(0.5 * squareWidth,
                                               0)];
            [baseLine lineToPoint: NSMakePoint(0.5 * squareWidth,
                                               squareWidth)];
            
            if (diode.anode == CD2DSideBottom) {
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.75 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.75 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(0.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(0.5 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
            }else{
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(-0.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(-0.5 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.75 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.75 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
            }
        }else if ([diode hasConnectionToSide: CD2DSideTopLeft]) {
            [baseLine moveToPoint: NSMakePoint(0,
                                               squareWidth)];
            [baseLine lineToPoint: NSMakePoint(squareWidth,
                                               0)];
            
            if (diode.anode == CD2DSideBottomRight) {
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(0.75 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(0.75 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
            }else{
                [triangle moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(1 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.3 * sin(1 * M_PI)))];
                [triangle lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.212 * cos(-0.25 * M_PI)),
                                                   (0.5 * squareWidth) + (squareWidth* 0.212 * sin(-0.25 * M_PI)))];
                
                [limitLine moveToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
                [limitLine lineToPoint: NSMakePoint((0.5 * squareWidth) + (squareWidth * 0.3 * cos(-0.5 * M_PI)),
                                                    (0.5 * squareWidth) + (squareWidth* 0.3 * sin(-0.5 * M_PI)))];
            }
        }
        
        [baseLine stroke];
        [triangle fill];
        [limitLine stroke];
    }
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 3];
    [NSBezierPath strokeRect: self.bounds];
}
    
@end
