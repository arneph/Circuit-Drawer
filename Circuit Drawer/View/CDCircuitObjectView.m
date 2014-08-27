//
//  CDCircuitObjectView.m
//  Circuit Drawer
//
//  Created by Programmieren on 23.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDCircuitObjectView.h"
#import "CD2DArray.h"
#import "CDCircuitObject.h"
#import "CDDiode.h"

#define CDCircuitObjectsDragType @"de.AP-Software.CircuitDrawer.CDCircuitObjectsDragType"

static NSImage *diodeImage;

@implementation CDCircuitObjectView
@synthesize circuitObjectClass = _circuitObjectClass;

+ (void)initialize{
    diodeImage = [NSImage imageNamed: @"Diode"];
}

- (void)awakeFromNib{
    _circuitObjectClass = [CDDiode class];
}

- (Class)circuitObjectClass{
    return _circuitObjectClass;
}

- (void)setCircuitObjectClass: (Class)circuitObjectClass{
    _circuitObjectClass = circuitObjectClass;
    [self setNeedsDisplay: YES];
}

- (NSDragOperation)draggingSession: (NSDraggingSession *)session sourceOperationMaskForDraggingContext: (NSDraggingContext)context{
    if (context == NSDraggingContextWithinApplication) {
        return NSDragOperationMove | NSDragOperationCopy;
    }else{
        return NSDragOperationNone;
    }
}

- (BOOL)acceptsFirstMouse: (NSEvent *)theEvent{
    return YES;
}

- (void)mouseDragged:(NSEvent *)theEvent{
    if (_circuitObjectClass == NULL) return;
    
    CD2DArray *array = [[CD2DArray alloc] init2DArrayWithX1Count: 1
                                                         x2Count: 1
                                                          object: [[_circuitObjectClass alloc] init]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: array];
    
    NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect: self.bounds];
    NSImage *image = [[NSImage alloc] init];
    
    [self cacheDisplayInRect: self.bounds toBitmapImageRep: imageRep];
    [image addRepresentation: imageRep];
    
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    [pboardItem setData: data
                forType: CDCircuitObjectsDragType];
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter: pboardItem];
    [draggingItem setDraggingFrame: self.bounds
                          contents: image];
    
    NSDraggingSession *session = [self beginDraggingSessionWithItems: @[draggingItem]
                                                               event: theEvent
                                                              source: self];
    session.animatesToStartingPositionsOnCancelOrFail = YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [[NSBezierPath bezierPathWithRoundedRect: NSInsetRect(self.bounds, 1, 1)
                                     xRadius: 3
                                     yRadius: 3] fill];
    
    [[NSColor darkGrayColor] set];
    [NSBezierPath setDefaultLineWidth: 1];
    [[NSBezierPath bezierPathWithRoundedRect: NSInsetRect(self.bounds, 1, 1)
                                     xRadius: 3
                                     yRadius: 3] stroke];
    
    [NSBezierPath setDefaultLineWidth: 1.0];
    if (_circuitObjectClass == [CDDiode class]) {
        [self drawDiode];
    }
}

- (void)drawDiode{
    CGFloat squareWidth = NSWidth(self.bounds);
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 1.5];
    
    [NSBezierPath strokeLineFromPoint: NSMakePoint(0.1 * squareWidth,
                                                   0.5 * squareWidth)
                              toPoint: NSMakePoint(0.9 * squareWidth,
                                                   0.5 * squareWidth)];
    NSBezierPath *trianglePath = [[NSBezierPath alloc] init];
    [trianglePath moveToPoint: NSMakePoint(0.3 * squareWidth,
                                           0.7 * squareWidth)];
    [trianglePath lineToPoint: NSMakePoint(0.3 * squareWidth,
                                           0.3 * squareWidth)];
    [trianglePath lineToPoint: NSMakePoint(0.7 * squareWidth,
                                           0.5 * squareWidth)];
    [trianglePath fill];
    
    [NSBezierPath strokeLineFromPoint: NSMakePoint(0.7 * squareWidth,
                                                   0.3 * squareWidth)
                              toPoint: NSMakePoint(0.7 * squareWidth,
                                                   0.7 * squareWidth)];
}

@end
