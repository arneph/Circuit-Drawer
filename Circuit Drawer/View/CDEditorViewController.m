//
//  CDEditorViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 20.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDEditorViewController.h"

#import "CD2DBaseTypes.h"
#import "CDCircuitObject.h"
#import "CDConnectionElement.h"

@implementation CDEditorViewController
@synthesize circuitPanel = _circuitPanel;
@synthesize editorView = _editorView;
@synthesize detailViewController = _detailViewController;

#pragma mark Initialisation

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark Deallocation

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Notifications

- (void)updateNotifications{
    if (_circuitPanel != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: nil
                                                      object: _circuitPanel];
    }    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(circuitPanelArrayChanged:)
                                                 name: CDCircuitPanelArrayChangedNotification
                                               object: _circuitPanel];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(circuitObjectChanged:)
                                                 name: CDCircuitPanelCircuitObjectChangedNotification
                                               object: _circuitPanel];
}

- (void)circuitPanelArrayChanged: (NSNotification *)notification{
    [_editorView reloadData];
    [self updateDetailViewController];
}

- (void)circuitObjectChanged: (NSNotification *)notification{
    CD2DCoordinate coordinate = coordinateFromDictionary(notification.userInfo[@"coordinate"]);
    [_editorView reloadDataFor2DCoordinate: coordinate];
    [self updateDetailViewController];
}

#pragma mark Properties

- (CDCircuitPanel *)circuitPanel{
    return _circuitPanel;
}

- (void)setCircuitPanel: (CDCircuitPanel *)circuitPanel{
    _circuitPanel = circuitPanel;
    
    [self updateNotifications];
    [_editorView reloadData];
    [self updateDetailViewController];
}

- (CDEditorView *)view{
    return _editorView;
}

- (void)setView: (CDEditorView *)editorView{
    _editorView.dataSource = nil;
    _editorView.delegate = nil;
    
    _editorView.nextResponder = self.nextResponder;
    
    
    _editorView = editorView;
    
    self.nextResponder = _editorView.nextResponder;
    _editorView.nextResponder = self;
    
    [_editorView reloadData];
}

- (CDDetailViewController *)detailViewController{
    return _detailViewController;
}

- (void)setDetailViewController: (CDDetailViewController *)detailViewController{
    _detailViewController = detailViewController;
    
    [self updateDetailViewController];
}

#pragma mark Undo / Redo

- (void)undoableSetArrayContents: (CD2DArray *)array{
    CD2DArray *oldArray = [[CD2DArray alloc] init2DArrayWith2DArray: _circuitPanel.array];
    
    [_circuitPanel.array replaceObjectsInArrayWithObjectsFrom2DArray: array];
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetArrayContents:)
                                  object: oldArray];
    [self updateDetailViewController];
}

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

#pragma mark Cut, Copy, Paste etc.

- (void)writeSelectionToPasteboard{
    CD2DRectangle rect = [_editorView rectangleIncludingSelection];
    if (isNotFound2DRectangle(rect)) {
        return;
    }
    
    CD2DArray *array = [_circuitPanel.array sub2DArrayFromCoordinate: rect.startCoordinate
                                                        toCoordinate: rect.endCoordinate];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: array];
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    
    [pboard declareTypes: @[CDCircuitObjectsPboardType]
                   owner: self];
    [pboard setData: data
            forType: CDCircuitObjectsPboardType];
}

- (BOOL)canReadFromPasteboard{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    return ([pboard dataForType: CDCircuitObjectsPboardType] != nil);
}

