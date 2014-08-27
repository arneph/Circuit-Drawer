//
//  CDEditorView.m
//  Circuit Drawer
//
//  Created by Programmieren on 27.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDEditorView.h"
#import "CDCircuitObject.h"
#import "CDConnectionElement.h"
#import "CDDiode.h"

@implementation CDEditorView{
    CD2DArray *array;
    
    BOOL dragged;
    
    NSMutableArray *selectionCoordinates;
    CD2DCoordinate selectionOperationStartCoordinate;
    CD2DRectangle selectionOperationRectangle;
    BOOL selectionOperationIsDeselection;
    
    CD2DArray *draggingArray;
    CD2DRectangle draggingRect;
    
    CD2DCoordinate connectionPenStartCoordinate;
    CD2DCoordinate connectionPenEndCoordinate;
    BOOL currentConnectionPenOperationIsValid;
}

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize showGrid = _showGrid;
@synthesize activeTool = _activeTool;

#pragma mark Initialisation

- (instancetype)init{
    self = [super init];
    if (self) {
        _allowsEditing = YES;
        _showGrid = YES;
        _activeTool = CDEditorViewToolPointer;
        
        dragged = NO;
        
        selectionCoordinates = [[NSMutableArray alloc] init];
        selectionOperationStartCoordinate = NotFound2DCoordinate;
        selectionOperationRectangle = NotFound2DRectangle;
        selectionOperationIsDeselection = NO;
        
        draggingArray = nil;
        draggingRect = NotFound2DRectangle;
        
        connectionPenStartCoordinate = NotFound2DCoordinate;
        connectionPenEndCoordinate = NotFound2DCoordinate;
        currentConnectionPenOperationIsValid = NO;
        
        [self registerForDraggedTypes: @[CDCircuitObjectsDragType]];
        [self reloadData];
    }
    return self;
}

- (instancetype)initWithFrame: (NSRect)frame{
    frame.size = NSMakeSize(256 * [self squareWidth], 128 * [self squareWidth]);
    
    self = [super initWithFrame:frame];
    if (self) {
        _allowsEditing = YES;
        _showGrid = YES;
        _activeTool = CDEditorViewToolPointer;
        
        dragged = NO;
        
        selectionCoordinates = [[NSMutableArray alloc] init];
        selectionOperationStartCoordinate = NotFound2DCoordinate;
        selectionOperationRectangle = NotFound2DRectangle;
        selectionOperationIsDeselection = NO;
        
        draggingArray = nil;
        draggingRect = NotFound2DRectangle;
        
        connectionPenStartCoordinate = NotFound2DCoordinate;
        connectionPenEndCoordinate = NotFound2DCoordinate;
        currentConnectionPenOperationIsValid = NO;
        
        [self registerForDraggedTypes: @[CDCircuitObjectsDragType]];
        [self reloadData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        _allowsEditing = YES;
        _showGrid = YES;
        _activeTool = CDEditorViewToolPointer;
        
        dragged = NO;
        
        selectionCoordinates = [[NSMutableArray alloc] init];
        selectionOperationStartCoordinate = NotFound2DCoordinate;
        selectionOperationRectangle = NotFound2DRectangle;
        selectionOperationIsDeselection = NO;
        
        draggingArray = nil;
        draggingRect = NotFound2DRectangle;
        
        connectionPenStartCoordinate = NotFound2DCoordinate;
        connectionPenEndCoordinate = NotFound2DCoordinate;
        currentConnectionPenOperationIsValid = NO;
        
        [self registerForDraggedTypes: @[CDCircuitObjectsDragType]];
        [self reloadData];
    }
    return self;
}

#pragma mark State Coding

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeBool: _showGrid forKey: @"showGrid"];
    [coder encodeInt: _activeTool forKey: @"activeTool"];
}

- (void)restoreStateWithCoder:(NSCoder *)coder{
    [super restoreStateWithCoder: coder];
    
    _showGrid = [coder decodeBoolForKey: @"showGrid"];
    _activeTool = [coder decodeIntForKey: @"activeTool"];
}

#pragma mark Properties

- (id<CDEditorViewDataSource>)dataSource{
    return _dataSource;
}

- (void)setDataSource:(id<CDEditorViewDataSource>)dataSource{
    _dataSource = dataSource;
    
    [self reloadData];
}

- (id<CDEditorViewDelegate>)delegate{
    return _delegate;
}

- (void)setDelegate:(id<CDEditorViewDelegate>)delegate{
    [[NSNotificationCenter defaultCenter] removeObserver: _delegate
                                                    name: nil
                                                  object: self];
    
    _delegate = delegate;
    
    if ([_delegate respondsToSelector: @selector(editorViewSelectionDidChange:)]) {
        [[NSNotificationCenter defaultCenter] addObserver: _delegate
                                                 selector: @selector(editorViewSelectionDidChange:)
                                                     name: CDEditorViewSelectionDidChangeNotification
                                                   object: self];
    }
    if ([_delegate respondsToSelector: @selector(editorViewActiveToolDidChange:)]) {
        [[NSNotificationCenter defaultCenter] addObserver: _delegate
                                                 selector: @selector(editorViewActiveToolDidChange:)
                                                     name: CDEditorViewActiveToolDidChangeNotification
                                                   object: self];
    }
}

#pragma mark Data

- (void)reloadData{
    array = [_dataSource arrayForEditorView: self];
    
    if (!array) {
        array = [[CD2DArray alloc] init2DArrayWithX1Count: 24
                                                  x2Count: 16
                                                   object: [[CDConnectionElement alloc] init]];
    }
    
    [self setNeedsDisplay: YES];
}

