//
//  CDDocument.m
//  Circuit Drawer
//
//  Created by Programmieren on 27.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDDocument.h"

@implementation CDDocument

- (id)init{
    self = [super init];
    if (self) {
        _circuitPanel = [[CDCircuitPanel alloc] init];
    }
    return self;
}

- (void)makeWindowControllers{
    CDWindowController *windowController = [[CDWindowController alloc] init];
    [self addWindowController: windowController];
}

- (void)windowControllerDidLoadNib: (CDWindowController *)controller{
    [super windowControllerDidLoadNib: controller];
    
    controller.editorViewController.circuitPanel = _circuitPanel;
    controller.editorViewController.allowsEditing = !self.isInViewingMode;
    controller.editorViewController.undoManager = self.undoManager;
    
    controller.detailViewController.circuitPanel = _circuitPanel;
    controller.detailViewController.undoManager = self.undoManager;
}

+ (BOOL)autosavesInPlace{
    return YES;
}

+ (BOOL)preservesVersions{
    return YES;
}

- (NSData *)dataOfType: (NSString *)typeName error: (NSError **)outError{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: _circuitPanel];
    return data;
}

- (BOOL)readFromData: (NSData *)data ofType: (NSString *)typeName error: (NSError **)outError{
    _circuitPanel = [NSKeyedUnarchiver unarchiveObjectWithData: data];
    return YES;
}

@end