- (void)replaceSelectionByReadingFromPasteboard{
    CD2DRectangle rect = [_editorView rectangleIncludingSelection];
    if (isNotFound2DRectangle(rect)) {
        return;
    }
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSData *data = [pboard dataForType: CDCircuitObjectsPboardType];
    
    CD2DArray *array = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    
    if (array.x1Count > _circuitPanel.array.x1Count) {
        array = [array sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                   toCoordinate: make2DCoordinate(_circuitPanel.array.x1Count - 1,
                                                                  array.x2Count - 1)];
    }
    if (array.x2Count > _circuitPanel.array.x2Count) {
        array = [array sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                   toCoordinate: make2DCoordinate(array.x1Count - 1,
                                                                  _circuitPanel.array.x2Count - 1)];
    }
    
    NSInteger x1 = rect.startCoordinate.x1;
    NSInteger x2 = rect.endCoordinate.x2 - array.x2Count + 1;
    
    if (x1 + array.x1Count > _circuitPanel.array.x1Count) x1 = _circuitPanel.array.x1Count - array.x1Count;
    if (x2 < 0) x2 = 0;
    
    CD2DArray *oldArray = _circuitPanel.array.deepCopy;
    
    [_circuitPanel.array replaceObjectsBeginningFrom: make2DCoordinate(x1, x2)
                              withObjectsFrom2DArray: array];
    
    for (NSUInteger tx1 = x1; tx1 < x1 + array.x1Count; tx1++) {
        for (NSUInteger tx2 = x2; tx2 < x2 + array.x2Count; tx2++) {
            CDCircuitObject *o = (CDCircuitObject*) [_circuitPanel.array objectAtX1: tx1
                                                                                 x2: tx2];
            
            for (NSUInteger i = 0; i < 8; i++) {
                CD2DSides side = (1 << i);
                CD2DSides oppositeSide = (1 << ((i + 4) % 8));
                
                if (![o canConnectToSide: side]) {
                    if ([o isKindOfClass: [CDConnectionElement class]]) {
                        [((CDConnectionElement *) o) disconnect: side];
                    }
                    continue;
                }
                if (![o hasConnectionToSide: side]) {
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
                if (is2DCoordinateIn2DRectangle(make2DCoordinate(o.coordinate.x1 + oX1,
                                                                 o.coordinate.x2 + oX2),
                                                make2DRectangle(x1, x2,
                                                                x1 + array.x1Count - 1,
                                                                x2 + array.x2Count - 1))) {
                                                    continue;
                                                }
                
                CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: o.coordinate.x1 + oX1
                                                                                                   x2: o.coordinate.x2 + oX2];
                if (!oppositeObject ||
                    ![oppositeObject canConnectToSide: oppositeSide] ||
                    ![oppositeObject isKindOfClass: [CDConnectionElement class]]) {
                    if ([o isKindOfClass: [CDConnectionElement class]]) {
                        [((CDConnectionElement *) o) disconnect: side];
                    }
                    continue;
                }
                
                CDConnectionElement *oppositeConnectionElement = (CDConnectionElement *)oppositeObject;
                [oppositeConnectionElement connect: oppositeSide];
            }
        }
    }
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetArrayContents:)
                                  object: oldArray];
    [self updateDetailViewController];
}

- (void)deleteSelection{
    CD2DArray *oldArray = _circuitPanel.array.deepCopy;
    
    for (CDCircuitObject *o in [_editorView selectedObjects]) {
        if ([o isKindOfClass: [CDConnectionElement class]]) {
            CDConnectionElement *e = (CDConnectionElement *)o;
            [e disconnectEverything];
        }else{
            [_circuitPanel.array setObject: [[CDConnectionElement alloc] init]
                              atCoordinate: o.coordinate];
        }
    }
    
    for (CDCircuitObject *o in [_editorView selectedObjects]) {
        for (NSUInteger i = 0; i < 8; i++) {
            CD2DSides side = (1 << i);
            CD2DSides oppositeSide = (1 << ((i + 4) % 8));
            
            if (![o canConnectToSide: side]) {
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
            CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: o.coordinate.x1 + oX1
                                                                                               x2: o.coordinate.x2 + oX2];
            if (![oppositeObject canConnectToSide: oppositeSide] ||
                ![oppositeObject isKindOfClass: [CDConnectionElement class]] ||
                [_editorView isCoordinateInSelection: oppositeObject.coordinate]) {
                continue;
            }
            
            CDConnectionElement *oppositeConnectionElement = (CDConnectionElement *)oppositeObject;
            [oppositeConnectionElement disconnect: oppositeSide];
        }
    }
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetArrayContents:)
                                  object: oldArray];
    [self updateDetailViewController];
}

#pragma mark Connections