- (void)reloadDataFor2DCoordinate: (CD2DCoordinate)coordinate{
    array = [_dataSource arrayForEditorView: self];
    
    if (!array) {
        array = [[CD2DArray alloc] init2DArrayWithX1Count: 24
                                                  x2Count: 16
                                                   object: [[CDConnectionElement alloc] init]];
    }
    
    [self setNeedsDisplayInRect: NSMakeRect((coordinate.x1 - 1) * [self squareWidth],
                                            (coordinate.x2 - 1) * [self squareWidth],
                                            3 * [self squareWidth],
                                            3 * [self squareWidth])];
}

- (void)reloadDataFor2DRectangle:(CD2DRectangle)rectangle{
    array = [_dataSource arrayForEditorView: self];
    
    if (!array) {
        array = [[CD2DArray alloc] init2DArrayWithX1Count: 24
                                                  x2Count: 16
                                                   object: [[CDConnectionElement alloc] init]];
    }
    
    [self setNeedsDisplayInRect: NSMakeRect((rectangle.startCoordinate.x1 - 1) * [self squareWidth],
                                            (rectangle.startCoordinate.x2 - 1) * [self squareWidth],
                                            (rectangle.endCoordinate.x1 - rectangle.startCoordinate.x1 + 3)
                                            * [self squareWidth],
                                            (rectangle.endCoordinate.x2 - rectangle.startCoordinate.x2 + 3)
                                            * [self squareWidth])];
}

#pragma mark Drag & Drop

- (NSDragOperation)draggingSession: (NSDraggingSession *)session sourceOperationMaskForDraggingContext: (NSDraggingContext)context{
    if (context == NSDraggingContextWithinApplication) {
        return NSDragOperationMove | NSDragOperationCopy;
    }else{
        return NSDragOperationNone;
    }
}

- (void)draggingSession: (NSDraggingSession *)session
           endedAtPoint: (NSPoint)screenPoint
              operation: (NSDragOperation)operation{
    [_dataSource editorView: self drag: session originatedInSelectionOperation: operation];
}

- (NSDragOperation)draggingEntered: (id <NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([pboard dataForType: CDCircuitObjectsDragType] == nil) {
        return NSDragOperationNone;
    }else{
        [self updateDraggingDestinationRectForDragginInfo: sender];
        
        if (([NSEvent modifierFlags] & NSAlternateKeyMask) == YES) {
            return NSDragOperationCopy;
        }else{
            return NSDragOperationMove;
        }
    }
}

