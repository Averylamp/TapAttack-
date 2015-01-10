//
//  GameScene.m
//  GreenRedBlackGame
//
//  Created by Avery Lamp on 12/27/14.
//  Copyright (c) 2014 Avery Lamp. All rights reserved.
//

#import "GameScene.h"
#import "AppDelegate.h"
#import "UIImage+Mask.h"
#import <AVFoundation/AVFoundation.h>
@interface GameScene()
@property double lastTime;
@property double numberOfUpdates;
@property int score;
@property SKLabelNode *scoreLabel;
@property double spawnRate;
@property double spawnTime;
@property int redSpawnRate;
@property int redLastNumberOfUpdates;
@property double timeToDissappear;
@property double timeToDissappearRate;
@property NSMutableArray *arrayOfClickableCircles;
@property NSMutableArray *arrayOfTimesToDissappear;
@property NSMutableArray *arrayOfRedCircles;
@property NSMutableArray *arrayOfRedTimesToDissappear;
@property BOOL started;
@property SystemSoundID clickSound;
@property SystemSoundID redClickSound;
@property SystemSoundID goldenClickSound;
@end
@implementation GameScene

static double const savedImageMultiplier = 4.0/3.0;
-(void)didMoveToView:(SKView *)view {
    NSString * soundFilePath = [[NSBundle mainBundle] pathForResource:@"partnersinrhyme_CLICK13A" ofType:@"mp3"];
    //NSLog(soundFilePath);
    NSLog(@"HERE");
    NSURL *soundURL = [NSURL fileURLWithPath:soundFilePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_clickSound);
    
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"FartSound" ofType:@"mp3"];
    soundURL = [NSURL fileURLWithPath:soundFilePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_redClickSound);
    
    soundFilePath = [[NSBundle mainBundle] pathForResource:@"Powerup20" ofType:@"wav"];
    soundURL = [NSURL fileURLWithPath:soundFilePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_goldenClickSound);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    self.screenSize = screenSize;
    self.active = YES;
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    appDelegate.gameScene = self;
    
    self.lost = NO;
    if ([self.view isKindOfClass:[SKView class]]) {
        NSLog(@"IT IS A SKVIEW");
    }else{
        NSLog(@"IT IS A UIVIEW");
    }
    /* Setup your scene here */
    self.spawnTime = 0;
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Condensed"];
    self.scoreLabel.text = @"Score - 0";
    self.scoreLabel.fontSize = 100.0f;
    self.scoreLabel.fontColor = [UIColor blackColor];
    self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                           self.screenSize.height - 90);
    [self addChild:self.scoreLabel];
    
    
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel.fontColor = [UIColor blackColor];
    myLabel.text = @"3";
    myLabel.fontSize = 200;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    myLabel.xScale = 0.25;
    
    myLabel.yScale = 0.25;
    [self addChild:myLabel];
    
    
    [myLabel runAction: [SKAction scaleTo:1.0 duration:1] completion:^{
        myLabel.text = @"2";
        NSLog(@"2");
        myLabel.xScale = 0.25;
        myLabel.yScale = 0.25;
        [myLabel runAction: [SKAction scaleTo:1.0 duration:1]completion:^{
            myLabel.text = @"1";
            NSLog(@"1");
            myLabel.xScale = 0.25;
            myLabel.yScale = 0.25;
            [myLabel runAction:[SKAction scaleTo:1.0 duration:1] completion:^{
                [myLabel removeFromParent];
                self.paused = NO;
                self.started = YES;
            }];
            
        }];
    }];
    self.redSpawnRate = 300;
    
    
    
    self.arrayOfClickableCircles =[[NSMutableArray alloc]init];
    self.arrayOfTimesToDissappear =[[NSMutableArray alloc]init];
    self.arrayOfRedCircles =[[NSMutableArray alloc]init];
    self.arrayOfRedTimesToDissappear =[[NSMutableArray alloc]init];
    self.spawnRate = .75;
    self.timeToDissappear = 1.5;
    self.timeToDissappearRate = .5;
    
}





