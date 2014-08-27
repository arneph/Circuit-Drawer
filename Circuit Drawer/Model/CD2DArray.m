//
//  CD2DArray.m
//  Circuit Drawer
//
//  Created by Programmieren on 28.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CD2DArray.h"

@interface CD2DArray ()

- (NSMutableArray*)_array;
- (void)_setArray: (NSMutableArray *)a;

- (void)_setX1Count: (NSUInteger)c;
- (void)_setX2Count: (NSUInteger)c;

- (BOOL)validateInternalCoordinate: (CD2DCoordinate)coordinate
                 throwingException: (NSString *)exception;
- (BOOL)validateInternalX1: (NSUInteger)x1
                        x2: (NSUInteger)x2
         throwingException: (NSString *)exception;

@end

@implementation CD2DArray{
    NSMutableArray *array;
    NSUInteger x1Count;
    NSUInteger x2Count;
}

#pragma mark Initialisation

- (instancetype)init2DArrayWith2DArray: (CD2DArray *)ar{
    if (!ar) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        x1Count = ar.x1Count;
        x2Count = ar.x2Count;
        array = [[NSMutableArray alloc] initWithCapacity: ar.totalCount];
        
        for (NSUInteger x2 = 0; x2 < x2Count; x2++) {
            for (NSUInteger x1 = 0; x1 < x1Count; x1++) {
                [array addObject: [ar objectAtX1:x1 x2:x2]];
            }
        }
        
    }
    return self;
}

- (instancetype)init2DArrayWithDeepCopied2DArray: (CD2DArray *)ar{
    if (!ar) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        x1Count = ar.x1Count;
        x2Count = ar.x2Count;
        array = [[NSMutableArray alloc] initWithCapacity: ar.totalCount];
        
        for (NSUInteger x2 = 0; x2 < x2Count; x2++) {
            for (NSUInteger x1 = 0; x1 < x1Count; x1++) {
                [array addObject: [ar objectAtX1:x1 x2:x2].copy];
            }
        }
        
    }
    return self;
}

- (instancetype)init2DArrayWithX1Count: (NSUInteger)x1c
                               x2Count: (NSUInteger)x2c
                                object: (NSObject <NSCoding, NSCopying>*)object{
    if (!object) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        x1Count = x1c;
        x2Count = x2c;
        array = [[NSMutableArray alloc] initWithCapacity: x1Count * x2Count];
        
        for (NSUInteger x2 = 0; x2 < x2Count; x2++) {
            for (NSUInteger x1 = 0; x1 < x1Count; x1++) {
                [array addObject: object.copy];
            }
        }
    }
    return self;
}

- (instancetype)init2DArrayWithX1Count: (NSUInteger)x1c
                               x2Count: (NSUInteger)x2c
                               objects: (NSArray *)objects {
    if (!objects || objects.count != x1c * x2c) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super init];
    if (self) {
        x1Count = x1c;
        x2Count = x2c;
        array = objects.copy;
    }
    return self;
}

