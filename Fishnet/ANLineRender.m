//
//  ANRenderLine.m
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANLineRender.h"

@interface ANLineRender () {
    ANLineCoordinates * _linesData;
}

@property (strong) GLKBaseEffect * effect;
@property (assign) float linesCount;

@end

@implementation ANLineRender

- (id) initWithBaseEffect: (GLKBaseEffect *) effect
{
    self = [super init];

    if (self != nil)
    {
        self.effect = effect;
        self.effect.useConstantColor = GL_TRUE;        
        // Make the line a black color
        self.effect.constantColor = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
    }

    return self;
}

- (void)prepareForRenderingWithLines:(NSArray *)linesArray
{
    NSAssert(linesArray.count, @"Array shouldn't be empty");
    
    if (self.linesCount == 0)
    {
        self.linesCount = linesArray.count;
        // create data storage for lines
        _linesData = calloc(_linesCount, sizeof(ANLineCoordinates));
    }
    else if (_linesCount != linesArray.count)
    {
        NSAssert(0, @"Render was fed with different data this and previous times. Data must be the same.");
    }

    // copy data to storage
    for (int i = 0; i < _linesCount; ++i)
    {
        _linesData[i] = ((ANLine *)linesArray[i]).lineCoordinates;
    }
}

- (void) renderPreparedLines {    
    [self.effect prepareToDraw];
    
    GLuint bufferLinesArray;
    glGenBuffers(1, &bufferLinesArray);
    glBindBuffer(GL_ARRAY_BUFFER, bufferLinesArray);
    
    glBufferData(GL_ARRAY_BUFFER,   // the target buffer
                 sizeof(ANLineCoordinates) * _linesCount,      // the number of bytes to put into the buffer
                 _linesData,              // a pointer to the data being copied
                 GL_STATIC_DRAW);   // the usage pattern of the data
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition, 
                          2,                       
                          GL_FLOAT,                
                          GL_FALSE,                
                          sizeof(float) * 2,       
                          NULL);                   
    
    glBindBuffer(GL_ARRAY_BUFFER, 0); // unbind currently bound buffer
    
    glDrawArrays(GL_LINES, 0, 2 * _linesCount);
}

- (void) dealloc {
    free(_linesData);
}

@end
