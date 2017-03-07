//
//  ANRenderLine.h
//  Fishnet
//
//  Created by Andrew Zhuk on 02.09.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANLine.h"
#import <GLKit/GLKit.h>

@interface ANLineRender : NSObject

- (instancetype)initWithBaseEffect:(GLKBaseEffect*)effect;

- (void)prepareForRenderingWithLines:(NSArray*)linesArray;
- (void)renderPreparedLines;

@end
