//
//  ANLine.m
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANLine.h"
#import <GLKit/GLKit.h>

static float const kANStiffness = 2; // newtons per metre

@interface ANLine ()

@property (nonatomic, assign, readwrite) float lineLength;

@end

@implementation ANLine

- (id) initWithLineCoordinates: (ANLineCoordinates) coordinates
           startNodeLocation: (CGPoint) start
             endNodeLocation: (CGPoint) end
{
    self = [super init];
    
    if (self){
        self.lineCoordinates = coordinates;
        self.startNodeLocation = start;
        self.endNodeLocation = end;
        self.stiffness = kANStiffness;
              
        self.lineLength = GLKVector2Distance(coordinates.startPoint,
                                             coordinates.endPoint);
    }
    
    return self;
}

- (float) lineDisplacement {
    return GLKVector2Distance(self.lineCoordinates.endPoint, self.lineCoordinates.startPoint) - self.lineLength;    
}

- (void) setLineCoordinates: (ANLineCoordinates) lineCoordinates {
    _lineCoordinates = lineCoordinates;   
}

@end
