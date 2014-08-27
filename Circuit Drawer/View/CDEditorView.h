//
//  CDEditorView.h
//  Circuit Drawer
//
//  Created by Programmieren on 27.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CD2DBaseTypes.h"
#import "CD2DArray.h"

#define CDCircuitObjectsPboardType @"de.AP-Software.CircuitDrawer.CDCircuitObjectsPboardType"
#define CDCircuitObjectsDragType @"de.AP-Software.CircuitDrawer.CDCircuitObjectsDragType"

#define CDEditorViewSelectionDidChangeNotification @"CDEditorViewSelectionDidChangeNotification"
#define CDEditorViewActiveToolDidChangeNotification @"CDEditorViewActiveToolDidChangeNotification"

typedef enum{
    CDEditorViewToolPointer,
    CDEditorViewToolConnectionPen,
    CDEditorViewToolEraser
}CDEditorViewTool;

@class CDEditorView;

@protocol CDEditorViewDataSource <NSObject>

- (CD2DArray *)arrayForEditorView: (CDEditorView *)editorView;

- (void)editorView: (CDEditorView *)editorView
drewConnectionFrom: (CD2DCoordinate)c1
                to: (CD2DCoordinate)c2
      onlyCrossing: (BOOL)flag;

- (void)editorView: (CDEditorView *)editorView
              drag: (NSDraggingSession *)session
originatedInSelectionOperation: (NSDragOperation)operation;
- (void)editorView: (CDEditorView *)editorView
              drag: (id<NSDraggingInfo>)info
     endedIn2DRect: (CD2DRectangle)rect
         operation: (NSDragOperation)operation;

@end

@protocol CDEditorViewDelegate <NSObject>

@optional
- (void)editorViewSelectionDidChange: (NSNotification *)notification;
- (void)editorViewActiveToolDidChange: (NSNotification *)notification;

@end

@interface CDEditorView : NSView <NSDraggingSource, NSDraggingDestination>

@property (weak) IBOutlet id<CDEditorViewDataSource> dataSource;
@property (weak) IBOutlet id<CDEditorViewDelegate> delegate;

@property BOOL allowsEditing;

@property (getter = showsGrid) BOOL showGrid;
@property CDEditorViewTool activeTool;

- (void)reloadData;
- (void)reloadDataFor2DCoordinate: (CD2DCoordinate)coordinate;
- (void)reloadDataFor2DRectangle: (CD2DRectangle)rectangle;

- (BOOL)hasSelection;
- (BOOL)isCoordinateInSelection: (CD2DCoordinate)coordinate;
- (CD2DRectangle)rectangleIncludingSelection;

- (NSArray *)selectedObjects;
- (CD2DSides)sidesWithSelectionBoundsForCoordinate: (CD2DCoordinate)coordinate;

- (void)addCoordinatesInRectangleToSelection: (CD2DRectangle)rectangle;
- (void)removeCoodinatesInRectangleFromSelection: (CD2DRectangle)rectangle;

- (IBAction)toogleGrid: (id)sender;
- (IBAction)usePointerTool: (id)sender;
- (IBAction)useConnectionPenTool: (id)sender;

@end
