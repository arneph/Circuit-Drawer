//
//  CD2DBaseTypes.m
//  Circuit Drawer
//
//  Created by Programmieren on 30.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import "CD2DBaseTypes.h"

@implementation CD2DCoordinateObj

+ (CD2DCoordinateObj *)objForCoordinate: (CD2DCoordinate)c {
    CD2DCoordinateObj *o = [[CD2DCoordinateObj alloc] init];
    o.c = c;
    return o;
}

@end

CD2DCoordinate make2DCoordinate(NSInteger x1, NSInteger x2) {
    CD2DCoordinate c;
    c.x1 = x1;
    c.x2 = x2;
    return c;
}

BOOL are2DCoordinatesEqual(CD2DCoordinate c1, CD2DCoordinate c2){
    if (c1.x1 != c2.x1) return NO;
    if (c1.x2 != c2.x2) return NO;
    return YES;
}

CD2DCoordinate notFound2DCoordinate() {
    CD2DCoordinate c;
    c.x1 = NSNotFound;
    c.x2 = NSNotFound;
    return c;
}

BOOL isNotFound2DCoordinate(CD2DCoordinate c) {
    if (c.x1 == NSNotFound && c.x2 == NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

extern NSDictionary * dictionaryStoringCoordinate(CD2DCoordinate c){
    return @{@"x1" : @(c.x1), @"x2" : @(c.x2)};
}

extern CD2DCoordinate coordinateFromDictionary(NSDictionary *dict){
    CD2DCoordinate c;
    c.x1 = ((NSNumber *)dict[@"x1"]).integerValue;
    c.x2 = ((NSNumber *)dict[@"x2"]).integerValue;
    return c;
}

extern NSUInteger numberOfSides(CD2DSides sides){
    NSUInteger c = 0;
    for (NSUInteger i = 0; i < 8; i++) {
        CD2DSides s = (1 << i);
        if ((sides & s) != 0) {
            c++;
        }
    }
    return c;
}

@implementation CD2DRectangleObj

+ (CD2DRectangleObj *)objForRectangle: (CD2DRectangle)r {
    CD2DRectangleObj *o = [[CD2DRectangleObj alloc] init];
    o.r = r;
    return o;
}

@end

extern CD2DRectangle make2DRectangle(NSInteger firstX1, NSInteger firstX2, NSInteger secondX1, NSInteger secondX2) {
    if (firstX1 == NSNotFound || firstX2 == NSNotFound ||
        secondX1 == NSNotFound || secondX2 == NSNotFound) {
        return NotFound2DRectangle;
    }
    
    NSInteger minX1 = (firstX1 < secondX1) ? firstX1 : secondX1;
    NSInteger minX2 = (firstX2 < secondX2) ? firstX2 : secondX2;
    NSInteger maxX1 = (firstX1 > secondX1) ? firstX1 : secondX1;
    NSInteger maxX2 = (firstX2 > secondX2) ? firstX2 : secondX2;
    
    CD2DRectangle r;
    r.startCoordinate.x1 = minX1;
    r.startCoordinate.x2 = minX2;
    r.endCoordinate.x1 = maxX1;
    r.endCoordinate.x2 = maxX2;
    
    return r;
}

extern CD2DRectangle make2DRectangleWithCoordinates(CD2DCoordinate c1, CD2DCoordinate c2) {
    if (isNotFound2DCoordinate(c1) ||
        isNotFound2DCoordinate(c2)) {
        return NotFound2DRectangle;
    }
    
    NSInteger minX1 = (c1.x1 < c2.x1) ? c1.x1 : c2.x1;
    NSInteger minX2 = (c1.x2 < c2.x2) ? c1.x2 : c2.x2;
    NSInteger maxX1 = (c1.x1 > c2.x1) ? c1.x1 : c2.x1;
    NSInteger maxX2 = (c1.x2 > c2.x2) ? c1.x2 : c2.x2;
    
    CD2DRectangle r;
    r.startCoordinate.x1 = minX1;
    r.startCoordinate.x2 = minX2;
    r.endCoordinate.x1 = maxX1;
    r.endCoordinate.x2 = maxX2;
    
    return r;
}

extern CD2DRectangle notFound2DRectangle() {
    CD2DRectangle r;
    r.startCoordinate = NotFound2DCoordinate;
    r.endCoordinate = NotFound2DCoordinate;
    return r;
}

extern BOOL isNotFound2DRectangle(CD2DRectangle r) {
    if (isNotFound2DCoordinate(r.startCoordinate) &&
        isNotFound2DCoordinate(r.endCoordinate)) {
        return YES;
    }else{
        return NO;
    }
}

extern BOOL is2DCoordinateIn2DRectangle(CD2DCoordinate c, CD2DRectangle r) {
    if (isNotFound2DCoordinate(c) ||
        isNotFound2DRectangle(r)) {
        return NO;
    }else if (c.x1 >= r.startCoordinate.x1 && c.x1 <= r.endCoordinate.x1 &&
              c.x2 >= r.startCoordinate.x2 && c.x2 <= r.endCoordinate.x2) {
        return YES;
    }else{
        return NO;
    }
}

extern NSDictionary * dictionaryStoringRectangle(CD2DRectangle r) {
    return @{@"minX1" : @(r.startCoordinate.x1), @"minX2" : @(r.startCoordinate.x2),
             @"maxX1" : @(r.endCoordinate.x1), @"maxX2" : @(r.endCoordinate.x2)};
}

extern CD2DRectangle rectangleFromDictionary(NSDictionary *dict) {
    CD2DRectangle r;
    r.startCoordinate.x1 = ((NSNumber *)dict[@"minX1"]).integerValue;
    r.startCoordinate.x2 = ((NSNumber *)dict[@"minX2"]).integerValue;
    r.endCoordinate.x1 = ((NSNumber *)dict[@"maxX1"]).integerValue;
    r.endCoordinate.x2 = ((NSNumber *)dict[@"maxX2"]).integerValue;
    return r;
}
