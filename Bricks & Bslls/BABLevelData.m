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
        levels = @[
                   @{
                       @"cols": @7,
                       @"rows": @3
                     },
                   @{
                       @"cols": @7,
                       @"rows": @4
                       },
//                   @{
//                       @"cols": @7,
//                       @"rows": @4
//                       },
                   
                   ];
    }
    return self;
}

- (NSDictionary *)levelInfo
{
    return levels[self.currentLevel];
    // if currentLevel equals 0 will get the first dictionary
}

@end
