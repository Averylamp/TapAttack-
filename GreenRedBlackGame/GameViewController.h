//
//  GameViewController.h
//  GreenRedBlackGame
//

//  Copyright (c) 2014 Avery Lamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GameViewController : UIViewController
@property   CGSize screenSize;
-(void)menu:(UIButton *)sender;
-(void)play:(UIButton *)sender;
@end