- (BOOL)wantsPeriodicDraggingUpdates{
    return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([pboard dataForType: CDCircuitObjectsDragType] == nil) {
        return NSDragOperationNone;
    }else{
        [self updateDraggingDestinationRectForDragginInfo: sender];
        
        if (([NSEvent modifierFlags] & NSAlternateKeyMask) != 0) {
            return NSDragOperationCopy;
        }else{
            return NSDragOperationMove;
        }
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
    draggingArray = nil;
    draggingRect = NotFound2DRectangle;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation: (id<NSDraggingInfo>)sender{
    if (!draggingArray || isNotFound2DRectangle(draggingRect)) {
        return NO;
    }
    
    [sender setAnimatesToDestination: YES];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender{
    [sender enumerateDraggingItemsWithOptions: NSDraggingItemEnumerationConcurrent
                                      forView: self
                                      classes: @[[NSPasteboardItem class]]
                                searchOptions: @{}
                                   usingBlock: ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop){
        CGFloat squareWidth = [self squareWidth];
        [draggingItem setDraggingFrame: NSMakeRect(draggingRect.startCoordinate.x1 * squareWidth,
                                                   draggingRect.startCoordinate.x2 * squareWidth,
                                                   (draggingRect.endCoordinate.x1
                                                    - draggingRect.startCoordinate.x1 + 1)
                                                   * squareWidth,
                                                   (draggingRect.endCoordinate.x2
                                                    - draggingRect.startCoordinate.x2 + 1)
                                                   * squareWidth)];
    }];
        
    [_dataSource editorView: self
                       drag: sender
              endedIn2DRect: draggingRect
                  operation: ([NSEvent modifierFlags] & NSAlternateKeyMask) ? NSDragOperationCopy : NSDragOperationMove];
    
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender{
    draggingArray = nil;
    draggingRect = NotFound2DRectangle;
    
    [self reloadData];
}

- (void)updateDraggingDestinationRectForDragginInfo: (id <NSDraggingInfo>)info{
    if (!draggingArray) {
        NSData *data = [[info draggingPasteboard] dataForType: CDCircuitObjectsDragType];
        draggingArray = [NSKeyedUnarchiver unarchiveObjectWithData: data];
        
        if (draggingArray.x1Count > array.x1Count) {
            draggingArray = [array sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                               toCoordinate: make2DCoordinate(array.x1Count - 1,
                                                                              draggingArray.x2Count - 1)];
        }
        if (draggingArray.x2Count > array.x2Count) {
            draggingArray = [array sub2DArrayFromCoordinate: make2DCoordinate(0, 0)
                                               toCoordinate: make2DCoordinate(draggingArray.x1Count - 1,
                                                                              array.x2Count - 1)];
        }
    }
    
    if (isNotFound2DRectangle(draggingRect) || draggingArray.totalCount < array.totalCount) {
        NSPoint point = [self convertPoint: [info draggedImageLocation]
                                  fromView: nil];
        CD2DCoordinate c1 = make2DCoordinate(floor((point.x / [self squareWidth]) + 0.5),
                                             floor((point.y / [self squareWidth]) + 0.5));
        if (point.x < 0.0) c1.x1 = 0;
        if (point.y < 0.0) c1.x2 = 0;
            
        CD2DCoordinate c2 = make2DCoordinate(c1.x1 + draggingArray.x1Count - 1, c1.x2 + draggingArray.x2Count - 1);
        CD2DRectangle rect = make2DRectangleWithCoordinates(c1, c2);
        
        if (rect.endCoordinate.x1 >= array.x1Count) {
            rect.startCoordinate.x1 -= rect.endCoordinate.x1 - array.x1Count + 1;
            rect.endCoordinate.x1 = array.x1Count - 1;
        }
        if (rect.endCoordinate.x2 >= array.x2Count) {
            rect.startCoordinate.x2 -= rect.endCoordinate.x2 - array.x2Count + 1;
            rect.endCoordinate.x2 = array.x2Count - 1;
        }
        
        draggingRect = rect;
        [self setNeedsDisplay: YES];
    }
}

#pragma mark Selection

- (BOOL)hasSelection{
    return !isNotFound2DRectangle([self rectangleIncludingSelection]);
}

- (BOOL)isCoordinateInSelection: (CD2DCoordinate)coordinate{
    if (selectionOperationIsDeselection &&
        is2DCoordinateIn2DRectangle(coordinate, selectionOperationRectangle)) {
        return NO;
    }
    if (is2DCoordinateIn2DRectangle(coordinate, selectionOperationRectangle)) {
        return YES;
    }
    if (selectionCoordinates.count == 0) {
        return NO;
    }
    for (CD2DCoordinateObj *o in selectionCoordinates) {
        if (are2DCoordinatesEqual(o.c, coordinate)) {
            return YES;
        }
    }
    return NO;
}

- (CD2DRectangle)rectangleIncludingSelection{
    NSUInteger minX1 = NSNotFound;
    NSUInteger minX2 = NSNotFound;
    NSUInteger maxX1 = NSNotFound;
    NSUInteger maxX2 = NSNotFound;
    
    for (NSUInteger x1 = 0; x1 < self.gridSize.width; x1++) {
        for (NSUInteger x2 = 0; x2 < self.gridSize.height; x2++) {
            CD2DCoordinate c = make2DCoordinate(x1, x2);
            
            if (![self isCoordinateInSelection: c]) {
                continue;
            }
            
            if (minX1 == NSNotFound) {
                minX1 = c.x1;
                minX2 = c.x2;
                maxX1 = c.x1;
                maxX2 = c.x2;
                continue;
            }
            
            if (minX1 > c.x1) {
                minX1 = c.x1;
            }else if (maxX1 < c.x1) {
                maxX1 = c.x1;
            }
            if (minX2 > c.x2) {
                minX2 = c.x2;
            }else if (maxX2 < c.x2) {
                maxX2 = c.x2;
            }
        }
    }
    
    if (minX1 == NSNotFound) {
        return NotFound2DRectangle;
    }else{
        return make2DRectangle(minX1, minX2, maxX1, maxX2);
    }
}

- (NSArray *)selectedObjects{
    NSMutableArray *selectedObjects = [[NSMutableArray alloc] init];
    for (NSUInteger x1 = 0; x1 < self.gridSize.width; x1++) {
        for (NSUInteger x2 = 0; x2 < self.gridSize.height; x2++) {
            if ([self isCoordinateInSelection: make2DCoordinate(x1, x2)]) {
                [selectedObjects addObject: [array objectAtX1: x1
                                                           x2: x2]];
            }
        }
    }
    return [NSArray arrayWithArray: selectedObjects];
}

- (void)addCoordinatesInRectangleToSelection: (CD2DRectangle)rectangle{
    for (NSInteger x1 = rectangle.startCoordinate.x1;
         x1 <= rectangle.endCoordinate.x1; x1++) {
        for (NSInteger x2 = rectangle.startCoordinate.x2;
             x2 <= rectangle.endCoordinate.x2; x2++) {
            CD2DCoordinate c = make2DCoordinate(x1, x2);
            
            if (![self isCoordinateInSelection: c]) {
                [selectionCoordinates addObject: [CD2DCoordinateObj objForCoordinate: c]];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewSelectionDidChangeNotification
                                                        object: self];
}

- (void)removeCoodinatesInRectangleFromSelection: (CD2DRectangle)rectangle{
    for (NSInteger i = selectionCoordinates.count - 1; i >= 0; i--) {
        CD2DCoordinateObj *o = selectionCoordinates[i];
        if (is2DCoordinateIn2DRectangle(o.c, rectangle)) {
            [selectionCoordinates removeObjectAtIndex: i];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewSelectionDidChangeNotification
                                                        object: self];
}

- (CD2DSides)sidesWithSelectionBoundsForCoordinate: (CD2DCoordinate)coordinate{
    if (![self isCoordinateInSelection: coordinate]) {
        return 0;
    }
    
    CDCircuitObject *object = (CDCircuitObject *)[array objectAtCoordinate: coordinate];
    CD2DSides sides = 0;
    if (object.isLeftMost) {
        sides = sides | CD2DSideLeft;
    }else{
        CD2DCoordinate leftCoordinate = make2DCoordinate(coordinate.x1 - 1, coordinate.x2);
        if (![self isCoordinateInSelection: leftCoordinate]) {
            sides = sides | CD2DSideLeft;
        }
    }
    if (object.isRightMost) {
        sides = sides | CD2DSideRight;
    }else{
        CD2DCoordinate rightCoordinate = make2DCoordinate(coordinate.x1 + 1, coordinate.x2);
        if (![self isCoordinateInSelection: rightCoordinate]) {
            sides = sides | CD2DSideRight;
        }
    }
    if (object.isBottomMost) {
        sides = sides | CD2DSideBottom;
    }else{
        CD2DCoordinate bottomCoordinate = make2DCoordinate(coordinate.x1, coordinate.x2 - 1);
        if (![self isCoordinateInSelection: bottomCoordinate]) {
            sides = sides | CD2DSideBottom;
        }
    }
    if (object.isTopMost) {
        sides = sides | CD2DSideTop;
    }else{
        CD2DCoordinate topCoordinate = make2DCoordinate(coordinate.x1, coordinate.x2 + 1);
        if (![self isCoordinateInSelection: topCoordinate]) {
            sides = sides | CD2DSideTop;
        }
    }
    return sides;
}

#pragma mark Grid

- (BOOL)showsGrid{
    return _showGrid;
}

- (void)setShowGrid:(BOOL)showGrid{
    _showGrid = showGrid;
    [self setNeedsDisplay: YES];
    [self invalidateRestorableState];
}

#pragma mark Tools

- (CDEditorViewTool)activeTool{
    return _activeTool;
}

- (void)setActiveTool:(CDEditorViewTool)activeTool{
    if (_activeTool == activeTool || !_allowsEditing) return;
    
    _activeTool = activeTool;
    [self invalidateRestorableState];
    
    [self.window invalidateCursorRectsForView:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewActiveToolDidChangeNotification
                                                        object: self];
}

- (CD2DCoordinate)coordinateForPoint: (NSPoint)point{
    CD2DCoordinate coordinate = make2DCoordinate(floor(point.x / [self squareWidth]),
                                                 floor(point.y / [self squareWidth]));
    return coordinate;
}

- (void)resetCursorRects{
    [super resetCursorRects];
    
    if (_activeTool == CDEditorViewToolPointer) {
        [self addCursorRect: self.visibleRect
                     cursor: [NSCursor arrowCursor]];
        
    }else if (_activeTool == CDEditorViewToolConnectionPen) {
        NSImage *image = [NSImage imageNamed: @"Pen Pointer"];
        [image setSize: NSMakeSize(16, 16)];
        [self addCursorRect: self.visibleRect
                     cursor: [[NSCursor alloc] initWithImage: image
                                                     hotSpot: NSMakePoint(0, 15)]];
    }
}

#pragma mark Responding

- (BOOL)acceptsFirstResponder{
    return YES;
}

- (void)mouseDown: (NSEvent *)theEvent{
    NSPoint point = [self convertPoint: theEvent.locationInWindow
                              fromView: nil];
    
    if (!NSPointInRect(point, self.visibleRect)) return;
    
    if (_activeTool == CDEditorViewToolPointer) {
        CD2DCoordinate coordinate = [self coordinateForPoint: point];
        
        if (![self isCoordinateInSelection: coordinate]) {
            selectionOperationStartCoordinate = coordinate;
            selectionOperationRectangle = make2DRectangleWithCoordinates(coordinate,
                                                                         coordinate);
            selectionOperationIsDeselection = NO;
            if (~theEvent.modifierFlags & NSCommandKeyMask) {
                [selectionCoordinates removeAllObjects];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewSelectionDidChangeNotification
                                                                object: self];
            [self setNeedsDisplay: YES];
        }else if (theEvent.modifierFlags & NSCommandKeyMask) {
            selectionOperationStartCoordinate = coordinate;
            selectionOperationRectangle = make2DRectangleWithCoordinates(coordinate,
                                                                         coordinate);
            selectionOperationIsDeselection = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewSelectionDidChangeNotification
                                                                object: self];
            [self setNeedsDisplay: YES];
        }
    }else if (_activeTool == CDEditorViewToolConnectionPen) {
        connectionPenStartCoordinate = [self coordinateForPoint: point];
        connectionPenEndCoordinate = connectionPenStartCoordinate;
        currentConnectionPenOperationIsValid = YES;
        
        [self setNeedsDisplay: YES];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent{
    [self.window invalidateCursorRectsForView:self];
    NSPoint point = [self convertPoint: theEvent.locationInWindow
                              fromView: nil];
    dragged = YES;
    
    if (_activeTool == CDEditorViewToolPointer) {
        CD2DCoordinate coordinate = [self coordinateForPoint: point];
        
        if (!isNotFound2DCoordinate(selectionOperationStartCoordinate)) {
            selectionOperationRectangle = make2DRectangleWithCoordinates(selectionOperationStartCoordinate,
                                                                         coordinate);
            
            [[NSNotificationCenter defaultCenter] postNotificationName: CDEditorViewSelectionDidChangeNotification
                                                                object: self];
            [self setNeedsDisplay: YES];
        }else{
            CD2DRectangle rect = [self rectangleIncludingSelection];
            if (isNotFound2DRectangle(rect) || draggingArray || !isNotFound2DRectangle(draggingRect)) {
                return;
            }
            
            CD2DArray *dArray = [array sub2DArrayFromCoordinate: rect.startCoordinate
                                                   toCoordinate: rect.endCoordinate];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject: dArray];
            
            //Dragging Image:
            NSPoint imageOrigin = NSMakePoint(rect.startCoordinate.x1 * self.squareWidth - 1.0,
                                              rect.startCoordinate.x2 * self.squareWidth - 1.0);
            NSSize imageSize = NSMakeSize((rect.endCoordinate.x1 - rect.startCoordinate.x1 + 1) * [self squareWidth] + 2.0,
                                          (rect.endCoordinate.x2 - rect.startCoordinate.x2 + 1) * [self squareWidth] + 2.0);
            NSRect imageRect;
            imageRect.origin = imageOrigin;
            imageRect.size = imageSize;
            
            NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect: imageRect];
            NSImage *image = [[NSImage alloc] init];
            
            [self cacheDisplayInRect: imageRect toBitmapImageRep: imageRep];
            [image addRepresentation: imageRep];
            
            
            NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
            [pboardItem setData: data
                        forType: CDCircuitObjectsDragType];
            NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter: pboardItem];
            [draggingItem setDraggingFrame: imageRect
                                  contents: image];
            
            NSDraggingSession *session = [self beginDraggingSessionWithItems: @[draggingItem]
                                                                       event: theEvent
                                                                      source: self];
            session.animatesToStartingPositionsOnCancelOrFail = YES;
            
            return;
        }
    }else if (_activeTool == CDEditorViewToolConnectionPen) {
        CD2DCoordinate newEndCoordinate = [self coordinateForPoint: point];
        
        if (newEndCoordinate.x1 >= 0 && newEndCoordinate.x1 < array.x1Count &&
            newEndCoordinate.x2 >= 0 && newEndCoordinate.x2 < array.x2Count) {
            connectionPenEndCoordinate = newEndCoordinate;
        }
        
        CGFloat deltaX1 = connectionPenStartCoordinate.x1
                          - connectionPenEndCoordinate.x1;
        CGFloat deltaX2 = connectionPenStartCoordinate.x2
                          - connectionPenEndCoordinate.x2;
        if (deltaX1 == 0 ||
            deltaX2 == 0 ||
            (deltaX2 / deltaX1) == 1.0 ||
            (deltaX2 / deltaX1) == -1.0) {
            currentConnectionPenOperationIsValid = YES;
        }else{
            currentConnectionPenOperationIsValid = NO;
        }
        
        [self setNeedsDisplay: YES];
    }
}

- (void)mouseUp:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint: theEvent.locationInWindow
                              fromView: nil];
    
    if (!dragged && !NSPointInRect(point, self.visibleRect)) return;
    dragged = NO;
    
    if (_activeTool == CDEditorViewToolPointer) {
        CD2DCoordinate coordinate = [self coordinateForPoint: point];
        
        if (!isNotFound2DCoordinate(selectionOperationStartCoordinate)) {
            if (NSPointInRect(point, self.bounds)) {
                selectionOperationRectangle = make2DRectangleWithCoordinates(selectionOperationStartCoordinate,
                                                                             coordinate);
            }
            CD2DRectangle newSelectionRectangle = selectionOperationRectangle;
            BOOL deselect = selectionOperationIsDeselection;
            
            selectionOperationStartCoordinate = NotFound2DCoordinate;
            selectionOperationRectangle = NotFound2DRectangle;
            selectionOperationIsDeselection = NO;
            
            if (!deselect) {
                [self addCoordinatesInRectangleToSelection: newSelectionRectangle];
            }else{
                [self removeCoodinatesInRectangleFromSelection: newSelectionRectangle];
            }
            
            [self setNeedsDisplay: YES];
        }
    }else if (_activeTool == CDEditorViewToolConnectionPen) {
        CD2DCoordinate newEndCoordinate = [self coordinateForPoint: point];
        
        if (newEndCoordinate.x1 >= 0 && newEndCoordinate.x1 < array.x1Count &&
            newEndCoordinate.x2 >= 0 && newEndCoordinate.x2 < array.x2Count) {
            connectionPenEndCoordinate = newEndCoordinate;
        }
        
        CGFloat deltaX1 = connectionPenStartCoordinate.x1
                          - connectionPenEndCoordinate.x1;
        CGFloat deltaX2 = connectionPenStartCoordinate.x2
                          - connectionPenEndCoordinate.x2;
        if (deltaX1 == 0 ||
            deltaX2 == 0 ||
            (deltaX2 / deltaX1) == 1.0 ||
            (deltaX2 / deltaX1) == -1.0) {
            [_dataSource editorView: self
                 drewConnectionFrom: connectionPenStartCoordinate
                                 to: connectionPenEndCoordinate
                       onlyCrossing: !(theEvent.modifierFlags & NSAlternateKeyMask)];
        }
        
        connectionPenStartCoordinate = NotFound2DCoordinate;
        connectionPenEndCoordinate = NotFound2DCoordinate;
        currentConnectionPenOperationIsValid = NO;
        
        [self setNeedsDisplay: YES];
    }
}

#pragma mark Actions

- (void)selectAll: (id)sender{
    [self addCoordinatesInRectangleToSelection: make2DRectangle(0,
                                                                0,
                                                                self.gridSize.width - 1,
                                                                self.gridSize.height - 1)];
    [self setNeedsDisplay: YES];
}

- (void)deselectAll: (id)sender{
    [self removeCoodinatesInRectangleFromSelection: make2DRectangle(0,
                                                                    0,
                                                                    self.gridSize.width - 1,
                                                                    self.gridSize.height - 1)];
    
    [self setNeedsDisplay: YES];
}

- (void)toogleGrid: (id)sender{
    [self setShowGrid: !_showGrid];
}

- (void)usePointerTool:(id)sender{
    [self setActiveTool: CDEditorViewToolPointer];
}

- (void)useConnectionPenTool:(id)sender {
    [self setActiveTool: CDEditorViewToolConnectionPen];
}

- (BOOL)validateMenuItem: (NSMenuItem *)menuItem{
    if (menuItem.action == @selector(selectAll:)) {
        return isNotFound2DCoordinate(selectionOperationStartCoordinate);
    }else if (menuItem.action == @selector(deselectAll:)) {
        return isNotFound2DCoordinate(selectionOperationStartCoordinate);
    }else if (menuItem.action == @selector(toogleGrid:)) {
        menuItem.title = (_showGrid) ? @"Hide Grid" : @"Show Grid";
        return YES;
    }else if (menuItem.action == @selector(usePointerTool:)) {
        menuItem.state = (_activeTool == CDEditorViewToolPointer);
        return _allowsEditing;
    }else if (menuItem.action == @selector(useConnectionPenTool:)) {
        menuItem.state = (_activeTool == CDEditorViewToolConnectionPen);
        return _allowsEditing;
    }else{
        return [super validateMenuItem: menuItem];
    }
}

#pragma mark Drawing

- (NSSize)gridSize {
    if (!array) {
        return NSMakeSize(24, 16);
    }
    
    return NSMakeSize(array.x1Count,
                      array.x2Count);
}

- (CGFloat)squareWidth {
    return 50;
}

- (BOOL)isOpaque {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:dirtyRect];
    
    CGFloat squareWidth = [self squareWidth];
    
    //Draw the Grid:
    if (_showGrid) {
        [self drawGridInRect: dirtyRect];
    }
    
    //Draw the Contents:
    [self drawContentsInRect: dirtyRect];
    
    //Draw the Selection:
    [self drawSelectionInRect: dirtyRect];
    
    //Draw Tool related things:
    if (_activeTool == CDEditorViewToolPointer) {
        
    }else if (_activeTool == CDEditorViewToolConnectionPen) {
        if (!isNotFound2DCoordinate(connectionPenStartCoordinate) &&
            !isNotFound2DCoordinate(connectionPenEndCoordinate)) {
            
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineCapStyle: NSButtLineCapStyle];
            NSBezierPath *path = [[NSBezierPath alloc] init];
            
            [path setLineWidth:1.5];
            if (!currentConnectionPenOperationIsValid) {
                CGFloat ary[2];
                ary[0] = 5.0;
                ary[1] = 5.0;
                [path setLineDash: ary count: 2 phase: 0.0];
            }
            
            [path moveToPoint: NSMakePoint((connectionPenStartCoordinate.x1 + 0.5) * squareWidth,
                                           (connectionPenStartCoordinate.x2 + 0.5) * squareWidth)];
            [path lineToPoint: NSMakePoint((connectionPenEndCoordinate.x1 + 0.5) * squareWidth,
                                           (connectionPenEndCoordinate.x2 + 0.5) * squareWidth)];
            [path stroke];
        }
    }
    
    //Draw the Dragging Destination Rect:
    [self drawDragginDestinationInRect: dirtyRect];
}