- (void)addConnectionsFrom: (CD2DCoordinate)start to: (CD2DCoordinate)end connectWithCrossingLines: (BOOL)connect {
    CGFloat deltaX1 = start.x1
    - end.x1;
    CGFloat deltaX2 = start.x2
    - end.x2;
    NSUInteger minX1 = (start.x1 < end.x1) ? start.x1 : end.x1;
    NSUInteger maxX1 = (start.x1 > end.x1) ? start.x1 : end.x1;
    NSUInteger minX2 = (start.x2 < end.x2) ? start.x2 : end.x2;
    NSUInteger maxX2 = (start.x2 > end.x2) ? start.x2 : end.x2;
    
    if (deltaX1 == 0 && deltaX2 == 0) {
        return;
    }
    
    [_undoManager beginUndoGrouping];
    
    if (deltaX1 == 0) {
        for (NSUInteger x2 = minX2; x2 <= maxX2; x2++) {
            CDCircuitObject *object = (CDCircuitObject *) [[_circuitPanel array] objectAtX1: minX1
                                                                                         x2: x2];
            if (![object isKindOfClass: [CDConnectionElement class]]) {
                continue;
            }
            CDConnectionElement *connectionElement = (CDConnectionElement *)object;
            CD2DSides sidesToConnect = 0;
            
            if (x2 == minX2) {
                sidesToConnect = CD2DSideTop;
            }else if (x2 == maxX2) {
                sidesToConnect = CD2DSideBottom;
            }else{
                sidesToConnect = CD2DSideBottom | CD2DSideTop;
            }
            
            CD2DSides sidesToDisconnect = ~connectionElement.connections & sidesToConnect;
            BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
            
            [connectionElement connect: sidesToConnect];
            if (!connect) [connectionElement setConnectionsOnlyCross: YES];
            
            [_undoManager registerUndoWithTarget: self
                                        selector: @selector(undoableDisconnect:)
                                          object: @{@"coordinate" : dictionaryStoringCoordinate(connectionElement.coordinate),
                                                    @"sidesToDisconnect" : @(sidesToDisconnect),
                                                    @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
        }
    }else if (deltaX2 == 0) {
        for (NSUInteger x1 = minX1; x1 <= maxX1; x1++) {
            CDCircuitObject *object = (CDCircuitObject *) [[_circuitPanel array] objectAtX1: x1
                                                                                         x2: minX2];
            if (![object isKindOfClass: [CDConnectionElement class]]) {
                continue;
            }
            CDConnectionElement *connectionElement = (CDConnectionElement *)object;
            CD2DSides sidesToConnect = 0;
            
            if (x1 == minX1) {
                sidesToConnect = CD2DSideRight;
            }else if (x1 == maxX1) {
                sidesToConnect = CD2DSideLeft;
            }else{
                sidesToConnect = CD2DSideLeft | CD2DSideRight;
            }
            
            CD2DSides sidesToDisconnect = ~connectionElement.connections & sidesToConnect;
            BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
            
            [connectionElement connect: sidesToConnect];
            if (!connect) [connectionElement setConnectionsOnlyCross: YES];
            
            [_undoManager registerUndoWithTarget: self
                                        selector: @selector(undoableDisconnect:)
                                          object: @{@"coordinate" : dictionaryStoringCoordinate(connectionElement.coordinate),
                                                    @"sidesToDisconnect" : @(sidesToDisconnect),
                                                    @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
        }
    }else if (deltaX2 / deltaX1 == 1.0) {
        for (NSUInteger x = 0; x <= maxX1 - minX1; x++) {
            NSUInteger x1 = x + minX1;
            NSUInteger x2 = x + minX2;
            
            CDCircuitObject *object = (CDCircuitObject *) [[_circuitPanel array] objectAtX1: x1
                                                                                         x2: x2];
            if (![object isKindOfClass: [CDConnectionElement class]]) {
                continue;
            }
            CDConnectionElement *connectionElement = (CDConnectionElement *)object;
            CD2DSides sidesToConnect = 0;
            
            if (x == 0) {
                sidesToConnect = CD2DSideTopRight;
            }else if (x == maxX1 - minX1) {
                sidesToConnect = CD2DSideBottomLeft;
            }else{
                sidesToConnect = CD2DSideBottomLeft | CD2DSideTopRight;
            }
            
            CD2DSides sidesToDisconnect = ~connectionElement.connections & sidesToConnect;
            BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
            
            [connectionElement connect: sidesToConnect];
            if (!connect) [connectionElement setConnectionsOnlyCross: YES];
            
            [_undoManager registerUndoWithTarget: self
                                        selector: @selector(undoableDisconnect:)
                                          object: @{@"coordinate" : dictionaryStoringCoordinate(connectionElement.coordinate),
                                                    @"sidesToDisconnect" : @(sidesToDisconnect),
                                                    @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
        }
    }else if (deltaX2 / deltaX1 == -1.0) {
        for (NSUInteger x = 0; x <= maxX1 - minX1; x++) {
            NSUInteger x1 = x + minX1;
            NSUInteger x2 = maxX2 - x;
            
            CDCircuitObject *object = (CDCircuitObject *) [[_circuitPanel array] objectAtX1: x1
                                                                                         x2: x2];
            if (![object isKindOfClass: [CDConnectionElement class]]) {
                continue;
            }
            CDConnectionElement *connectionElement = (CDConnectionElement *)object;
            CD2DSides sidesToConnect = 0;
            
            if (x == 0) {
                sidesToConnect = CD2DSideBottomRight;
            }else if (x == maxX1 - minX1) {
                sidesToConnect = CD2DSideTopLeft;
            }else{
                sidesToConnect = CD2DSideBottomRight | CD2DSideTopLeft;
            }
            
            CD2DSides sidesToDisconnect = ~connectionElement.connections & sidesToConnect;
            BOOL connectionsDidOnlyCross = connectionElement.connectionsOnlyCross;
            
            [connectionElement connect: sidesToConnect];
            if (!connect) [connectionElement setConnectionsOnlyCross: YES];
            
            [_undoManager registerUndoWithTarget: self
                                        selector: @selector(undoableDisconnect:)
                                          object: @{@"coordinate" : dictionaryStoringCoordinate(connectionElement.coordinate),
                                                    @"sidesToDisconnect" : @(sidesToDisconnect),
                                                    @"connectionsOnlyCross" : @(connectionsDidOnlyCross)}];
        }
    }
    
    [_undoManager endUndoGrouping];
    [_undoManager setActionName: @"Drawing Connection"];
}

#pragma mark Detail View

- (void)updateDetailViewController{
    NSArray *selectedObjects = [_editorView selectedObjects];
    
    if (selectedObjects.count == 0) {
        [_detailViewController showNotApplicable];
        [self.view.window makeFirstResponder: _editorView];
        return;
    }else if (selectedObjects.count == 1) {
        [_detailViewController showDetailsForCircuitObjects: selectedObjects];
        return;
    }
    
    Class class = [selectedObjects[0] class];
    for (NSUInteger i = 1; i < selectedObjects.count; i++) {
        if ([selectedObjects[i] class] != class) {
            [_detailViewController showNotApplicable];
            [self.view.window makeFirstResponder: _editorView];
            return;
        }
    }
    
    [_detailViewController showDetailsForCircuitObjects: selectedObjects];
}

#pragma mark EditorView DataSource

- (CD2DArray *)arrayForEditorView: (CDEditorView *)editorView{
    return _circuitPanel.array;
}

- (void)editorView: (CDEditorView *)editorView
drewConnectionFrom: (CD2DCoordinate)c1
                to: (CD2DCoordinate)c2
      onlyCrossing: (BOOL)flag{
    [self addConnectionsFrom: c1 to: c2 connectWithCrossingLines: flag];
}

- (void)editorView:(CDEditorView *)editorView
              drag:(NSDraggingSession *)session
originatedInSelectionOperation:(NSDragOperation)operation{
    if (operation == NSDragOperationMove
        && [session.draggingPasteboard dataForType: CDCircuitObjectsDragType]) {
        [self deleteSelection];
        [_undoManager setActionName: @"Dragging"];
    }
}

- (void)editorView: (CDEditorView *)editorView
              drag: (id<NSDraggingInfo>)info
     endedIn2DRect: (CD2DRectangle)rect
         operation: (NSDragOperation)operation{
    NSData *data = [[info draggingPasteboard] dataForType: CDCircuitObjectsDragType];
    CD2DArray *draggingArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    
    if (draggingArray.x1Count > _circuitPanel.array.x1Count) {
        draggingArray = [draggingArray sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                                   toCoordinate: make2DCoordinate(_circuitPanel.array.x1Count - 1,
                                                                                  draggingArray.x2Count - 1)];
    }
    if (draggingArray.x2Count > _circuitPanel.array.x2Count) {
        draggingArray = [draggingArray sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                                   toCoordinate: make2DCoordinate(draggingArray.x1Count - 1,
                                                                                  _circuitPanel.array.x2Count - 1)];
    }
    
    CD2DArray *oldArray = _circuitPanel.array.deepCopy;
    
    if ([info draggingSource] == _editorView && operation == NSDragOperationMove) {
        [self deleteSelection];
        [_editorView removeCoodinatesInRectangleFromSelection: make2DRectangle(0,
                                                                               0,
                                                                               _circuitPanel.array.x1Count - 1,
                                                                               _circuitPanel.array.x2Count - 1)];
        [_editorView addCoordinatesInRectangleToSelection: rect];
        [[info draggingPasteboard] clearContents];
    }
    
    [_circuitPanel.array replaceObjectsBeginningFrom: rect.startCoordinate
                              withObjectsFrom2DArray: draggingArray];
    
    for (NSUInteger x1 = rect.startCoordinate.x1; x1 <= rect.endCoordinate.x1; x1++) {
        for (NSUInteger x2 = rect.startCoordinate.x2; x2 <= rect.endCoordinate.x2; x2++) {
            CDCircuitObject *o = (CDCircuitObject*) [_circuitPanel.array objectAtX1: x1
                                                                                 x2: x2];
            
            if (x1 > rect.startCoordinate.x1 && x1 < rect.endCoordinate.x1 &&
                x2 > rect.startCoordinate.x2 && x2 < rect.endCoordinate.x2) {
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
                
                CD2DCoordinate oc = make2DCoordinate(x1 + oX1, x2 + oX2);
                BOOL isOppositeInBounds = is2DCoordinateIn2DRectangle(oc,
                                                                      make2DRectangle(0,
                                                                                      0,
                                                                                      _circuitPanel.array.x1Count - 1,
                                                                                      _circuitPanel.array.x2Count - 1));
                BOOL isOppositeInDragginRect = is2DCoordinateIn2DRectangle(oc,
                                                                           rect);
                if (!isOppositeInBounds || isOppositeInDragginRect) {
                    continue;
                }
                
                CDCircuitObject *oppositeObject = (CDCircuitObject *) [_circuitPanel.array objectAtX1: o.coordinate.x1 + oX1
                                                                                                   x2: o.coordinate.x2 + oX2];
                
                if ([o hasConnectionToSide: side] == [oppositeObject hasConnectionToSide: oppositeSide]) {
                    continue;
                }
                
                if ([o isKindOfClass: [CDConnectionElement class]]) {
                    CDConnectionElement *ce = (CDConnectionElement *) o;
                    
                    [ce connect: side];
                }
                if ([oppositeObject isKindOfClass: [CDConnectionElement class]]) {
                    CDConnectionElement *oce = (CDConnectionElement *) oppositeObject;
                    
                    [oce connect: oppositeSide];
                }
            }
        }
    }
    
    [_undoManager registerUndoWithTarget: self
                                selector: @selector(undoableSetArrayContents:)
                                  object: oldArray];
    [_undoManager setActionName: @"Dropping"];
}

#pragma mark EditorView Delegate

- (void)editorViewSelectionDidChange: (NSNotification *)notification{
    [self updateDetailViewController];
}

#pragma mark Actions

- (void)cut: (id)sender{
    [self writeSelectionToPasteboard];
    [self deleteSelection];
    [_undoManager setActionName: @"Cut"];
}

- (void)copy: (id)sender{
    [self writeSelectionToPasteboard];
}

- (void)paste: (id)sender{
    [self replaceSelectionByReadingFromPasteboard];
    [_undoManager setActionName: @"Paste"];
}

- (void)delete: (id)sender{
    [self deleteSelection];
    [_undoManager setActionName: @"Delete"];
}

- (BOOL)validateMenuItem: (NSMenuItem *)menuItem{
    if (menuItem.action == @selector(cut:)) {
        return _allowsEditing && _editorView.hasSelection;
    }else if (menuItem.action == @selector(copy:)) {
        return _editorView.hasSelection;
    }else if (menuItem.action == @selector(paste:)) {
        return _allowsEditing && _editorView.hasSelection && self.canReadFromPasteboard;
    }else if (menuItem.action == @selector(delete:)) {
        return _allowsEditing && _editorView.hasSelection;
    }else{
        return [super validateMenuItem: menuItem];
    }
}

@end
