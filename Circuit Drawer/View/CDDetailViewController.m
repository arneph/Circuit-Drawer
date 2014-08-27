//
//  CDDetailViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 02.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDDetailViewController.h"
#import "CDConnectionElementDetailViewController.h"
#import "CDDiodeDetailViewController.h"

@interface CDDetailViewController ()

@property IBOutlet NSScrollView *scrollView;
@property IBOutlet NSTextField *notApplicabelLabel;

@end

@implementation CDDetailViewController{
    CDConnectionElementDetailViewController *connectionElementDetailViewController;
    CDDiodeDetailViewController *diodeDetailViewController;
    
    NSView *documentView;
}

@synthesize circuitPanel = _circuitPanel;
@synthesize undoManager = _undoManager;

- (void)awakeFromNib{
    documentView = _scrollView.documentView;
}

- (CDCircuitPanel *)circuitPanel{
    return _circuitPanel;
}

- (void)setCircuitPanel:(CDCircuitPanel *)circuitPanel{
    if (circuitPanel == _circuitPanel) return;
    
    _circuitPanel = circuitPanel;
    
    connectionElementDetailViewController.circuitPanel = _circuitPanel;
}

- (NSUndoManager *)undoManager{
    return _undoManager;
}

- (void)setUndoManager:(NSUndoManager *)undoManager{
    if (undoManager == _undoManager) return;
    
    _undoManager = undoManager;
    
    connectionElementDetailViewController.undoManager = _undoManager;
}

- (void)setDocumentView: (NSView *)view{
    documentView = view;
    [documentView setFrameSize: NSMakeSize(NSWidth(_scrollView.bounds),
                                           NSHeight(documentView.frame))];
    
    [_scrollView setDocumentView: documentView];
}

- (void)showDetailsForCircuitObjects: (NSArray *)objects{
    if (objects.count == 0) {
        [self showNotApplicable];
    }else{
        [_notApplicabelLabel setHidden: YES];
        if ([objects.firstObject isKindOfClass: [CDConnectionElement class]]) {
            if (!connectionElementDetailViewController) {
                connectionElementDetailViewController
                = [CDConnectionElementDetailViewController connectionElementDetailViewController];
                
                connectionElementDetailViewController.circuitPanel = _circuitPanel;
                connectionElementDetailViewController.undoManager = _undoManager;
            }
            
            connectionElementDetailViewController.connectionElements = objects;
            [self setDocumentView: connectionElementDetailViewController.view];
        }else if ([objects.firstObject isKindOfClass: [CDDiode class]]) {
            if (!diodeDetailViewController) {
                diodeDetailViewController
                = [CDDiodeDetailViewController diodeDetailViewController];
                
                diodeDetailViewController.circuitPanel = _circuitPanel;
                diodeDetailViewController.undoManager = _undoManager;
            }
            
            diodeDetailViewController.diodes = objects;
            [self setDocumentView: diodeDetailViewController.view];
        }else{
            [self showNotApplicable];
        }
    }
}

- (void)showNotApplicable{
    [_scrollView setDocumentView: [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 200, 400)]];
    [_notApplicabelLabel setHidden: NO];
}

- (NSView *)currentView{
    return documentView;
}

@end