#pragma mark Coding

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        x1Count = [aDecoder decodeIntegerForKey: @"x1Count"];
        x2Count = [aDecoder decodeIntegerForKey: @"x2Count"];
        array = [[NSMutableArray alloc] initWithArray: [aDecoder decodeObjectForKey: @"array"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger: x1Count forKey: @"x1Count"];
    [aCoder encodeInteger: x2Count forKey: @"x2Count"];
    [aCoder encodeObject: array forKey: @"array"];
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone{
    return [[[self class] alloc] init2DArrayWith2DArray: self];
}

- (id)deepCopy{
    return [[[self class] alloc] init2DArrayWithDeepCopied2DArray: self];
}

#pragma mark Semi-internal Methods

- (NSMutableArray*)_array{
    return array;
}

- (void)_setArray: (NSMutableArray *)a{
    if (!a) {
        @throw NSInvalidArgumentException;
        return;
    }
    array = a;
}

- (void)_setX1Count: (NSUInteger)c{
    x1Count = c;
}

- (void)_setX2Count: (NSUInteger)c{
    x2Count = c;
}

#pragma mark Validation

- (BOOL)validateInternalCoordinate: (CD2DCoordinate)coordinate
                 throwingException: (NSString *)exception{
    if (coordinate.x1 >= 0 && coordinate.x1 < x1Count &&
        coordinate.x2 >= 0 && coordinate.x2 < x2Count) {
        return YES;
    }else{
        if (exception) {
            @throw exception;
        }
        return NO;
    }
}

- (BOOL)validateInternalX1: (NSUInteger)x1
                        x2: (NSUInteger)x2
         throwingException: (NSString *)exception{
    if (x1 < x1Count && x2 < x2Count) {
        return YES;
    }else{
        if (exception) {
            @throw exception;
        }
        return NO;
    }
}

#pragma mark Counting

- (NSUInteger)totalCount{
    return x1Count * x2Count;
}

- (NSUInteger)x1Count{
    return x1Count;
}

- (NSUInteger)x2Count{
    return x2Count;
}

#pragma mark Querrying

- (NSObject <NSCoding, NSCopying>*)objectAtCoordinate: (CD2DCoordinate)coordinate{
    if (![self validateInternalCoordinate:coordinate
                        throwingException:NSInvalidArgumentException]) {
        return nil;
    }
    NSUInteger index = (coordinate.x2 * x1Count) + coordinate.x1;
    
    return array[index];
}

- (NSObject <NSCoding, NSCopying>*)objectAtX1: (NSUInteger)x1 x2: (NSUInteger)x2{
    if (![self validateInternalX1:x1 x2:x2 throwingException:NSInvalidArgumentException]) {
        return nil;
    }
    NSUInteger index = (x2 * x1Count) + x1;
    
    return array[index];
}

- (NSArray *)objectsAtX1: (NSUInteger)x1{
    if (x1 >= x1Count) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:x2Count];
    for (NSUInteger x2 = 0; x2 < x2Count; x2++) {
        NSUInteger index = (x2 * x1Count) + x1;
        
        [objects addObject: array[index]];
    }
    return [NSArray arrayWithArray:objects];
}

- (NSArray *)objectsAtX2: (NSUInteger)x2{
    if (x2 >= x2Count) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    return [array subarrayWithRange: NSMakeRange(x2 * x1Count, x1Count)];
}

- (CD2DArray *)sub2DArrayFromCoordinate: (CD2DCoordinate)startCoordinate
                           toCoordinate: (CD2DCoordinate)endCoordinate{
    if (![self validateInternalCoordinate:startCoordinate
                        throwingException:NSInvalidArgumentException] ||
        ![self validateInternalCoordinate:endCoordinate
                        throwingException: NSInvalidArgumentException]) {
        return nil;
    }
    
    NSUInteger minX1 = (startCoordinate.x1 <= endCoordinate.x1) ? startCoordinate.x1 : endCoordinate.x1;
    NSUInteger maxX1 = (startCoordinate.x1 <= endCoordinate.x1) ? endCoordinate.x1 : startCoordinate.x1;
    NSUInteger minX2 = (startCoordinate.x2 <= endCoordinate.x2) ? startCoordinate.x2 : endCoordinate.x2;
    NSUInteger maxX2 = (startCoordinate.x2 <= endCoordinate.x2) ? endCoordinate.x2 : startCoordinate.x2;
    
    NSUInteger x1c = maxX1 - minX1 + 1;
    NSUInteger x2c = maxX2 - minX2 + 1;
    
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity: x1c * x2c];
    for (NSUInteger x2 = minX2; x2 <= maxX2; x2++) {
        for (NSUInteger x1 = minX1; x1 <= maxX1; x1++) {
            NSUInteger index = (x2 * x1Count) + x1;
            [objects addObject: array[index]];
        }
    }
    
    CD2DArray *subArray = [[CD2DArray alloc] init2DArrayWithX1Count:x1c
                                                            x2Count:x2c
                                                            objects:objects];
    return subArray;
}

- (BOOL)containsObject: (NSObject <NSCoding, NSCopying>*)object{
    return [array containsObject: object];
}

- (NSUInteger)getX1OfObject: (NSObject <NSCoding, NSCopying>*)object{
    NSUInteger index = [array indexOfObject: object];
    if (index == NSNotFound) {
        return NSNotFound;
    }
    
    NSUInteger x1 = index % x1Count;
    return x1;
}

