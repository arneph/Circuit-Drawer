//
//  CDDiodeDetailViewController.h
//  Circuit Drawer
//
//  Created by Programmieren on 25.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDDiode.h"
#import "CDCircuitPanel.h"

@interface CDDiodeDetailViewController : NSViewController

@property CDCircuitPanel *circuitPanel;
@property NSArray *diodes;

@property NSUndoManager *undoManager;

+ (CDDiodeDetailViewController *)diodeDetailViewController;

@end
