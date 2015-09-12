//
//  ANPhysicalSystem.m
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANPhysicalSystem.h"
#import "ANNode.h"

static float const kANAttenuation = 0.01;

static float const kANg = 9.80665f; // Earth gravity constant (metres per (second ^ -2) )
static float const kANIdent = 35.0f;

typedef struct {
    NSUInteger width;
    NSUInteger height;
} ANMatrixSize;


@interface ANPhysicalSystem () {
    void *** _nodesMatrix;
}

@property (nonatomic, assign, readwrite) ANMatrixSize matrixSize;
@property (assign) NSUInteger nodeIterator;
@property (strong) NSArray * linesArray;

- (void) updateLines;

@end

@implementation ANPhysicalSystem

- (id)init {
    self = [super init];
    if (self) {
        self.nodeIterator = 0;
    }
    return self;
}

#pragma mark -
#pragma mark - preparing for work
- (void) createNodeSystemWithHorizontalAmount: (NSUInteger) width
                               verticalAmount: (NSUInteger) height
                                   screenSize: (CGSize) theScreenSize
{
    // save matrix size
    _matrixSize.height = height;
    _matrixSize.width = width;
    
    // creating matrix with nodes: memory allocation
    _nodesMatrix = calloc(height, sizeof(void *));
    for (int i = 0; i < height; i++){
        _nodesMatrix[i] = calloc(width, sizeof(void *));
    }
    
    // create nodes and save them in the matrix
    float horizontalIdent = (theScreenSize.width - (width * kANIdent)) / 2;
    float verticalIdent = 100;
    
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            GLKVector2 pos = GLKVector2Make(j * kANIdent + horizontalIdent,
                                            theScreenSize.height - (kANIdent * i + verticalIdent / 2));
            
            ANNode * node = [[ANNode alloc] initWithPosition: pos];
            node.identifier = (i * width) + j + 1;
            if (node.identifier ==  width  || node.identifier == 1) {
                node.isMovable = NO;
            }
            _nodesMatrix[i][j] = (void *)CFBridgingRetain(node);
        }
    }
        
    [self generateLines];
}

- (void) generateLines {    
    ANLineCoordinates coords;
    ANLine * line;
    NSMutableArray *linesArray = [NSMutableArray array];
    
    // setting up horizontal lines
    ANNode * leftNode;
    ANNode * rightNode;    
    for (int i = 0; i < self.matrixSize.height; i++) {
        for (int j = 0; j < self.matrixSize.width - 1; j++) {
            leftNode = (__bridge ANNode *)(_nodesMatrix[i][j]);
            rightNode = (__bridge ANNode *)(_nodesMatrix[i][j + 1]);
            
            coords.startPoint = leftNode.position;
            coords.endPoint = rightNode.position;
            
            line = [[ANLine alloc] initWithLineCoordinates: coords
                                         startNodeLocation: CGPointMake(i, j)
                                           endNodeLocation: CGPointMake(i, j + 1)];
            [linesArray addObject: line];
            
            // make neighbors
            leftNode.rightNeighborLine = line;
            rightNode.leftNeighborLine = line;            
        }
    }
    
    // setting up vertical lines
    ANNode * upperNode;
    ANNode * lowerNode;
    for (int j = 0; j < self.matrixSize.width; j++) {
        for (int i = 0; i < self.matrixSize.height - 1; i++) {
            upperNode = (__bridge ANNode *)(_nodesMatrix[i][j]);
            lowerNode = (__bridge ANNode *)(_nodesMatrix[i + 1][j]);
            
            coords.startPoint = upperNode.position;
            coords.endPoint = lowerNode.position;
            
            line = [[ANLine alloc] initWithLineCoordinates: coords
                                         startNodeLocation: CGPointMake(i, j)
                                           endNodeLocation: CGPointMake(i + 1, j)];
            [linesArray addObject:line];
            
            // make neighbors
            upperNode.lowerNeighborLine = line;
            lowerNode.upperNeighborLine = line;
        }
    }
    
    self.linesArray = linesArray;
}

#pragma mark - getters
- (ANNode *) getNextNode {
    NSUInteger i, j;
    
    i = (self.nodeIterator / self.matrixSize.width);
    
    j = self.nodeIterator - (i * self.matrixSize.width);
    self.nodeIterator++;
    
    return (self.matrixSize.width > j && self.matrixSize.height > i) ? ((__bridge ANNode *)(_nodesMatrix[i][j])) : nil;
}

- (NSArray *) lines {
    return _linesArray;
}

- (void) resetNodeIterator {
    self.nodeIterator = 0;
}

- (ANNode *) findNodeForScreenLocation:(CGPoint) location {
    ANNode * cn; // current node;
    GLKVector2 locationVector = GLKVector2Make(location.x, location.y);
    float dist;
    
    for (int i = 0; i < self.matrixSize.height; i++) {
        for (int j = 0; j < self.matrixSize.width; j++) {
            cn = (__bridge ANNode *)(_nodesMatrix[i][j]);
            if ((dist = GLKVector2Distance(cn.position, locationVector)) <= self.nodeSize / 2.0f) {
                return cn;
            }
        }
    }
    return nil;
}

