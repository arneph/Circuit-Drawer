//
//  CD2DArray.h
//  Circuit Drawer
//
//  Created by Programmieren on 28.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CD2DBaseTypes.h"

@interface CD2DArray : NSObject <NSCoding, NSCopying>

- (instancetype)init2DArrayWith2DArray: (CD2DArray *)array;
- (instancetype)init2DArrayWithDeepCopied2DArray: (CD2DArray *)array;
- (instancetype)init2DArrayWithX1Count: (NSUInteger)x1Count
                               x2Count: (NSUInteger)x2Count
                                object: (NSObject <NSCoding, NSCopying>*)object;

- (id)deepCopy;

- (NSUInteger)totalCount;
- (NSUInteger)x1Count;
- (NSUInteger)x2Count;

- (NSObject <NSCoding, NSCopying>*)objectAtCoordinate: (CD2DCoordinate)coordinate;
- (NSObject <NSCoding, NSCopying>*)objectAtX1: (NSUInteger)x1 x2: (NSUInteger)x2;

- (NSArray *)objectsAtX1: (NSUInteger)x1;
- (NSArray *)objectsAtX2: (NSUInteger)x2;
- (CD2DArray *)sub2DArrayFromCoordinate: (CD2DCoordinate)startCoordinate
                           toCoordinate: (CD2DCoordinate)endCoordinate;

- (BOOL)containsObject: (NSObject <NSCoding, NSCopying>*)object;

- (NSUInteger)getX1OfObject: (NSObject <NSCoding, NSCopying>*)object;
- (NSUInteger)getX2OfObject: (NSObject <NSCoding, NSCopying>*)object;
- (CD2DCoordinate)getCoordinateOfObject: (NSObject <NSCoding, NSCopying>*)object;

- (void)enumerateObjectsUsingBlock: (void (^)(NSObject <NSCoding, NSCopying>* obj,
                                              CD2DCoordinate coord,
                                              BOOL *stop))block;

@end

#define CDMutable2DArrayChangedNotification  @"CDMutable2DArrayChangedNotification"

@interface CDMutable2DArray : CD2DArray <NSCoding, NSCopying>

- (void)setX1Count: (NSUInteger)x1Count
           x2Count: (NSUInteger)x2Count
       placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder;
- (void)setX1Count: (NSUInteger)x1Count placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder;
- (void)setX2Count: (NSUInteger)x2Count placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder;

- (void)setObject: (NSObject <NSCoding, NSCopying>*)object atCoordinate: (CD2DCoordinate)cooridnate;
- (void)setObject: (NSObject <NSCoding, NSCopying>*)object atX1: (NSUInteger)x1 x2: (NSUInteger)x2;

- (void)setObjects: (NSArray *)objects atX1: (NSUInteger)x1;
- (void)setObjects: (NSArray *)objects atX2: (NSUInteger)x2;
- (void)replaceObjectsBeginningFrom: (CD2DCoordinate)startCoordinate
             withObjectsFrom2DArray: (CD2DArray *)array;

- (void)replaceObjectsInArrayWithObjectsFrom2DArray: (CD2DArray *)array;

- (void)removeObjectsAtX1: (NSUInteger)x1;
- (void)removeObjectsAtX2: (NSUInteger)x2;

- (void)insertObjects: (NSArray *)array atX1: (NSUInteger)x1;
- (void)insertObjects: (NSArray *)array atX2: (NSUInteger)x2;

@end
