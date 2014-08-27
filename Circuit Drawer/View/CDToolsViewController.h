//
//  CDToolsViewController.h
//  Circuit Drawer
//
//  Created by Programmieren on 21.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDEditorViewController.h"

@interface CDToolsViewController : NSViewController

@property IBOutlet CDEditorViewController *editorViewController;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet NSClipView *clipView;

@end
