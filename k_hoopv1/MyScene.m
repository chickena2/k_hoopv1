//
//  MyScene.m
//  k_hoopv1
//
//  Created by khoa nguyen on 5/29/14.
//  Copyright (c) 2014 knoob studio. All rights reserved.
//

#import "MyScene.h"

static const float vel_x = 600;
static const float vel_y = 600;
static const float gravity = -4.8;

@implementation MyScene {
    SKSpriteNode *ground;
    SKSpriteNode *player;
    SKSpriteNode *ball;
    SKSpriteNode *grid;
    SKSpriteNode *aim;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor whiteColor];
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0,gravity);
        [self addGround];
        [self addPlayer];
        [self addBall];
        [self addGrid];
        [self addRim];
        [self addAim];
    }
    return self;
}



-(void)addGrid {
    grid = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(100,1)];
    grid.position = CGPointMake(10,500);
    [self addChild:grid];
    
}

-(void)addGround {
    ground = [[SKSpriteNode alloc] initWithColor:[SKColor grayColor]
                                            size:CGSizeMake(1000,100)];
    ground.name = @"ground";
    ground.position = CGPointMake(ground.size.width/2,50);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
    ground.physicsBody.dynamic = NO;
    [self addChild:ground];
    
}

-(void)addPlayer {
    player = [[SKSpriteNode alloc] initWithImageNamed:@"player"];
    player.anchorPoint = CGPointMake(0,0);
    player.position = CGPointMake(100, 100);
    [player setScale:0.5];
    [self addChild:player];
}

-(void)addBall {
    ball = [[SKSpriteNode alloc] initWithImageNamed:@"ball"];
    ball.name = @"ball";
    [ball setScale:0.5];
    ball.position = CGPointMake(player.position.x+ball.size.width/2,
                                player.size.height+ground.size.height+ball.size.height/2);
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width/2];
    ball.physicsBody.affectedByGravity = false;
    [self addChild:ball];
}

-(void)addRim {
    SKSpriteNode *frontRim = [self drawRim];
    frontRim.position = CGPointMake(player.position.x+player.size.height*3
                                    ,ground.size.height+ player.size.height*2);
    SKSpriteNode *backRim = [self drawRim];
    backRim.position = CGPointMake(frontRim.position.x+ball.size.width+20,
                                   frontRim.position.y);
}

-(void)addAim {
    aim = [[SKSpriteNode alloc] initWithImageNamed:@"angle_aim"];
    aim.anchorPoint = CGPointMake(0,0);
    aim.position = ball.position;
    [self addChild:aim];
}

-(SKSpriteNode *)drawRim {
    SKSpriteNode *rim = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    [rim setScale:0.1];
    rim.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rim.size.width/2];
    rim.physicsBody.dynamic = NO;
    [self addChild:rim];
    return rim;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:location];
    
    if (touchedNode.name == ball.name) {
        ball.physicsBody.affectedByGravity = true;
        ball.physicsBody.velocity = CGVectorMake(vel_x,vel_y);
    }
    else {
        NSLog(@"touch nothing");
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (ball.position.x > 800 || ball.position.y > 1000) {
        [ball removeFromParent];
        [self addBall];
    }
}

@end
