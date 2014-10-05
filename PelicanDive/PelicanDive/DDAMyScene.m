//
//  DDAMyScene.m
//  PelicanDive
//
//  Created by Dulio Denis on 10/4/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "DDAMyScene.h"

@interface DDAMyScene()
@property (nonatomic) SKSpriteNode *pelican;
@property (nonatomic) SKColor *skyColor;
@property (nonatomic) SKTexture *airplaneTexture;
@property (nonatomic) SKTexture *scubaDiverTexture;
@property (nonatomic) SKAction *moveAndRemoveEnemies;
@end

@implementation DDAMyScene

// The Gap between enemies
static NSInteger const kEnemyGap = 100;

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        // The Sky
        self.skyColor = [UIColor colorWithRed:0.7961 green:0.9333 blue:0.9804 alpha:1];
        self.backgroundColor = self.skyColor;
        
        // The World's Gravity
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
        
        // The Pelican
        SKTexture *pelicanTexture1 = [SKTexture textureWithImageNamed:@"pelican1"];
        SKTexture *pelicanTexture2 = [SKTexture textureWithImageNamed:@"pelican2"];
        
        SKAction *flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[pelicanTexture1, pelicanTexture2] timePerFrame:0.2]];
        
        self.pelican = [SKSpriteNode spriteNodeWithTexture:pelicanTexture1];
        [self.pelican setScale:0.5];
        self.pelican.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        [self.pelican runAction:flap];
        
        self.pelican.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.pelican.size.height / 2];
        self.pelican.physicsBody.dynamic = YES;
        self.pelican.physicsBody.allowsRotation = NO;
        
        [self addChild:self.pelican];
        
        // The Sea Bottom
        SKTexture *seaTexture = [SKTexture textureWithImageNamed:@"sea"];
        
        SKAction *moveSeaSprite = [SKAction moveByX:-seaTexture.size.width*2 y:0 duration:0.02 * seaTexture.size.width*2];
        SKAction *resetSeaSprite = [SKAction moveByX:seaTexture.size.width*2 y:0 duration:0];
        SKAction *moveSeaSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSeaSprite, resetSeaSprite]]];
        
        for (int i = 0; i < 2 + self.frame.size.width / seaTexture.size.width *4; i++) {
            SKSpriteNode *sea = [SKSpriteNode spriteNodeWithTexture:seaTexture];
            [sea setScale:0.5];
            sea.zPosition = -10;
            sea.position = CGPointMake(i * sea.size.width, sea.size.height / 4);
            [sea runAction:moveSeaSpritesForever];
            [self addChild:sea];
        }
        
        // Create a bottom edge physics container
        SKSpriteNode *sea = [SKSpriteNode spriteNodeWithTexture:seaTexture];
        [sea setScale:0.005];
        
        SKNode *bottomEdge = [SKNode node];
        bottomEdge.position = CGPointMake(0, sea.size.height);
        bottomEdge.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, sea.size.height)];
        bottomEdge.physicsBody.dynamic = NO;
        [self addChild:bottomEdge];
        
        // Add Air & Sea Enemies
        self.airplaneTexture = [SKTexture textureWithImageNamed:@"airplane"];
        self.scubaDiverTexture = [SKTexture textureWithImageNamed:@"ScubaDiver"];
        
        CGFloat distanceToMove = self.frame.size.width + 2 * self.airplaneTexture.size.width;
        SKAction *moveEnemies = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
        SKAction *removeEnemies = [SKAction removeFromParent];
        self.moveAndRemoveEnemies = [SKAction sequence:@[moveEnemies, removeEnemies]];
        
        SKAction *spawn = [SKAction performSelector:@selector(spawnEnemies) onTarget:self];
        SKAction *delay = [SKAction waitForDuration:2.0];
        SKAction *spawnThenDelay = [SKAction sequence:@[spawn, delay]];
        SKAction *spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
        [self runAction:spawnThenDelayForever];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.pelican.physicsBody.velocity = CGVectorMake(0, 0);
    [self.pelican.physicsBody applyImpulse:CGVectorMake(0, 4)];
}

CGFloat boxValue(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

- (void)update:(NSTimeInterval)currentTime {
    self.pelican.zRotation = boxValue( -1, 0.5,
                                      self.pelican.physicsBody.velocity.dy *
                                      ( self.pelican.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
}


-(void)spawnEnemies {
    SKNode* enemyPair = [SKNode node];
    enemyPair.position = CGPointMake(self.frame.size.width + self.scubaDiverTexture.size.width, 0);
    enemyPair.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)(self.frame.size.height / 3);
    
    SKSpriteNode *scubaDiver = [SKSpriteNode spriteNodeWithTexture:self.scubaDiverTexture];
    [scubaDiver setScale:0.5];
    scubaDiver.position = CGPointMake(0, y);
    scubaDiver.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:scubaDiver.size];
    scubaDiver.physicsBody.dynamic = NO;
    [enemyPair addChild:scubaDiver];
    
    SKSpriteNode *airplane = [SKSpriteNode spriteNodeWithTexture:self.airplaneTexture];
    [airplane setScale:0.5];
    airplane.position = CGPointMake(0, y + airplane.size.height + kEnemyGap);
    airplane.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:airplane.size];
    airplane.physicsBody.dynamic = NO;
    [enemyPair addChild:airplane];
    
    [enemyPair runAction:self.moveAndRemoveEnemies];
    
    [self addChild:enemyPair];
}

@end
