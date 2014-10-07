//
//  DDAMyScene.m
//  PelicanDive
//
//  Created by Dulio Denis on 10/4/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "DDAMyScene.h"

@interface DDAMyScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *pelican;
@property (nonatomic) SKColor *skyColor;
@property (nonatomic) SKTexture *airplaneTexture;
@property (nonatomic) SKTexture *cloudTexture;
@property (nonatomic) SKTexture *helicopterTexture;
@property (nonatomic) SKTexture *scubaDiverTexture;
@property (nonatomic) SKTexture *oilspillTexture;
@property (nonatomic) SKAction *moveAndRemoveEnemies;
@property (nonatomic) SKAction *moveAndRemoveClouds;
@end

@implementation DDAMyScene


// Collision Categories
static const uint32_t pelicanCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;


// The Gap between enemies
static NSInteger const kEnemyGap = 100;


- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        // The Sky
        self.skyColor = [UIColor colorWithRed:0.7961 green:0.9333 blue:0.9804 alpha:1];
        self.backgroundColor = self.skyColor;
        
        // The World's Gravity & Contact Delegate
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
        self.physicsWorld.contactDelegate = self;
        
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
        
        // Contact Definition for Pelican
        self.pelican.physicsBody.categoryBitMask = pelicanCategory;
        self.pelican.physicsBody.collisionBitMask = enemyCategory;
        self.pelican.physicsBody.contactTestBitMask = enemyCategory;
        
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
        self.helicopterTexture = [SKTexture textureWithImageNamed:@"helicopter"];
        self.scubaDiverTexture = [SKTexture textureWithImageNamed:@"ScubaDiver"];
        self.oilspillTexture = [SKTexture textureWithImageNamed:@"oilspill"];
        self.cloudTexture = [SKTexture textureWithImageNamed:@"cloud0"];
        
        CGFloat distanceToMove = self.frame.size.width + 2 * self.airplaneTexture.size.width;
        SKAction *moveEnemies = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
        SKAction *removeEnemies = [SKAction removeFromParent];
        self.moveAndRemoveEnemies = [SKAction sequence:@[moveEnemies, removeEnemies]];
        
        SKAction *spawn = [SKAction performSelector:@selector(spawnEnemies) onTarget:self];
        SKAction *delay = [SKAction waitForDuration:2.0];
        SKAction *spawnThenDelay = [SKAction sequence:@[spawn, delay]];
        SKAction *spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
        [self runAction:spawnThenDelayForever];
        
        // Add Moving Clouds
        CGFloat distanceToMoveCloud = self.frame.size.width + 2 * self.cloudTexture.size.width;
        SKAction *moveClouds = [SKAction moveByX:-distanceToMoveCloud y:0 duration:0.03 * distanceToMoveCloud];
        SKAction *removeClouds = [SKAction removeFromParent];
        self.moveAndRemoveClouds = [SKAction sequence:@[moveClouds, removeClouds]];
        
        SKAction *spawnClouds = [SKAction performSelector:@selector(spawnClouds) onTarget:self];
        SKAction *delayCloud = [SKAction waitForDuration:1.5];
        SKAction *spawnCloudAndDelay = [SKAction sequence:@[spawnClouds, delayCloud]];
        SKAction *spawnCloudThenDelayForever = [SKAction repeatActionForever:spawnCloudAndDelay];
        [self runAction:spawnCloudThenDelayForever];
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
                                      (self.pelican.physicsBody.velocity.dy < 0 ? 0.003 : 0.001));
}


- (void)spawnClouds {
    NSInteger cloud = arc4random_uniform(3);
    NSString *textureName = [NSString stringWithFormat:@"cloud%ld", (long)cloud];
    SKSpriteNode *cloudSprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:textureName]];
//    SKSpriteNode *cloudSprite = [SKSpriteNode spriteNodeWithTexture:self.cloudTexture];
    cloudSprite.zPosition = -15;
    [cloudSprite setScale:0.5];
    
    CGFloat y = arc4random() % (NSInteger)(self.frame.size.height / 2);
    cloudSprite.position = CGPointMake(self.frame.size.width + self.cloudTexture.size.width,y+200);
    cloudSprite.physicsBody.dynamic = NO;
    
    [cloudSprite runAction:self.moveAndRemoveClouds];
    [self addChild:cloudSprite];
}

-(void)spawnEnemies {
    SKNode *enemyPair = [SKNode node];
    
    NSInteger seaEnemy = arc4random_uniform(2);
    SKSpriteNode *seaEnemySprite = [SKSpriteNode node];
    if (seaEnemy == 0) {
        enemyPair.position = CGPointMake(self.frame.size.width + self.scubaDiverTexture.size.width, 0);
        seaEnemySprite = [SKSpriteNode spriteNodeWithTexture:self.scubaDiverTexture];
    } else {
        enemyPair.position = CGPointMake(self.frame.size.width + self.oilspillTexture.size.width, 0);
        seaEnemySprite = [SKSpriteNode spriteNodeWithTexture:self.oilspillTexture];
    }
    enemyPair.zPosition = -10;
    
    CGFloat y = arc4random() % (NSInteger)(self.frame.size.height / 3);
    
    [seaEnemySprite setScale:0.5];
    seaEnemySprite.position = CGPointMake(0, y);
    seaEnemySprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:seaEnemySprite.size];
    seaEnemySprite.physicsBody.dynamic = NO;
    
    // Collision Definition for Sea Enemies
    seaEnemySprite.physicsBody.collisionBitMask = enemyCategory;
    seaEnemySprite.physicsBody.contactTestBitMask = pelicanCategory;
    
    [enemyPair addChild:seaEnemySprite];
    
    NSInteger enemy = arc4random_uniform(2);
    SKSpriteNode *airShip = [SKSpriteNode node];
    if (enemy == 0) {
        airShip = [SKSpriteNode spriteNodeWithTexture:self.airplaneTexture];
    } else {
        airShip = [SKSpriteNode spriteNodeWithTexture:self.helicopterTexture];
    }
    [airShip setScale:0.5];
    airShip.position = CGPointMake(0, y + airShip.size.height + kEnemyGap);
    airShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:airShip.size];
    airShip.physicsBody.dynamic = NO;
    
    // Collision Definition for Air Enemies
    airShip.physicsBody.collisionBitMask = enemyCategory;
    airShip.physicsBody.contactTestBitMask = pelicanCategory;
    
    [enemyPair addChild:airShip];
    
    [enemyPair runAction:self.moveAndRemoveEnemies];
    
    [self addChild:enemyPair];
}


- (void)didBeginContact:(SKPhysicsContact *)contact {
    [self removeActionForKey:@"flash"];
    [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
        self.backgroundColor = [SKColor redColor];
    }], [SKAction waitForDuration:0.05], [SKAction runBlock:^{
        self.backgroundColor = self.skyColor;
    }], [SKAction waitForDuration:0.05]]] count:4]]] withKey:@"flash"];
}

@end