-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if(!self.lost){
        for (UITouch *touch in touches) {
            
            
            CGPoint positionInScene = [touch locationInNode:self];
            SKShapeNode *touchedNode = (SKShapeNode *)[self nodeAtPoint:positionInScene];
            if (touchedNode){
                if ([[touchedNode name]  isEqualToString:@"Green Node"]||[[touchedNode name]  isEqualToString:@"Green Node with Image"]||[[touchedNode name]  isEqualToString:@"Green Node with Saved Image"]){
                    //[self lose];
                    AudioServicesPlaySystemSound(self.clickSound);
                    int x = [self.arrayOfClickableCircles indexOfObject:touchedNode];
                    if (x<[self.arrayOfTimesToDissappear count]) {
                        [self.arrayOfTimesToDissappear removeObjectAtIndex:x];
                    }
                    [self.arrayOfClickableCircles  removeObjectAtIndex:x];
                    [touchedNode removeAllActions];
                    [touchedNode removeFromParent];
                    self.score = self.score + 1;
                    if ([[touchedNode name]  isEqualToString:@"Green Node with Image"]) {
                        self.score = self.score + 1;
                    }
                }
                if([[touchedNode name]isEqualToString:@"Golden Node"]){
                    [touchedNode removeFromParent];
                    AudioServicesPlaySystemSound(self.goldenClickSound);
                    self.score = self.score + arc4random() %30 + 20;
                }
                if([[touchedNode name]isEqualToString:@"Red Node"]){
                    AudioServicesPlaySystemSound(self.redClickSound);
                    [self lose:@"You touched a red"];
                }
            }
            
            /*
             CGRect circle = CGRectMake(-55, -55, 110.0,110.0);
             SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
             shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
             shapeNode.fillColor = SKColor.greenColor;
             shapeNode.strokeColor = nil;
             shapeNode.position = location;
             shapeNode.xScale=0.1;
             shapeNode.yScale=0.1;
             [self addChild:shapeNode];
             [shapeNode runAction:[SKAction  scaleTo:1 duration:0.15]completion:^{
             [self.arrayOfClickableCircles addObject:shapeNode];
             [self.arrayOfTimesToDissappear addObject:[NSDecimalNumber numberWithDouble:CACurrentMediaTime() + self.timeToDissappear]];
             } ];
             NSLog(@"TimeTODissappear - %f",CACurrentMediaTime() + self.timeToDissappear);
             */
        }
    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch * touch = (UITouch *)[[touches allObjects]firstObject];
    CGPoint location = [touch locationInNode:self];
    
    NSLog(@"Position x - %f , y - %f", location.x, location.y);
    
    
}

-(void)lose:(NSString *)loseMessage{
    self.lost = YES;
    //NSLog(loseMessage);
    //SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    /*
     myLabel.text = loseMessage;
     myLabel.fontSize = 40;
     myLabel.fontColor = SKColor.blackColor;
     myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
     CGRectGetMidY(self.frame));
     [self addChild:myLabel];
     */
    NSLog(@"YOU LOSE");
    //sleep(3);
    self.active = NO;
    [RWGameData sharedGameData].highScore = MAX([RWGameData sharedGameData].highScore, self.score);
    [[RWGameData sharedGameData]save];
    self.viewController.lastScore = self.score;
    [self.viewController loseScene:nil];
    
    
}

-(void) spawnGreen{
    NSLog(@"SPAWN GREEN");
    BOOL valid = NO;
    CGPoint location;
    while (!valid){
        int x= (arc4random() % (int)(self.screenSize.width - 130)) + 65, y = (arc4random() % (int) (self.screenSize.height - 130)) + 65;
        valid = YES;
        for(SKShapeNode *s in self.arrayOfClickableCircles){
            if(ABS(x-s.position.x)<110&&ABS(y-s.position.y)<120){
                valid = NO;
                NSLog(@"TOO CLOSE");
            }
        }
        for(SKShapeNode *s in self.arrayOfRedCircles){
            if(ABS(x-s.position.x)<120&&ABS(y-s.position.y)<130){
                valid = NO;
                NSLog(@"TOO CLOSE");
            }
        }
        location = CGPointMake(x, y);
    }
    SKNode *node;
    if (YES) {
        node = [self returnRandomCirclePhoto];
        node.position = location;
        node.xScale = 0.1;
        node.yScale = 0.1;
        if ([[node name]  isEqualToString:@"Green Node with Saved Image"]) {
            node.xScale = node.xScale * savedImageMultiplier;
            node.yScale = node.yScale * savedImageMultiplier;
        }
    }else{
        //ShapeNode
        CGRect circle = CGRectMake(-65, -65, 130.0,130.0);
        node = [[SKShapeNode alloc] init];
        
        
        node.name = @"Green Node";
        ((SKShapeNode*)node).path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
        ((SKShapeNode*)node).fillColor = SKColor.greenColor;
        ((SKShapeNode*)node).strokeColor = nil;
        ((SKShapeNode*)node).position = location;
        ((SKShapeNode*)node).xScale=0.1;
        ((SKShapeNode*)node).yScale=0.1;
        
    }
    node.zPosition = 2;
    [self addChild:node];
    [self.arrayOfClickableCircles addObject:node];
    [self.arrayOfTimesToDissappear addObject:[NSDecimalNumber numberWithDouble:CACurrentMediaTime() + self.timeToDissappear + .15]];
    
    
    double scaleNum = 1;
    if([[node name]  isEqualToString:@"Green Node with Saved Image"]){
        scaleNum = scaleNum * savedImageMultiplier;
    }
    [node runAction:[SKAction  scaleTo:scaleNum duration:0.15]completion:^{
        
    } ];
    //NSLog(@"TimeTODissappear - %f",CACurrentMediaTime() + self.timeToDissappear);
    
}
-(void)spawnRed{
    NSLog(@"SPAWN RED");
    
    BOOL valid = NO;
    CGPoint location;
    while (!valid){
        int x= (arc4random() % (int)(self.screenSize.width - 130)) + 65, y = (arc4random() % (int) (self.screenSize.height - 130)) + 65;
        valid = YES;
        for(SKShapeNode *s in self.arrayOfClickableCircles){
            if(ABS(x-s.position.x)<130 && ABS(y-s.position.y)<130){
                valid = NO;
                //NSLog(@"TOO CLOSE");
            }
        }
        for(SKShapeNode *s in self.arrayOfRedCircles){
            if(ABS(x-s.position.x)<90 && ABS(y-s.position.y)<90){
                valid = NO;
                NSLog(@"RED TOO CLOSE");
            }
        }
        location = CGPointMake(x, y);
    }
    CGRect circle = CGRectMake(-65, -65, 130.0,130.0);
    SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
    shapeNode.name = @"Red Node";
    shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
    shapeNode.fillColor = SKColor.redColor;
    shapeNode.strokeColor = nil;
    shapeNode.position = location;
    shapeNode.xScale=0.2;
    shapeNode.yScale=0.2;
    [self addChild:shapeNode];
    [self.arrayOfRedCircles addObject:shapeNode];
    [self.arrayOfRedTimesToDissappear addObject:[NSDecimalNumber numberWithDouble:CACurrentMediaTime() + self.timeToDissappear + 0.15]];
    [shapeNode runAction:[SKAction  scaleTo:1 duration:0.25]completion:^{
        
    } ];
}

