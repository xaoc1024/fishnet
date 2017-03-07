//
//  ANNode.h
//  Fishnet
//
//  Created by Andrew Zhuk on 22.08.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>
#import "ANLine.h"

@interface ANNode : NSObject

@property (assign) NSUInteger identifier;

@property (weak) ANLine * leftNeighborLine;
@property (weak) ANLine * rightNeighborLine;
@property (weak) ANLine * upperNeighborLine;
@property (weak) ANLine * lowerNeighborLine;

@property (nonatomic, assign) GLKVector2 motionVector;
@property (assign) GLKVector2 forceVector;
@property (assign) GLKVector2 position;

@property (assign) float weight;
@property (assign) BOOL isMovable;
@property (nonatomic, assign) BOOL isManaged;

- (id)initWithPosition: (GLKVector2) position;

- (void)processMotion;

@end