#pragma mark - processing system
- (void) processSystemWithTime: (float) timeSinceLastUpdate {
    [self calculateForces];
    [self processMotionUsingTime: timeSinceLastUpdate];    
    [self updateLines];
}

- (void) calculateForces {
    ANNode * cn; // current node;
    
    for (int i = 0; i < self.matrixSize.height; i++) {
        for (int j = 0; j < self.matrixSize.width; j++) {
            cn = (__bridge ANNode *)(_nodesMatrix[i][j]);
            
            // calculating all forces
            // Earth gravity force
            GLKVector2 commonForceVector = GLKVector2Make(0.0f, - kANg * cn.weight);
            
            // summing up all line forces that affect on current node
            GLKVector2 commonHookForce = GLKVector2Make(0.0f, 0.0f);
            commonHookForce = GLKVector2Add(commonHookForce, [self hookForceVectorForLine: cn.leftNeighborLine
                                                                                usingNode: cn]);
            commonHookForce = GLKVector2Add(commonHookForce, [self hookForceVectorForLine: cn.rightNeighborLine
                                                                                usingNode: cn]);
            commonHookForce = GLKVector2Add(commonHookForce, [self hookForceVectorForLine: cn.upperNeighborLine
                                                                                usingNode: cn]);
            commonHookForce = GLKVector2Add(commonHookForce, [self hookForceVectorForLine: cn.lowerNeighborLine
                                                                                usingNode: cn]);
            
            commonForceVector = GLKVector2Add(commonForceVector, commonHookForce);
            cn.forceVector = commonForceVector;
        }
    }
}

- (GLKVector2) hookForceVectorForLine:(ANLine *)line usingNode:(ANNode *) node {
    if (line == nil) {
        return GLKVector2Make(0.0f, 0.0f);
    }
    
    BOOL lineStartsInThisNode = ((node.position.x == line.lineCoordinates.startPoint.x) &&
                      (node.position.y == line.lineCoordinates.startPoint.y)) ? YES : NO;
    
    float lineDisplacement = [line lineDisplacement];
    if (lineDisplacement < 0){
        lineDisplacement = 0;
    }
    // Using Hooks law to calculate force comminted by line to node;
    float hookForce = lineDisplacement * line.stiffness;
    GLKVector2 lineVector;
    
    lineVector = (lineStartsInThisNode) ? GLKVector2Make(line.lineCoordinates.endPoint.x - line.lineCoordinates.startPoint.x,
                                                         line.lineCoordinates.endPoint.y - line.lineCoordinates.startPoint.y) :
                                          GLKVector2Make(line.lineCoordinates.startPoint.x - line.lineCoordinates.endPoint.x,
                                                         line.lineCoordinates.startPoint.y - line.lineCoordinates.endPoint.y);
    
    lineVector = GLKVector2Normalize(lineVector);
    GLKVector2 hookForceVector = GLKVector2MultiplyScalar(lineVector, hookForce);
    
    return hookForceVector;
}

- (void) processMotionUsingTime: (float) timeSinceLastUpdate {
    ANNode * cn; // current node;
    
    for (int i = 0; i < self.matrixSize.height; i++)
    {
        for (int j = 0; j < self.matrixSize.width; j++)
        {
            cn = (__bridge ANNode *)(_nodesMatrix[i][j]);
            // calculating speed of node motion using Newton second law
            cn.motionVector = GLKVector2Add(cn.motionVector,
                                            GLKVector2MultiplyScalar(cn.forceVector,
                                                                     (1.0f / cn.weight) * timeSinceLastUpdate));
            // simulating friction force
            cn.motionVector = GLKVector2Subtract(cn.motionVector,
                                                 GLKVector2MultiplyScalar(cn.motionVector, kANAttenuation));
            // shifting node position considering motion vector
            [cn processMotion];
        }
    }
}

- (void) updateLines {
    NSUInteger i, j;
    ANLineCoordinates coords;
    
    for (ANLine * line in self.linesArray) {
        // looking for line's start node indeces in matrix
        i = line.startNodeLocation.x;
        j = line.startNodeLocation.y;
        coords.startPoint = ((__bridge ANNode *)(_nodesMatrix[i][j])).position;
        
        // looking for line's end node indeces in matrix
        i = line.endNodeLocation.x;
        j = line.endNodeLocation.y;        
        coords.endPoint = ((__bridge ANNode *)(_nodesMatrix[i][j])).position;
        
        // saving new coordinates to line
        line.lineCoordinates = coords;
    }
}

- (void) dealloc {
    // releasing matrix;
    if (_nodesMatrix != nil){
        for (int i = 0; i < self.matrixSize.height; i++) {
            for (int j = 0; j < self.matrixSize.width; j++) {
                CFRelease(_nodesMatrix[i][j]);
            }
            free(_nodesMatrix[i]);
        }
    }
}

@end
