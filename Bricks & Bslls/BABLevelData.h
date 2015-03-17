//
//  BABLevelData.h
//  Bricks & Balls
//
//  Created by KaL on 8/7/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface BABLevelData : NSObject

+ (BABLevelData *) mainData;

@property (nonatomic) int topScore;
@property (nonatomic) int currentLevel;

- (NSDictionary *)levelInfo;

@end