- (NSUInteger)getX2OfObject: (NSObject <NSCoding, NSCopying>*)object{
    NSUInteger index = [array indexOfObject: object];
    if (index == NSNotFound) {
        return NSNotFound;
    }
    
    NSUInteger x2 = floor(index / x1Count);
    return x2;
}

- (CD2DCoordinate)getCoordinateOfObject: (NSObject <NSCoding, NSCopying>*)object{
    NSUInteger index = [array indexOfObject: object];
    if (index == NSNotFound) {
        return NotFound2DCoordinate;
    }
    
    NSUInteger x1 = index % x1Count;
    NSUInteger x2 = floor(index / x1Count);
    return make2DCoordinate(x1, x2);
}

#pragma mark Enumeration

- (void)enumerateObjectsUsingBlock: (void (^)(NSObject <NSCoding, NSCopying>*obj,
                                              CD2DCoordinate coord,
                                              BOOL *stop))block{
    BOOL stp = NO;
    BOOL *stop = &stp;
    
    for (NSUInteger x2 = 0; x2 < x2Count; x2++) {
        for (NSUInteger x1 = 0; x1 < x1Count; x1++) {
            NSUInteger index = (x2 * x1Count) + x1;
            
            CD2DCoordinate c = make2DCoordinate(x1, x2);
            NSObject <NSCoding, NSCopying>*o = array[index];
            
            block(o, c, stop);
            
            if (*stop == YES) break;
        }
        if (*stop == YES) break;
    }
}

@end

@implementation CDMutable2DArray

#pragma mark Notifications

- (void)postContentChangedNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName: CDMutable2DArrayChangedNotification
                                                        object: self];
}

#pragma mark Resizing

- (void)setX1Count: (NSUInteger)x1c
           x2Count: (NSUInteger)x2c
       placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder{
    if (x1c == NSNotFound || x2c == NSNotFound) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity: x1c * x2c];
    
    for (NSUInteger x2 = 0; x2 < x2c; x2++) {
        for (NSUInteger x1 = 0; x1 < x1c; x1++) {
            
            if (x1 < self.x1Count && x2 < self.x2Count) {
                [newArray addObject: [self objectAtX1:x1 x2:x2]];
                
            }else{
                
                [newArray addObject: placeHolder.copy];
            }
        }
    }
    
    [self _setX1Count: x1c];
    [self _setX2Count: x2c];
    [self _setArray: newArray];
    [self postContentChangedNotification];
}

- (void)setX1Count: (NSUInteger)x1c
       placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder{
    [self setX1Count: x1c x2Count: self.x2Count placeHolder: placeHolder];
}

- (void)setX2Count: (NSUInteger)x2c
       placeHolder: (NSObject <NSCoding, NSCopying>*)placeHolder{
    [self setX1Count: self.x1Count x2Count: x2c placeHolder: placeHolder];
}

- (void)replaceObjectsInArrayWithObjectsFrom2DArray: (CD2DArray *)array{
    if (!array) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    [self _setX1Count: array.x1Count];
    [self _setX2Count: array.x2Count];
    
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity: self.totalCount];
    for (NSUInteger x2 = 0; x2 < self.x2Count; x2++) {
        for (NSUInteger x1 = 0; x1 < self.x1Count; x1++) {
            [newArray addObject: [array objectAtX1: x1 x2: x2].copy];
        }
    }
    
    [self _setArray: newArray];
    [self postContentChangedNotification];
}

#pragma mark Changing Contents

- (void)setObject: (NSObject <NSCoding, NSCopying>*)object
     atCoordinate: (CD2DCoordinate)cooridnate{
    if (![self validateInternalCoordinate: cooridnate
                        throwingException: NSInvalidArgumentException]) {
        return;
    }else if (!object) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    NSUInteger index = (cooridnate.x2 * self.x1Count) + cooridnate.x1;
    (self._array)[index] = object;
    [self postContentChangedNotification];
}

