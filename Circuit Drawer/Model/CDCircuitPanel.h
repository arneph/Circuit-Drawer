//
//  CDCircuitPanel.h
//  Circuit Drawer
//
//  Created by Programmieren on 28.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CD2DBaseTypes.h"
#import "CD2DArray.h"
#import "CDCircuitObject.h"
#import "CDConnectionElement.h"
#import "CDDiode.h"

#define CDCircuitPanelArrayChangedNotification @"CDCircuitPanelArrayChangedNotification"
#define CDCircuitPanelCircuitObjectChangedNotification @"CDCircuitPanelCircuitObjectChangedNotification"

@interface CDCircuitPanel : NSObject <NSCoding, NSCopying>

@property (readonly) CDMutable2DArray *array;

- (instancetype)initWithCircuitPanel: (CDCircuitPanel *)cp;

@end
