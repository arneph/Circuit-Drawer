//
//  CDEditorClipView.m
//  Circuit Drawer
//
//  Created by Programmieren on 28.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CDEditorClipView.h"

@implementation CDEditorClipView

- (NSRect)constrainBoundsRect:(NSRect)proposedClipViewBoundsRect {
    NSRect constrainedClipViewBoundsRect;
    NSRect documentViewFrameRect = [self.documentView frame];
    
    constrainedClipViewBoundsRect = [super constrainBoundsRect:proposedClipViewBoundsRect];
    
    if (proposedClipViewBoundsRect.size.width >= documentViewFrameRect.size.width) {
        constrainedClipViewBoundsRect.origin.x = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedClipViewBoundsRect.size.width, documentViewFrameRect.size.width);
    }
    
    if (proposedClipViewBoundsRect.size.height >= documentViewFrameRect.size.height) {
        constrainedClipViewBoundsRect.origin.y = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedClipViewBoundsRect.size.height, documentViewFrameRect.size.height);
    }
    
    return constrainedClipViewBoundsRect;
}

CGFloat centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(CGFloat proposedContentViewBoundsDimension,
                                                                                                  CGFloat documentViewFrameDimension) {
    CGFloat result = floor( (proposedContentViewBoundsDimension - documentViewFrameDimension) / -2.0F );
    return result;
}

@end
