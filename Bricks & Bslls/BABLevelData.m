//
//  BABLevelData.m
//  Bricks & Balls
//
//  Created by KaL on 8/7/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//

#import "BABLevelData.h"

@implementation BABLevelData
{
    NSArray * levels;
}

+ (BABLevelData *)mainData
{
    static dispatch_once_t create;
    static BABLevelData *singleton = nil;
    
    dispatch_once(&create, ^{
        
        // init is the instance method that gets created once
        singleton = [[BABLevelData alloc]init];
    });
    
    return singleton;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        // now to retrive the save data
            NSUserDefaults *nsDefaults = [NSUserDefaults standardUserDefaults];
        self.topScore = (int)[nsDefaults integerForKey:@"topScore"];
        
        levels = @[
                   @{
                       @"cols": @7,
                       @"rows": @2
                     },
                   @{
                       @"cols": @7,
                       @"rows": @3
                       },
                   @{
                       @"cols": @7,
                       @"rows": @3
                       }
                   
                   ];
    }
    return self;
}

- (void)setTopScore:(int)topScore
{
    _topScore = topScore;
    
    NSUserDefaults *nsDefaults = [NSUserDefaults standardUserDefaults];
    [nsDefaults setInteger:topScore forKey:@"topScore"];
    [nsDefaults synchronize]; // synchronize saves it
}

- (void)setCurrentLevel:(int)currentLevel
{
    _currentLevel = currentLevel;
    
    if (currentLevel >= levels.count - 1)
    {
        _currentLevel = 0;
    }
}

- (NSDictionary *)levelInfo
{
    return levels[self.currentLevel];
    // if currentLevel equals 0 will get the first dictionary
}

@end
