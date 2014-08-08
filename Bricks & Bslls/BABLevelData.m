//
//  BABLevelData.m
//  Bricks & Balls
//
//  Created by KaL on 8/7/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//

#import "BABLevelData.h"

@implementation BABLevelData

+ (BABLevelData *)mainData
{
    static dispatch_once_t create;
    static BABLevelData *singleton = nil;
    
    dispatch_once(&create, ^{
        
        singleton = [[BABLevelData alloc]init];
    });
    
    return singleton;
}


@end