-(void)spawnGolden{
    NSLog(@"SPAWN GOLDEN");
    BOOL valid = NO;
    CGPoint location;
    while (!valid){
        int x= (arc4random() % (int)(self.screenSize.width - 250)) + 125, y = (arc4random() % (int) (self.screenSize.height - 250)) + 125;
        valid = YES;
        for(SKShapeNode *s in self.arrayOfClickableCircles){
            if(ABS(x-s.position.x)<130 && ABS(y-s.position.y)<130){
                valid = NO;
                //NSLog(@"TOO CLOSE");
            }
        }
        for(SKShapeNode *s in self.arrayOfRedCircles){
            if(ABS(x-s.position.x)<90 && ABS(y-s.position.y)<90){
                valid = NO;
                NSLog(@"RED TOO CLOSE");
            }
        }
        location = CGPointMake(x, y);
    }
    CGRect circle = CGRectMake(-40, -40, 80.0,80.0);
    SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
    shapeNode.name = @"Golden Node";
    shapeNode.path = [UIBezierPath bezierPathWithOvalInRect:circle].CGPath;
    shapeNode.fillColor = [SKColor colorWithRed:255.0f green:180.0f blue:0.0f alpha:1.0f];
    shapeNode.strokeColor = nil;
    shapeNode.position = location;
    shapeNode.xScale=0.2;
    shapeNode.yScale=0.2;
    shapeNode.zPosition = 1;
    [self addChild:shapeNode];
    [shapeNode runAction:[SKAction  scaleTo:1 duration:0.25]completion:^{
        [shapeNode runAction:[SKAction scaleTo:1.2 duration:0.4] completion:^{
            [shapeNode runAction:[SKAction scaleTo:0.0f duration:.25]];
        }];
    } ];
    [shapeNode runAction:[SKAction moveByX:(arc4random()%350)-175 y:(arc4random()%350)-175 duration:.65]];
    
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if (self.started && !self.lost)
    {
        BOOL greenAdded=NO;
        if(self.spawnTime ==0){
            self.spawnTime = CACurrentMediaTime();
            [self spawnGreen];
            self.spawnTime = self.spawnTime + self.spawnRate;
            greenAdded = YES;
        }
        self.redLastNumberOfUpdates = self.redLastNumberOfUpdates + 1;
        if(self.numberOfUpdates ==600 || (self.numberOfUpdates > 600 &&(int) self.redLastNumberOfUpdates % (int)self.redSpawnRate==0)){
            //NSLog(@"SPAWN RED");
            if(!greenAdded){
                self.redLastNumberOfUpdates = 1;
                self.redSpawnRate = self.redSpawnRate -19;
                //[self spawnRed];
            }else{
                self.redLastNumberOfUpdates = self.redLastNumberOfUpdates - 1;
            }
        }
        
        
        if(self.lastTime < self.spawnTime && self.spawnTime < currentTime){
            [self spawnGreen];
            //double chanceOfRedSpawn =  1-(.30  / (1 + 20 *pow(M_E, -.0008 * (self.numberOfUpdates* 2))));
            double chanceOfRedSpawn = .6 +( self.numberOfUpdates/100000.0);
            if(self.numberOfUpdates > 600){
                //NSLog(@"Chance of Red Spawn - %f" , chanceOfRedSpawn);
                if (arc4random() %100 > chanceOfRedSpawn * 100) {
                    [self spawnRed];
                }
            }
            self.spawnTime = self.spawnTime + self.spawnRate;
            //NSLog(@"Spawn Rate - %f ",self.spawnRate );
            
        }
        self.numberOfUpdates = self.numberOfUpdates + 1;
        self.spawnRate = .75-(0.60 / (1 + 20 *pow(M_E, -.0008 * (self.numberOfUpdates+2800))));
        
        
        
        double  firstTimeToDissappear = ((NSDecimalNumber*) [self.arrayOfTimesToDissappear firstObject]).doubleValue;
        id timeInArray = [self.arrayOfTimesToDissappear firstObject];
        
        SKShapeNode *shapeToDissappear = (SKShapeNode *)[self.arrayOfClickableCircles firstObject];
        if(self.lastTime<firstTimeToDissappear && firstTimeToDissappear < currentTime){
            //NSLog(@"firstTime - %f currentTime - %f",firstTimeToDissappear,currentTime);
            double scaleNum = 0.1;
            if([[shapeToDissappear name]  isEqualToString:@"Green Node with Saved Image"]){
                scaleNum = scaleNum * savedImageMultiplier;
            }
            [shapeToDissappear runAction:[SKAction scaleTo:0 duration:scaleNum] completion:^{
                [self lose:@"You missed a green"];
                [shapeToDissappear removeFromParent];
                [self.arrayOfClickableCircles removeObject:shapeToDissappear];
            }];
            [self.arrayOfTimesToDissappear removeObject:timeInArray];
            
        }
        
        firstTimeToDissappear = ((NSDecimalNumber*) [self.arrayOfRedTimesToDissappear firstObject]).doubleValue;
        timeInArray = [self.arrayOfRedTimesToDissappear firstObject];
        
        shapeToDissappear = (SKShapeNode *)[self.arrayOfRedCircles firstObject];
        if(self.lastTime<firstTimeToDissappear && firstTimeToDissappear < currentTime){
            //NSLog(@"firstTime - %f currentTime - %f",firstTimeToDissappear,currentTime);
            [shapeToDissappear runAction:[SKAction scaleTo:0 duration:.1] completion:^{
                [shapeToDissappear removeFromParent];
                [self.arrayOfRedCircles removeObject:shapeToDissappear];
            }];
            [self.arrayOfRedTimesToDissappear removeObject:timeInArray];
            
        }
        int t = (int)self.numberOfUpdates % 100;
        if(arc4random() % 100 == t && self.numberOfUpdates > 200){
            [self spawnGolden];
        }
        
        
        
        self.timeToDissappear =ABS( 1.5 - (self.numberOfUpdates / 20000));
        //NSLog(@"Time to dissappear - %f",self.timeToDissappear);
        self.scoreLabel.text = [NSString stringWithFormat:@"Score - %d",self.score];
        self.lastTime= currentTime;
    }
}

