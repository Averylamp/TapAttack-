//
//  RWGameData.m
//  GreenRedBlackGame
//
//  Created by Avery Lamp on 1/2/15.
//  Copyright (c) 2015 Avery Lamp. All rights reserved.
//

#import "RWGameData.h"

@implementation RWGameData

static NSString* const SSGameDataHighScoreKey = @"highScore";
static NSString* const SSGameDataPilotPhotoKey = @"pilotPhoto";
-(void)reset
{

}
+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

-(NSArray *)takenPhotos{
    if(!_takenPhotos){
        NSLog(@"Here");
        _takenPhotos = [[NSArray alloc]init];
    }
    return _takenPhotos;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeDouble:self.highScore forKey: SSGameDataHighScoreKey];
    if (self.takenPhotos) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.takenPhotos];
        [aCoder encodeObject:data forKey: SSGameDataPilotPhotoKey];
    }
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        _highScore = [decoder decodeDoubleForKey: SSGameDataHighScoreKey];
        NSData* imageData = [decoder decodeObjectForKey: SSGameDataPilotPhotoKey];
        if (imageData) {
            self.takenPhotos= [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
        }
    }
    return self;
}
+(instancetype)loadInstance
{
    NSData* decodedData = [NSData dataWithContentsOfFile: [RWGameData filePath]];
    if (decodedData) {
        RWGameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[RWGameData alloc] init];
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gameData"];
    }
    return filePath;
}

-(void)save
{
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[RWGameData filePath] atomically:YES];
}
@end
