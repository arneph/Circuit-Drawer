//
//  CD2DBaseTypes.h
//  Circuit Drawer
//
//  Created by Programmieren on 30.07.14.
//  Copyright (c) 2014 AP-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

struct CD2DCoordinate {
    NSInteger x1;
    NSInteger x2;
};
typedef struct CD2DCoordinate CD2DCoordinate;

@interface CD2DCoordinateObj : NSObject
@property CD2DCoordinate c;
+ (CD2DCoordinateObj *)objForCoordinate: (CD2DCoordinate)c;
@end

extern CD2DCoordinate make2DCoordinate(NSInteger x1, NSInteger x2);

extern BOOL are2DCoordinatesEqual(CD2DCoordinate c1, CD2DCoordinate c2);

#define NotFound2DCoordinate notFound2DCoordinate()

extern CD2DCoordinate notFound2DCoordinate();
extern BOOL isNotFound2DCoordinate(CD2DCoordinate c);

extern NSDictionary * dictionaryStoringCoordinate(CD2DCoordinate c);
extern CD2DCoordinate coordinateFromDictionary(NSDictionary *dict);

enum CD2DSides{
    CD2DSideRight = (1 << 0),
    CD2DSideTopRight = (1 << 1),
    CD2DSideTop = (1 << 2),
    CD2DSideTopLeft = (1 << 3),
    CD2DSideLeft = (1 << 4),
    CD2DSideBottomLeft = (1 << 5),
    CD2DSideBottom = (1 << 6),
    CD2DSideBottomRight = (1 << 7)
};
typedef enum CD2DSides CD2DSides;

extern NSUInteger numberOfSides(CD2DSides sides);

struct CD2DRectangle {
    CD2DCoordinate startCoordinate;
    CD2DCoordinate endCoordinate;
};
typedef struct CD2DRectangle CD2DRectangle;

@interface CD2DRectangleObj : NSObject
@property CD2DRectangle r;
+ (CD2DRectangleObj *)objForRectangle: (CD2DRectangle)r;
@end

extern CD2DRectangle make2DRectangle(NSInteger firstX1, NSInteger firstX2, NSInteger secondX1, NSInteger secondX2);
extern CD2DRectangle make2DRectangleWithCoordinates(CD2DCoordinate c1, CD2DCoordinate c2);

extern BOOL is2DCoordinateIn2DRectangle(CD2DCoordinate c, CD2DRectangle r);

#define NotFound2DRectangle notFound2DRectangle()

extern CD2DRectangle notFound2DRectangle();
extern BOOL isNotFound2DRectangle(CD2DRectangle r);

extern NSDictionary * dictionaryStoringRectangle(CD2DRectangle r);
extern CD2DRectangle rectangleFromDictionary(NSDictionary *dict);
