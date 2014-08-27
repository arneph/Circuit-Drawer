//
//  CDCircuitObjectView.h
//  Circuit Drawer
//
//  Created by Programmieren on 23.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CD2DBaseTypes.h"
#import "CDCircuitObject.h"

@interface CDCircuitObjectView : NSView <NSDraggingSource>

@property Class circuitObjectClass;

@end