- (void)drawGridInRect: (NSRect)dirtyRect{
    CGFloat squareWidth = [self squareWidth];
    
    NSUInteger minColumn = floor(NSMinX(dirtyRect) / squareWidth);
    NSUInteger maxColumn = ceil(NSMaxX(dirtyRect) / squareWidth);
    NSUInteger minRow = floor(NSMinY(dirtyRect) / squareWidth);
    NSUInteger maxRow = ceil(NSMaxY(dirtyRect) / squareWidth);
    
    if (maxRow >= [self gridSize].height) maxRow = [self gridSize].height - 1;
    if (maxColumn >= [self gridSize].width) maxColumn = [self gridSize].width - 1;
    
    [[NSColor lightGrayColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    [NSBezierPath setDefaultLineCapStyle: NSButtLineCapStyle];
    
    for (NSUInteger c = minColumn; c <= maxColumn; c++) {
        NSBezierPath *verticalGridLine = [[NSBezierPath alloc] init];
        
        if (minRow == 0) {
            [verticalGridLine moveToPoint: NSMakePoint((c + 0.5) * squareWidth, 0.5 * squareWidth)];
        }else{
            [verticalGridLine moveToPoint: NSMakePoint((c + 0.5) * squareWidth, minRow * squareWidth)];
        }
        
        if (maxRow == [self gridSize].height - 1) {
            [verticalGridLine lineToPoint: NSMakePoint((c + 0.5) * squareWidth, (maxRow + 0.5) * squareWidth)];
        }else{
            [verticalGridLine lineToPoint: NSMakePoint((c + 0.5) * squareWidth, maxRow * squareWidth)];
        }
        
        [verticalGridLine stroke];
    }
    
    for (NSUInteger r = minRow; r <= maxRow; r++) {
        NSBezierPath *horizontalGridLine = [[NSBezierPath alloc] init];
        
        if (minColumn == 0) {
            [horizontalGridLine moveToPoint: NSMakePoint(0.5 * squareWidth, (r + 0.5) * squareWidth)];
        }else{
            [horizontalGridLine moveToPoint: NSMakePoint(minColumn * squareWidth, (r + 0.5) * squareWidth)];
        }
        
        if (maxColumn == [self gridSize].width - 1) {
            [horizontalGridLine lineToPoint: NSMakePoint((maxColumn + 0.5) * squareWidth, (r + 0.5) * squareWidth)];
        }else{
            [horizontalGridLine lineToPoint: NSMakePoint(maxColumn * squareWidth, (r + 0.5) * squareWidth)];
        }
        
        [horizontalGridLine stroke];
    }
}

- (void)drawContentsInRect: (NSRect)dirtyRect{
    CGFloat squareWidth = [self squareWidth];
    
    NSUInteger minColumn = floor(NSMinX(dirtyRect) / squareWidth);
    NSUInteger maxColumn = ceil(NSMaxX(dirtyRect) / squareWidth);
    NSUInteger minRow = floor(NSMinY(dirtyRect) / squareWidth);
    NSUInteger maxRow = ceil(NSMaxY(dirtyRect) / squareWidth);
    
    if (maxRow >= [self gridSize].height) maxRow = [self gridSize].height - 1;
    if (maxColumn >= [self gridSize].width) maxColumn = [self gridSize].width - 1;
    
    [NSBezierPath setDefaultLineWidth: 1.5];
    [NSBezierPath setDefaultLineCapStyle: NSButtLineCapStyle];
    
    for (NSUInteger c = minColumn; c <= maxColumn; c++) {
        for (NSUInteger r = minRow; r <= maxRow; r++) {
            CDCircuitObject *circuitObject = (CDCircuitObject *)[array objectAtX1:c x2:r];
            
            if ([circuitObject isKindOfClass: [CDConnectionElement class]]) {
                [self drawConnectionElement: (CDConnectionElement *)circuitObject];
            }else if ([circuitObject isKindOfClass: [CDDiode class]]) {
                [self drawDiode: (CDDiode *)circuitObject];
            }
        }
    }
}

- (void)drawConnectionElement: (CDConnectionElement *)connectionElement{
    CGFloat squareWidth = [self squareWidth];
    
    NSUInteger x1 = connectionElement.coordinate.x1;
    NSUInteger x2 = connectionElement.coordinate.x2;
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    
    if (connectionElement.numberOfConnections > 2 && !connectionElement.connectionsOnlyCross) {
        NSBezierPath *circle = [[NSBezierPath alloc] init];
        [circle appendBezierPathWithOvalInRect: NSMakeRect(((x1 + 0.5) * squareWidth) - (squareWidth / 16),
                                                           ((x2 + 0.5) * squareWidth) - (squareWidth / 16),
                                                           squareWidth / 8, squareWidth / 8)];
        [circle fill];
    }
    
    if ([connectionElement isConnected: CD2DSideRight]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideTopRight]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                       (x2 + 1) * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideTop]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 1) * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideTopLeft]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint(x1 * squareWidth,
                                       (x2 + 1) * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideLeft]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint(x1 * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideBottomLeft]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        if (x2 > 0) {
            CDCircuitObject *circuitObjectBelow = (CDCircuitObject *)[array objectAtX1: x1
                                                                                    x2: x2 - 1];
            if ([circuitObjectBelow hasConnectionToSide: CD2DSideTopLeft]) {
                [[NSColor whiteColor] set];
                [NSBezierPath setDefaultLineWidth: 10];
                [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 - 0.2) * squareWidth,
                                                               (x2 - 0.2) * squareWidth)
                                          toPoint: NSMakePoint((x1 + 0.2) * squareWidth,
                                                               (x2 + 0.2) * squareWidth)];
                [[NSColor blackColor] set];
                [NSBezierPath setDefaultLineWidth: 1.5];
                
                [path moveToPoint: NSMakePoint((x1 - 0.2) * squareWidth,
                                               (x2 - 0.2) * squareWidth)];
            }else{
                [path moveToPoint: NSMakePoint(x1 * squareWidth,
                                               x2 * squareWidth)];
            }
        }else{
            [path moveToPoint: NSMakePoint(x1 * squareWidth,
                                           x2 * squareWidth)];
        }
        
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected: CD2DSideBottom]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       x2 * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    if ([connectionElement isConnected:CD2DSideBottomRight]) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                       x2 * squareWidth)];
        [path lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                       (x2 + 0.5) * squareWidth)];
        [path stroke];
    }
    
    if (!connectionElement.connectionsOnlyCross) return;
    
    if ([connectionElement isConnected: CD2DSideRight]) {
        [[NSColor whiteColor] set];
        [NSBezierPath setDefaultLineWidth: 10];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.3) * squareWidth,
                                                       (x2 + 0.5) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.7) * squareWidth,
                                                       (x2 + 0.5) * squareWidth)];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth: 1.5];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.3) * squareWidth,
                                                       (x2 + 0.5) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.7) * squareWidth,
                                                       (x2 + 0.5) * squareWidth)];
    }else if ([connectionElement isConnected: CD2DSideTopRight]) {
        [[NSColor whiteColor] set];
        [NSBezierPath setDefaultLineWidth: 10];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.3) * squareWidth,
                                                       (x2 + 0.3) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.7) * squareWidth,
                                                       (x2 + 0.7) * squareWidth)];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth: 1.5];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.3) * squareWidth,
                                                       (x2 + 0.3) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.7) * squareWidth,
                                                       (x2 + 0.7) * squareWidth)];
    }else if ([connectionElement isConnected: CD2DSideTop]) {
        [[NSColor whiteColor] set];
        [NSBezierPath setDefaultLineWidth: 10];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                                       (x2 + 0.3) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                                       (x2 + 0.7) * squareWidth)];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth: 1.5];
        [NSBezierPath strokeLineFromPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                                       (x2 + 0.3) * squareWidth)
                                  toPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                                       (x2 + 0.7) * squareWidth)];
    }
}

