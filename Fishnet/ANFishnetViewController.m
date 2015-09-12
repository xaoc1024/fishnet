//
//  ANFishnetViewController.m
//  Fishnet
//
//  Created by Andrew Zhuk on 22.08.13.
//  Copyright (c) 2013 Andrew Zhuk. All rights reserved.
//

#import "ANFishnetViewController.h"
#import "ANNodeRender.h"
#import "ANNode.h"
#import "ANPhysicalSystem.h"
#import "ANLineRender.h"

static NSUInteger const kANFishnetWidth = 7;
static NSUInteger const kANFishnetHeigth = 5;

@interface ANFishnetViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * nodesEffect;
@property (strong) GLKBaseEffect * linesEffect;

@property (strong) ANNodeRender *nodeRender;
@property (strong) ANLineRender *lineRender;

@property (strong) ANPhysicalSystem *system;

@property (nonatomic, weak) ANNode * currentNode;

@end

@implementation ANFishnetViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    [self initGL];
    [self initSystem];
}

- (void) initGL {
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.nodesEffect = [[GLKBaseEffect alloc] init];
    self.linesEffect = [[GLKBaseEffect alloc] init];
    CGSize screenSize = self.view.bounds.size;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0.0f,
                                                      screenSize.width,
                                                      0.0f,
                                                      screenSize.height,
                                                      -1024.0f,
                                                      1024.0f);
    
    self.nodesEffect.transform.projectionMatrix = projectionMatrix;
    self.linesEffect.transform.projectionMatrix = projectionMatrix;
    
    self.lineRender = [[ANLineRender alloc] initWithBaseEffect: self.linesEffect];
    UIImage * nodeImage = [UIImage imageNamed:@"NodeTexture"];
    assert(nodeImage);
    
    self.nodeRender = [[ANNodeRender alloc] initWithImage: nodeImage effect: self.nodesEffect];
    
    self.preferredFramesPerSecond = 60.0f;
}

- (void) initSystem {
    self.system = [[ANPhysicalSystem alloc] init];
    
    self.system.nodeSize = self.nodeRender.contentSize.height;
    
    [self.system createNodeSystemWithHorizontalAmount: kANFishnetWidth
                                       verticalAmount: kANFishnetHeigth
                                           screenSize: self.view.bounds.size];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {    
    [EAGLContext setCurrentContext: self.context];
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    // draw lines
    [self.lineRender renderPreparedLines];
    
    // draw nodes
    ANNode *node;
    [self.system resetNodeIterator];
    while ((node = [self.system getNextNode])) {
        [self.nodeRender renderNode: node];
    }
}

- (void)update {
    [self.system processSystemWithTime: self.timeSinceLastUpdate];
    [self.lineRender prepareForRenderingWithLines: self.system.lines];
}

#pragma mark - user interaction
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect				bounds = [self.view bounds];
    UITouch*	touch = [[event touchesForView:self.view] anyObject];
    
    CGPoint location = [touch locationInView:self.view];
	location.y = bounds.size.height - location.y;
    
    self.currentNode = [self.system findNodeForScreenLocation: location];
    self.currentNode.isManaged = YES;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGRect	bounds = [self.view bounds];
    UITouch * touch = [[event touchesForView: self.view] anyObject];
    
    CGPoint location = [touch locationInView: self.view];
    location.y = bounds.size.height - location.y;
    
    GLKVector2 position = GLKVector2Make(location.x, location.y);
    self.currentNode.position = position;    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentNode.isManaged = NO;
    self.currentNode = nil;
}

@end
