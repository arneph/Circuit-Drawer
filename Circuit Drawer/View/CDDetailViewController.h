//
//  CDDetailViewController.h
//  Circuit Drawer
//
//  Created by Programmieren on 02.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CD2DBaseTypes.h"
#import "CDCircuitObject.h"
#import "CDConnectionElement.h"
#import "CDCircuitPanel.h"

@interface CDDetailViewController : NSViewController

@property CDCircuitPanel *circuitPanel;

@property NSUndoManager *undoManager;

- (void)showDetailsForCircuitObjects: (NSArray *)objects;
- (void)showNotApplicable;

- (NSView *)currentView;

@end
