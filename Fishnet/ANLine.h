//
//  ANLine.h
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector2 startPoint;
    GLKVector2 endPoint;
} ANLineCoordinates;

@interface ANLine : NSObject

@property (nonatomic, assign) ANLineCoordinates lineCoordinates;

@property (nonatomic, assign, readonly) float lineLength;
@property (nonatomic, assign) float stiffness;

@property (nonatomic, assign) CGPoint startNodeLocation;
@property (nonatomic, assign) CGPoint endNodeLocation;

- (id)initWithLineCoordinates:(ANLineCoordinates)coordinates startNodeLocation:(CGPoint)start endNodeLocation:(CGPoint)end;

- (float)lineDisplacement;

@end
