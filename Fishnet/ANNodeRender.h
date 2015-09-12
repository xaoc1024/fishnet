//
//  ANNode.h
//  Fishnet
//
//  Created by Andrew Zhuk on 22.08.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ANNode.h"

@interface ANNodeRender : NSObject

@property (assign, readonly) CGSize contentSize;

- (id)initWithImage: (UIImage *) image effect: (GLKBaseEffect *) effect;

- (void)renderNode: (ANNode *) theNode;

@end
