//
//  ANPhysicalSystem.h
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANLine.h"
#import "ANNode.h"
#import "ANLineRender.h"

@interface ANPhysicalSystem : NSObject

@property (assign, readonly) NSUInteger linesAmount;
@property (assign) float nodeSize;

- (void) createNodeSystemWithHorizontalAmount: (NSUInteger) width
                               verticalAmount: (NSUInteger) height
                                   screenSize: (CGSize) size;
- (ANNode *) getNextNode;

- (NSArray *) lines;

- (void) resetNodeIterator;
- (void) processSystemWithTime: (float) timeSinceLastUpdate;
- (ANNode *) findNodeForScreenLocation:(CGPoint) location;

@end
