//
//  BABHeaderView.m
//  Bricks & Balls
//
//  Created by KaL on 8/7/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//

#import "BABHeaderView.h"
#import "BABLevelData.h"

@implementation BABHeaderView
{
    UIView *ballholder;
    UILabel *scoreLabel;
    UILabel *levelLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        ballholder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
        [self addSubview:ballholder];
        
        scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 160, 0, 150, 30)];
        scoreLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:scoreLabel];
        
        levelLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 180, 0, 190, 30)];
        levelLabel.layer.cornerRadius = 1;
        [self addSubview:levelLabel];
        
        self.lives = 3;
        self.score = 0;
        self.level = 1;
    }
    return self;
}

// must run a setter method after setting headerView.something in the view controller
- (void)setScore:(int)score
{
    _score = score;
    scoreLabel.text = [NSString stringWithFormat:@"Score : %d",score];
    
    if ([BABLevelData mainData].topScore < score) [BABLevelData mainData].topScore = score;
    // this only updates the top score if the score is higher than the top score
    
}

- (void)setLives:(int)lives
{
    _lives = lives;
    
    for (UIView *lifeBall in ballholder.subviews) {
        [lifeBall removeFromSuperview];
    }
    
    // loop through about of lives
    for (int i = 0; i < lives; i++)
    {
        // x is dynamic
        UIView *lifeBall = [[UIView alloc]initWithFrame:CGRectMake(10 + 30 * i, 10, 20, 20)];
        lifeBall.backgroundColor = [UIColor magentaColor];
        lifeBall.layer.cornerRadius = 10;
        [ballholder addSubview:lifeBall];
    }
}

- (void)setLevel:(int)level
{
    _level = level;
    levelLabel.text = [NSString stringWithFormat:@"Level : %d",level];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
