//
//  ANNode.m
//  Fishnet
//
//  Created by Andrew Zhuk on 22.08.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANNode.h"

static float const kANWeigth = 2.0f; // kg;

@interface ANNode ()

@end

@implementation ANNode

- (id)initWithPosition:(GLKVector2)position
{
    self = [super init];
    if (self){
        self.position = position;
        self.weight = kANWeigth;
        self.isMovable = YES;
    }
    return self;
}

- (void)setMotionVector:(GLKVector2)motionVector
{
    // if user drags the node, motion vector will be zero vector.
    _motionVector = (_isManaged) ? GLKVector2Make(0.0f, 0.0f) : motionVector;
}

- (void)setIsManaged:(BOOL)isManaged
{
    _isManaged = isManaged;
    
    if (isManaged){
        self.motionVector = GLKVector2Make(0.0f, 0.0f);
    }
}

- (void)processMotion
{
    if (!self.isManaged && self.isMovable){
        self.position = GLKVector2Add(self.position, self.motionVector);
    }
    
    if (_position.y <= 0) {
        _position.y = 0;
        _motionVector.y = - _motionVector.y;
    }
}

@end