+(NSArray*)arrayOfCircleImageNames{
    return [NSArray arrayWithObjects:@"SealFace",@"OwlFace", @"LemurFace",@"DogFace",@"DogFace2",@"BirdFace",nil];
}

-(SKSpriteNode *)returnRandomCirclePhoto
{
    NSString *imageName;
    SKSpriteNode *sprite;
    NSLog(@"Local - %d  Saved - %d",[[GameScene arrayOfCircleImageNames]count], [[RWGameData sharedGameData].takenPhotos count]);
    //int index =(arc4random()%([[GameScene arrayOfCircleImageNames]count]+[[RWGameData sharedGameData].takenPhotos count]));
    int index =(arc4random()%([[RWGameData sharedGameData].takenPhotos count])) + [[GameScene arrayOfCircleImageNames] count];
    
    
    if (index< [[GameScene arrayOfCircleImageNames]count]) {
        imageName = [[GameScene arrayOfCircleImageNames]objectAtIndex:index];
        sprite= [[SKSpriteNode alloc]initWithImageNamed:imageName];
        sprite.name = @"Green Node with Image";
    }else{
        index  = index - [[GameScene arrayOfCircleImageNames]count];
        UIImage *image = ((UIImage*)[[RWGameData sharedGameData].takenPhotos objectAtIndex:index])  ;
        image = [image imageWithSize:CGSizeMake(140, 140) andMask:[UIImage imageNamed:@"25_mask.png"]];
        sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
        sprite.name = @"Green Node with Saved Image";
    }
    
    
    sprite.size = CGSizeMake(135, 135);
    return sprite;
}






@end
