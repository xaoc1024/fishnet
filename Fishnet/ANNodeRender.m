//
//  ANNode.m
//  Fishnet
//
//  Created by Andrew Zhuk on 22.08.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANNodeRender.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface ANNodeRender ()

@property (strong) GLKBaseEffect * effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;
@property (assign, readwrite) CGSize contentSize;

@end

@implementation ANNodeRender
- (id)initWithImage:(UIImage *)image effect:(GLKBaseEffect *)effect
{
    if ((self = [super init])) {
        self.effect = effect;
        
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        NSError * error;
        self.textureInfo = [GLKTextureLoader textureWithCGImage: image.CGImage
                                                        options: options
                                                          error: &error];
        
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        float scale = [[UIScreen mainScreen] scale];
        float textureWidth = self.textureInfo.width / scale;
        float textureHeight = self.textureInfo.height / scale;
        
        self.contentSize = CGSizeMake(textureWidth, textureHeight);
        
        TexturedQuad quad;
        quad.bl.geometryVertex = CGPointMake(0, 0);
        quad.br.geometryVertex = CGPointMake(textureWidth, 0);
        quad.tl.geometryVertex = CGPointMake(0, textureHeight);
        quad.tr.geometryVertex = CGPointMake(textureWidth, textureHeight);
        
        quad.bl.textureVertex = CGPointMake(0, 0);
        quad.br.textureVertex = CGPointMake(1, 0);
        quad.tl.textureVertex = CGPointMake(0, 1);
        quad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = quad;
    }
    return self;
}

- (GLKMatrix4) modelMatrixForPosition: (GLKVector2) position {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, 0);
    
    return GLKMatrix4Translate(modelMatrix,
                              - self.contentSize.width / 2,
                              - self.contentSize.height / 2,
                              0);
}

- (void)renderNode:(ANNode *)node {
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    
    self.effect.transform.modelviewMatrix = [self modelMatrixForPosition: node.position];
    
    [self.effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    long offset = (long)&_quad;
    
    glVertexAttribPointer(GLKVertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(TexturedVertex),
                          (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(TexturedVertex),
                          (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
