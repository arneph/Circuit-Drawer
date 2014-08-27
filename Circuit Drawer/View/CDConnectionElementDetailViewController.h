//
//  CDConnectionElementDetailViewController.h
//  Circuit Drawer
//
//  Created by Programmieren on 02.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDConnectionElement.h"
#import "CDCircuitPanel.h"

@interface CDConnectionElementDetailViewController : NSViewController

@property CDCircuitPanel *circuitPanel;
@property NSArray *connectionElements;

@property NSUndoManager *undoManager;

+ (CDConnectionElementDetailViewController *)connectionElementDetailViewController;

@end