- (void)setObject: (NSObject <NSCoding, NSCopying>*)object
             atX1: (NSUInteger)x1
               x2: (NSUInteger)x2{
    if (![self validateInternalX1: x1 x2: x2 throwingException: NSInvalidArgumentException]) {
        return;
    }else if (!object) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    NSUInteger index = (x2 * self.x1Count) * x1;
    (self._array)[index] = object;
    [self postContentChangedNotification];
}

- (void)setObjects: (NSArray *)objects atX1: (NSUInteger)x1{
    if (x1 >= self.x1Count || !objects || objects.count != self.x2Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    for (NSUInteger x2 = 0; x2 < self.x2Count; x2++) {
        NSUInteger index = (x2 * self.x1Count) + x1;
        (self._array)[index] = objects[x2];
    }
    [self postContentChangedNotification];
}

- (void)setObjects: (NSArray *)objects atX2: (NSUInteger)x2{
    if (x2 >= self.x1Count || !objects || objects.count != self.x1Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    for (NSUInteger x1 = 0; x1 < self.x2Count; x1++) {
        NSUInteger index = (x2 * self.x1Count) + x1;
        (self._array)[index] = objects[x1];
    }
    [self postContentChangedNotification];
}

- (void)replaceObjectsBeginningFrom: (CD2DCoordinate)startCoordinate
             withObjectsFrom2DArray: (CD2DArray *)array{
    if (!array) {
        @throw NSInvalidArgumentException;
        return;
    }else if (array.x1Count == 0 || array.x2Count == 0) {
        return;
    }
    
    NSUInteger minX1 = startCoordinate.x1;
    NSUInteger maxX1 = minX1 + array.x1Count - 1;
    NSUInteger minX2 = startCoordinate.x2;
    NSUInteger maxX2 = minX2 + array.x2Count - 1;
    
    if (![self validateInternalX1: minX1 x2: minX2 throwingException: NSInvalidArgumentException] ||
        ![self validateInternalX1: maxX1 x2: maxX2 throwingException: NSInvalidArgumentException]) {
        return;
    }
    
    for (NSUInteger x2 = minX2; x2 <= maxX2; x2++) {
        for (NSUInteger x1 = minX1; x1 <= maxX1; x1++) {
            NSUInteger index1 = (x2 * self.x1Count) + x1;
            NSUInteger index2 = ((x2 - minX2) * array.x1Count) + (x1 - minX1);
            
            NSObject *object = (array._array)[index2];
            (self._array)[index1] = object;
        }
    }
    [self postContentChangedNotification];
}

#pragma mark Removing

- (void)removeObjectsAtX1: (NSUInteger)x1{
    if (x1 >= self.x1Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    for (NSInteger x2 = self.x2Count - 1; x2 >= 0; x2--) {
        NSUInteger index = (x2 * self.x1Count) + x1;
        [self._array removeObjectAtIndex: index];
    }
    [self _setX1Count: self.x1Count - 1];
    [self postContentChangedNotification];
}

- (void)removeObjectsAtX2: (NSUInteger)x2{
    if (x2 >= self.x2Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    [self._array removeObjectsInRange: NSMakeRange(x2 * self.x1Count, self.x1Count)];
    [self _setX2Count: self.x2Count - 1];
    [self postContentChangedNotification];
}

#pragma mark Inserting

- (void)insertObjects: (NSArray *)array
                 atX1: (NSUInteger)x1{
    if (x1 > self.x1Count || !array || array.count != self.x2Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    for (NSInteger x2 = self.x2Count - 1; x2 >= 0; x2--) {
        NSUInteger index = (x2 * self.x1Count) + x1;
        [self._array insertObject: array[x2]
                          atIndex: index];
    }
    [self _setX1Count: self.x1Count + 1];
    [self postContentChangedNotification];
}

- (void)insertObjects: (NSArray *)array
                 atX2: (NSUInteger)x2{
    if (x2 > self.x2Count || !array || array.count != self.x1Count) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    for (NSInteger x1 = self.x1Count - 1; x1 >= 0; x1--) {
        [self._array insertObject: array[x1]
                          atIndex: x2 * self.x1Count];
    }
    
    [self _setX2Count: self.x2Count + 1];
    [self postContentChangedNotification];
}

@end