- (void)drawDiode: (CDDiode *)diode{
    CGFloat squareWidth = [self squareWidth];
    
    NSUInteger x1 = diode.coordinate.x1;
    NSUInteger x2 = diode.coordinate.x2;
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    
    NSBezierPath *baseLine = [[NSBezierPath alloc] init];
    NSBezierPath *triangle = [[NSBezierPath alloc] init];
    NSBezierPath *limitLine = [[NSBezierPath alloc] init];
    
    if ([diode hasConnectionToSide: CD2DSideRight]) {
        [baseLine moveToPoint: NSMakePoint(x1 * squareWidth,
                                           (x2 + 0.5) * squareWidth)];
        [baseLine lineToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                           (x2 + 0.5) * squareWidth)];
        
        if (diode.anode == CD2DSideLeft) {
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(0.0 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(0.0 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(-0.25 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(-0.25 * M_PI)))];
        }else{
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(-0.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(-0.25 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(1 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(1 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
        }
    }else if ([diode hasConnectionToSide: CD2DSideTopRight]) {
        [baseLine moveToPoint: NSMakePoint(x1 * squareWidth,
                                           x2 * squareWidth)];
        [baseLine lineToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                           (x2 + 1) * squareWidth)];
        
        if (diode.anode == CD2DSideBottomLeft) {
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(0.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(0.25 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
        }else{
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(1.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(1.25 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
        }
    }else if ([diode hasConnectionToSide: CD2DSideTop]) {
        [baseLine moveToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                           x2 * squareWidth)];
        [baseLine lineToPoint: NSMakePoint((x1 + 0.5) * squareWidth,
                                           (x2 + 1) * squareWidth)];
        
        if (diode.anode == CD2DSideBottom) {
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.75 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.75 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(0.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(0.5 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
        }else{
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.25 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.75 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.75 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(-0.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(-0.5 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.75 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.75 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.25 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.25 * M_PI)))];
        }
    }else if ([diode hasConnectionToSide: CD2DSideTopLeft]) {
        [baseLine moveToPoint: NSMakePoint(x1 * squareWidth,
                                           (x2 + 1) * squareWidth)];
        [baseLine lineToPoint: NSMakePoint((x1 + 1) * squareWidth,
                                           x2 * squareWidth)];
        
        if (diode.anode == CD2DSideBottomRight) {
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.5 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(0.75 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(0.75 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1.0 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1.0 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
        }else{
            [triangle moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.5 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.5 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(1 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(1 * M_PI)))];
            [triangle lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.212 * cos(-0.25 * M_PI)),
                                               ((x2 + 0.5) * squareWidth) + (squareWidth* 0.212 * sin(-0.25 * M_PI)))];
            
            [limitLine moveToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(0.0 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(0.0 * M_PI)))];
            [limitLine lineToPoint: NSMakePoint(((x1 + 0.5) * squareWidth) + (squareWidth * 0.3 * cos(-0.5 * M_PI)),
                                                ((x2 + 0.5) * squareWidth) + (squareWidth* 0.3 * sin(-0.5 * M_PI)))];
        }
    }
    
    [baseLine stroke];
    [triangle fill];
    [limitLine stroke];
}
                       
- (void)drawSelectionInRect: (NSRect)dirtyRect{
    CGFloat squareWidth = [self squareWidth];
    
    NSUInteger minColumn = floor(NSMinX(dirtyRect) / squareWidth);
    NSUInteger maxColumn = ceil(NSMaxX(dirtyRect) / squareWidth) + 1;
    NSUInteger minRow = floor(NSMinY(dirtyRect) / squareWidth);
    NSUInteger maxRow = ceil(NSMaxY(dirtyRect) / squareWidth) + 1;
    
    if (minColumn > 0) minColumn--;
    if (minRow > 0) minRow--;
    if (maxRow >= [self gridSize].height) maxRow = [self gridSize].height - 1;
    if (maxColumn >= [self gridSize].width) maxColumn = [self gridSize].width - 1;
    
    [NSBezierPath setDefaultLineWidth: 2.0];
    [NSBezierPath setDefaultLineCapStyle: NSSquareLineCapStyle];
    
    for (NSUInteger c = minColumn; c <= maxColumn; c++) {
        for (NSUInteger r = minRow; r <= maxRow; r++) {
            if ([self isCoordinateInSelection: make2DCoordinate(c, r)]) {
                [[NSColor colorWithRed:0 green:0 blue:1 alpha:0.08] set];
                [NSBezierPath fillRect: NSMakeRect(c * squareWidth,
                                                   r * squareWidth,
                                                   squareWidth,
                                                   squareWidth)];
            }
            
            CD2DSides sides = [self sidesWithSelectionBoundsForCoordinate: make2DCoordinate(c, r)];
            
            [[NSColor blueColor] set];
            if (sides & CD2DSideLeft) {
                [NSBezierPath strokeLineFromPoint: NSMakePoint(c * squareWidth,
                                                               r * squareWidth)
                                          toPoint:NSMakePoint(c * squareWidth,
                                                              (r + 1) * squareWidth)];
            }
            if (sides & CD2DSideTop) {
                [NSBezierPath strokeLineFromPoint: NSMakePoint(c * squareWidth,
                                                               (r + 1) * squareWidth)
                                          toPoint:NSMakePoint((c + 1) * squareWidth,
                                                              (r + 1) * squareWidth)];
            }
            if (sides & CD2DSideRight) {
                [NSBezierPath strokeLineFromPoint: NSMakePoint((c + 1) * squareWidth,
                                                               (r + 1) * squareWidth)
                                          toPoint:NSMakePoint((c + 1) * squareWidth,
                                                              r * squareWidth)];
            }
            if (sides & CD2DSideBottom) {
                [NSBezierPath strokeLineFromPoint: NSMakePoint((c + 1) * squareWidth,
                                                               r * squareWidth)
                                          toPoint:NSMakePoint(c * squareWidth,
                                                              r * squareWidth)];
            }
        }
    }
}

- (void) drawDragginDestinationInRect: (NSRect)dirtyRect{
    if (isNotFound2DRectangle(draggingRect)) return;
    
    CGFloat squareWidth = [self squareWidth];
    
    [[NSColor blueColor] set];
    [NSBezierPath setDefaultLineWidth: 3.0];
    NSBezierPath *path =
     [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(draggingRect.startCoordinate.x1 * squareWidth,
                                                         draggingRect.startCoordinate.x2 * squareWidth,
                                                         (draggingRect.endCoordinate.x1
                                                          - draggingRect.startCoordinate.x1 + 1)
                                                         * squareWidth,
                                                         (draggingRect.endCoordinate.x2
                                                          - draggingRect.startCoordinate.x2 + 1)
                                                         * squareWidth)
                                    xRadius: 3
                                    yRadius: 3];
    [path stroke];
}

@end
