//
//  MyScene.m
//  k_hoopv1
//
//  Created by khoa nguyen on 5/29/14.
//  Copyright (c) 2014 knoob studio. All rights reserved.
//

#import "MyScene.h"

static const float power = 700;
static const float gravity = -4.8;
static const float r_in = 70;
static const float r_out = 100;

@implementation MyScene {
    SKSpriteNode *ground;
    SKSpriteNode *player;
    SKSpriteNode *ball;
    SKSpriteNode *grid;
    SKSpriteNode *aim;
    SKSpriteNode *needle;
    SKSpriteNode *b_rotateUp;
    SKSpriteNode *b_rotateDown;
    CGPoint p_start;
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
        [self addNeedle];
        [self addUpButton];
        [self addDownButton];
    }
    return self;
}

-(void)addDownButton {
    b_rotateDown = [[SKSpriteNode alloc] initWithImageNamed:@"ball"];
    b_rotateDown.name = @"rotate up";
    b_rotateDown.position = CGPointMake(300, 200);
    [self addChild:b_rotateDown];
}
         
-(void)addUpButton {
    b_rotateUp = [[SKSpriteNode alloc] initWithImageNamed:@"ball"];
    b_rotateUp.name = @"rotate down";
    b_rotateUp.position = CGPointMake(300, 300);
    [self addChild:b_rotateUp];
}



-(void)addNeedle {
    needle = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor] size:CGSizeMake(100,1)];
    needle.anchorPoint = CGPointMake(0,0);
    needle.position = ball.position;
    needle.zPosition = -1;
    needle.zRotation = M_PI_4;
    [self addChild:needle];
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
    aim.zPosition = -2;
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

-(void)throwBall {
    ball.physicsBody.affectedByGravity = true;
    ball.physicsBody.velocity = CGVectorMake(power*cosf(needle.zRotation),
                                             power*sinf(needle.zRotation));
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    p_start = [touch locationInNode:self];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isInsideAim:p_start]) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        if ([self isInsideAim:location]) {
            SKAction *rotate = [SKAction rotateToAngle:[self touchAngle:location] duration:1];
            [needle runAction: rotate];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:location];
    
    if (touchedNode.name == ball.name) {
        [self throwBall];
    }
    else if (touchedNode.name == b_rotateUp.name) {
        needle.zRotation = needle.zRotation + M_PI/90;
    }
    else if (touchedNode.name == b_rotateDown.name) {
        needle.zRotation = needle.zRotation - M_PI/90;
    }
    else {
        NSLog(@"%2f,%2f", [self touchAngle:p_start],[self angleBetween:p_start and:location]);
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (ball.position.x > 800 || ball.position.y > 1000
        || ball.position.x < player.position.x) {
        [ball removeFromParent];
        [self addBall];
    }
}

-(float)distanceBetween:(CGPoint)pointA and:(CGPoint)pointB {
    float dx = pointB.x - pointA.x;
    float dy = pointB.y - pointA.y;
    return sqrt(dx*dx + dy*dy );
}

-(float)angleBetween:(CGPoint)pointA and:(CGPoint)pointB {
    return [self touchAngle:pointB] - [self touchAngle:pointA];
}

-(BOOL)isInsideAim:(CGPoint)pointA {
    if (pointA.x > ball.position.x && pointA.y > ball.position.y) {
        float d = [self distanceBetween:pointA and:ball.position];
        if (d > r_in && d < r_out) {
            return TRUE;
        }
        else return FALSE;
    }
    else return FALSE;
}

-(float)touchAngle:(CGPoint)touchPoint {
    float dy = touchPoint.y - ball.position.y;
    float dx = touchPoint.x - ball.position.x;
    return atan2f(dy, dx);
}

-(void)rotateClockwise {
    needle.zRotation = needle.zRotation - M_PI/90;
}

-(void)rotateCounterClockwise {
    needle.zRotation = needle.zRotation + M_PI/90;
}
@end
