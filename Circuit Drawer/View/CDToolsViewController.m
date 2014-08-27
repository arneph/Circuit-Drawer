//
//  CDToolsViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 21.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDToolsViewController.h"

@interface CDToolsViewController ()

@property IBOutlet NSButton *pointerToolButton;
@property IBOutlet NSButton *connectionPenToolButton;

@end

@implementation CDToolsViewController
@synthesize editorViewController = _editorViewController;

- (CDEditorViewController *)editorViewController{
    return _editorViewController;
}

- (void)setEditorViewController:(CDEditorViewController *)editorViewController{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: CDEditorViewActiveToolDidChangeNotification
                                                  object: _editorViewController.view];
    
    _editorViewController = editorViewController;
    
    if (_editorViewController && _editorViewController.view) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(editorViewActiveToolDidChange:)
                                                     name: CDEditorViewActiveToolDidChangeNotification
                                                   object: _editorViewController.editorView];
    }
}

- (void)editorViewActiveToolDidChange: (NSNotification *)notification{
    [self update];
}

- (void)update{
    _pointerToolButton.state = (_editorViewController.editorView.activeTool == CDEditorViewToolPointer);
    _connectionPenToolButton.state = (_editorViewController.editorView.activeTool == CDEditorViewToolConnectionPen);
}

@end
