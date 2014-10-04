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
@end

@implementation DDAMyScene

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        // The Sky
        self.skyColor = [UIColor colorWithRed:0.7961 green:0.9333 blue:0.9804 alpha:1];
        self.backgroundColor = self.skyColor;
        
        // The Pelican
        SKTexture *pelicanTexture1 = [SKTexture textureWithImageNamed:@"pelican1"];
        SKTexture *pelicanTexture2 = [SKTexture textureWithImageNamed:@"pelican2"];
        
        SKAction *flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[pelicanTexture1, pelicanTexture2] timePerFrame:0.2]];
        
        self.pelican = [SKSpriteNode spriteNodeWithTexture:pelicanTexture1];
        self.pelican.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        [self.pelican runAction:flap];
        
        [self addChild:self.pelican];
        
        // The Sea Bottom
        SKTexture *seaTexture = [SKTexture textureWithImageNamed:@"sea"];
        
        SKAction* moveSeaSprite = [SKAction moveByX:-seaTexture.size.width*2 y:0 duration:0.02 * seaTexture.size.width*2];
        SKAction* resetSeaSprite = [SKAction moveByX:seaTexture.size.width*2 y:0 duration:0];
        SKAction* moveSeaSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSeaSprite, resetSeaSprite]]];
        
        for (int i = 0; i < 2 + self.frame.size.width / seaTexture.size.width *4; i++) {
            SKSpriteNode *sea = [SKSpriteNode spriteNodeWithTexture:seaTexture];
            [sea setScale:0.5];
            sea.position = CGPointMake(i * sea.size.width, sea.size.height / 4);
            [sea runAction:moveSeaSpritesForever];
            [self addChild:sea];
        }
        
    }
    return self;
}

@end
