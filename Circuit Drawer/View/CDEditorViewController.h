//
//  CDEditorViewController.h
//  Circuit Drawer
//
//  Created by Programmieren on 20.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDCircuitPanel.h"
#import "CDEditorView.h"
#import "CDDetailViewController.h"

@interface CDEditorViewController : NSViewController <CDEditorViewDataSource, CDEditorViewDelegate>

@property (getter = view, setter = setView:) CDEditorView *editorView;

@property CDCircuitPanel *circuitPanel;

@property BOOL allowsEditing;
@property NSUndoManager *undoManager;

@property IBOutlet CDDetailViewController *detailViewController;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet NSClipView *clipView;

@end
