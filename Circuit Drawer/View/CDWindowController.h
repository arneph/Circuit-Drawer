//
//  CDWindowController.h
//  Circuit Drawer
//
//  Created by Programmieren on 08.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDToolsViewController.h"
#import "CDEditorViewController.h"
#import "CDDetailViewController.h"

@interface CDWindowController : NSWindowController <NSWindowDelegate, NSSplitViewDelegate>

@property IBOutlet NSSplitView *splitView;
@property IBOutlet CDToolsViewController *toolsViewController;
@property IBOutlet CDEditorViewController *editorViewController;
@property IBOutlet CDDetailViewController *detailViewController;

- (IBAction)toggleToolboxView: (id)sender;
- (IBAction)toggleDetailView: (id)sender;

@end
