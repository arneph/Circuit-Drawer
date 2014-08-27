//
//  CDDocument.h
//  Circuit Drawer
//
//  Created by Programmieren on 27.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDCircuitPanel.h"
#import "CDWindowController.h"

@interface CDDocument : NSDocument

@property (readonly) CDCircuitPanel *circuitPanel;

@end
