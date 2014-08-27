//
//  CDDiodeDetailViewController.m
//  Circuit Drawer
//
//  Created by Programmieren on 25.08.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDDiodeDetailViewController.h"

@interface CDDiodesView : NSView

@property NSArray * diodes;

@end

@interface CDDiodeDetailViewController ()

@property IBOutlet NSTextField *x1Label;
@property IBOutlet NSTextField *x2Label;

@property IBOutlet CDDiodesView *diodesView;

@end

@implementation CDDiodeDetailViewController
@synthesize diodes = _diodes;

#pragma mark Life cycle

+ (CDDiodeDetailViewController *)diodeDetailViewController{
    return [[CDDiodeDetailViewController alloc] initWithNibName: @"CDDiodeDetailView"
                                                         bundle: [NSBundle mainBundle]];
}

- (void)awakeFromNib{
    _diodesView.diodes = _diodes;
    
    [self updateUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark Updating

- (void)updateUI{
    if (_diodes.count == 1) {
        [_x1Label setStringValue: @(((CDDiode *)_diodes[0]).coordinate.x1).stringValue];
        [_x2Label setStringValue: @(((CDDiode *)_diodes[0]).coordinate.x2).stringValue];
        
    }else{
        [_x1Label setStringValue: @"Multiple"];
        [_x2Label setStringValue: @"Multiple"];
    }
}

#pragma mark Properties

- (NSArray *)diodes{
    return _diodes;
}

- (void)setDiodes: (NSArray *)diodes{
    _diodes = diodes;
    
    [self updateUI];
    
    _diodesView.diodes = _diodes;
}

@end

@implementation CDDiodesView

- (BOOL)isOpaque{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect: dirtyRect];
    
    CGFloat squareWidth = 96;
        
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth: 3];
    [NSBezierPath strokeRect: self.bounds];
}
    
@end
