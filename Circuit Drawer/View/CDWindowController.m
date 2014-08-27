//
//  CDWindowController.m
//  Circuit Drawer
//
//  Created by Programmieren on 08.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDWindowController.h"

@interface CDWindowController ()

@end

@implementation CDWindowController{
    CGFloat oldDetailViewWidth;
}

- (id)init{
    self = [super initWithWindowNibName: @"CDDocumentWindow"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad{
    [super windowDidLoad];
    
    _detailViewController.view.nextResponder = _editorViewController.view;
    oldDetailViewWidth = 300.0;
    
    [self.document windowControllerDidLoadNib: self];
}

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame{
    CGFloat optimalWidth = 0;
    CGFloat optimalHeight = 0;
    
    optimalWidth += NSWidth(_editorViewController.view.frame);
    if (![_splitView isSubviewCollapsed: _toolsViewController.scrollView]) {
        optimalWidth += _splitView.dividerThickness;
        optimalWidth += NSWidth(_toolsViewController.view.bounds);
    }
    if (![_splitView isSubviewCollapsed: _detailViewController.view]) {
        optimalWidth += _splitView.dividerThickness;
        optimalWidth += NSWidth(_detailViewController.view.frame);
    }
    
    optimalHeight = NSHeight(_editorViewController.view.bounds);
    
    if (optimalHeight < NSHeight(_detailViewController.currentView.frame)) {
        optimalHeight = NSHeight(_detailViewController.currentView.frame);
    }
    
    if (self.window.toolbar.isVisible) {
        optimalHeight += NSHeight(self.window.frame) - NSHeight([self.window.contentView bounds]);
    }
    
    NSPoint origin = NSMakePoint(-1, -1);
    NSSize size = NSMakeSize(0, 0);
    
    if (optimalWidth > NSWidth(newFrame)) {
        origin.x = NSMinX(newFrame);
        size.width = NSWidth(newFrame);
    }else{
        origin.x = (NSInteger)(NSMinX(self.window.frame) - ((optimalWidth - NSWidth(self.window.frame)) / 2));
        size.width = optimalWidth;
    }
    if (optimalHeight >= NSHeight(newFrame)) {
        origin.y = NSMinY(newFrame);
        size.height = NSHeight(newFrame);
    }else{
        origin.y = (NSInteger)NSMinY(self.window.frame) - ((optimalHeight - NSHeight(self.window.frame)) / 2);
        size.height = optimalHeight;
    }
    
    return NSMakeRect(origin.x,
                      origin.y,
                      size.width, size.height);
}

- (void)toggleToolboxView:(id)sender{
    if ([_splitView isSubviewCollapsed: _toolsViewController.scrollView]) {
        [_splitView setPosition: 60.0
               ofDividerAtIndex: 0];
    }else{
        [_splitView setPosition: 0.0
               ofDividerAtIndex: 0];
    }
}

- (void)toggleDetailView:(id)sender{
    if ([_splitView isSubviewCollapsed: _detailViewController.view]) {
        [_splitView setPosition: NSWidth(_splitView.bounds)
                                 - oldDetailViewWidth
                                 - _splitView.dividerThickness
               ofDividerAtIndex: 1];
    }else{
        oldDetailViewWidth = NSWidth(_detailViewController.view.bounds);
        [_splitView setPosition: NSWidth(_splitView.bounds) + 10
               ofDividerAtIndex: 1];
    }
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize{
    oldDetailViewWidth = NSWidth(_detailViewController.view.bounds);
    
    [_splitView adjustSubviews];
    if (![_splitView isSubviewCollapsed: _toolsViewController.scrollView]) {
        [_splitView setPosition: 60.0
               ofDividerAtIndex: 0];
    }
    if (![_splitView isSubviewCollapsed: _detailViewController.view]) {
        [_splitView setPosition: NSWidth(_splitView.bounds)
                                 - oldDetailViewWidth
                                 - _splitView.dividerThickness
               ofDividerAtIndex: 1];
    }
}

- (BOOL)splitView: (NSSplitView *)splitView canCollapseSubview: (NSView *)subview{
    if (subview == _toolsViewController.scrollView) {
        return YES;
    }else if (subview == _detailViewController.view) {
        return YES;
    }
    return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex{
    return YES;
}

- (CGFloat)splitView: (NSSplitView *)splitView constrainMinCoordinate: (CGFloat)proposedMinimumPosition
         ofSubviewAt: (NSInteger)dividerIndex{
    if (dividerIndex == 0) {
        return 60.0;
    }else if (dividerIndex == 1) {
        if (NSWidth(_splitView.bounds) - 350.0 - _splitView.dividerThickness > 659.0) {
            return NSWidth(_splitView.bounds) - 350.0 - _splitView.dividerThickness;
        }else{
            return 659.0;
        }
    }else{
        return proposedMinimumPosition;
    }
}

- (CGFloat)splitView: (NSSplitView *)splitView constrainMaxCoordinate: (CGFloat)proposedMaximumPosition
         ofSubviewAt: (NSInteger)dividerIndex{
    if (dividerIndex == 0) {
        return 60.0;
    }else if (dividerIndex == 1) {
        return NSWidth(_splitView.bounds) - 200.0 - _splitView.dividerThickness;
    }else{
        return proposedMaximumPosition;
    }
}

@end
