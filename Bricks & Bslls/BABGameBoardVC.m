//
//  BABGameBoardViewController.m
//  Bricks & Bslls
//
//  Created by KaL on 8/6/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//

#import "BABGameBoardVC.h"
#import "BABHeaderView.h"
#import "BABLevelData.h"

//// when gameover clear bricks and show start button /
//// creata new class called "BABLevelData" as a subclass of NSObject

//// make a method that will drop a UIView (gravity) from a broken brick like a powerup
//// listen for it to collide with paddle
//// randonly change size of paddle when powerup hit paddle


//// ball2 not recognizing the only @floor as a boundary when instead all boundary
//// UIAlertview to set for both ball1 and 2

@interface BABGameBoardVC () <UICollisionBehaviorDelegate, UIAlertViewDelegate>
@end

@implementation BABGameBoardVC
{
    // for animation
    UIDynamicAnimator *animator;
    UIDynamicItemBehavior *ballItemBehavior;
    UIDynamicItemBehavior *brickItemBehavior;
    UIGravityBehavior *gravityBehavior;
    UICollisionBehavior *collisionBehavior;
    UIAttachmentBehavior *attachmentBehavior;
    UICollisionBehavior *powerupCollision;
    UIPushBehavior *pushBehavior;
    
    UIButton *startButton;
    
    UIView *ball;
    //    NSMutableArray *balls;
    UIView *ball2;
    UIView *paddle;
    
    UIView *powerUp;
    
    int random;
    
    BABHeaderView *headerView;
    
    NSMutableArray *bricks;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        bricks = [@[]mutableCopy];
        
        //        balls = [@[]mutableCopy];
        
        
        // since were in a view controller the self.view will be the reference
        animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
        
        ballItemBehavior = [[UIDynamicItemBehavior alloc]init];
        ballItemBehavior.friction = 0;
        ballItemBehavior.elasticity = 1;
        ballItemBehavior.resistance = 0;
        ballItemBehavior.allowsRotation = NO;
        [animator addBehavior:ballItemBehavior];
        
        gravityBehavior = [[UIGravityBehavior alloc]init];
        [animator addBehavior:gravityBehavior];
        
        collisionBehavior = [[UICollisionBehavior alloc]init];
        //      collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        
        // create own boundary to know when it hits the ground
        [collisionBehavior addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, SCREEN_HEIGHT) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT + 20)];
        [collisionBehavior addBoundaryWithIdentifier:@"left wall" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, SCREEN_HEIGHT)];
        [collisionBehavior addBoundaryWithIdentifier:@"right wall" fromPoint:CGPointMake(SCREEN_WIDTH, 0) toPoint:CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
        [collisionBehavior addBoundaryWithIdentifier:@"ceiling" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(SCREEN_WIDTH, 0)];
        
        collisionBehavior.collisionDelegate = self;
        [animator addBehavior:collisionBehavior];
        
        brickItemBehavior = [[UIDynamicItemBehavior alloc]init];
        brickItemBehavior.density = 1000000;
        [animator addBehavior:brickItemBehavior];
        
        // alloc/init from the BAB Header View - so I can access its @property
        headerView = [[BABHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [self.view addSubview:headerView];
        
        powerupCollision = [[UICollisionBehavior alloc]init];
        powerupCollision.collisionDelegate = self;
        [animator addBehavior:powerupCollision];
        
        
        NSLog(@"Top Score : %d",[BABLevelData mainData].topScore);
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    paddle = [[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2.0, SCREEN_HEIGHT - 10, 100, 4)];
    paddle.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:paddle];
    
    startButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 100, (SCREEN_HEIGHT - 320) / 2.0, 100, 100)];
    [startButton setTitle:@"START" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    startButton.layer.cornerRadius = 50;
    startButton.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:startButton];
        
    //    [self resetBricks];
    
}

- (void)startGame
{
    [startButton removeFromSuperview];
    
    [self createNewBall];
    [self resetBricks];
}

- (void)startNewGame
{
    headerView.score = 0;
    headerView.lives = 3;
    
    [self.view addSubview:startButton];
    
    // re-center the paddle when reseted
    attachmentBehavior.anchorPoint = CGPointMake(SCREEN_WIDTH / 2.0, paddle.center.y);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    attachmentBehavior = [[UIAttachmentBehavior alloc]initWithItem:paddle attachedToAnchor:paddle.center];
    [animator addBehavior:attachmentBehavior];
    
    for (UIView *brick  in bricks)
    {
        [collisionBehavior addItem:brick];
        [brickItemBehavior addItem:brick];
        
    }
    
    [collisionBehavior addItem:paddle];
    [brickItemBehavior addItem:paddle];
    
    [powerupCollision addItem:paddle];
    // means only the paddle amd the powerup can collide
    
    
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    // When the ball hits the floor
    if ([@"floor" isEqualToString:(NSString *)identifier])
    {
        //        UIView *ballItem = (UIView *)item;
        //
        //        [collisionBehavior removeItem:ballItem];
        //        [ballItem removeFromSuperview];
        
        //        [balls removeObject;ballitem];
        
        
        [collisionBehavior removeItem:ball];
        [ball removeFromSuperview];
        
        
        
        // ball dies, lose life, create new ball
        
        // here 3 balls
        // Balls --;
        //        ballCount.text = [NSString stringWithFormat:@"Lives: %d",headerView.lives];
        
        if (headerView.lives > 0)
        {
            //            if (balls.count == 0) {
            //                for (UIview *ball in balls)
            //                {
            //                    [collisionBehavior removeItem:ball];
            //                    [ball removeFromSuperview];
            //                }
            //            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You lost a Life" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [alert show];
            
            [self createNewBall];
        }
        else {
            //
            ////            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game Over" message:@"Your Out of Lives" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            ////            [alert show];
            //        }
            
            // here 4 balls
            headerView.lives --;
            //
            //    } else {
            //        [collisionBehavior removeItem:ball2];
            //        //        [ball2 removeFromSuperview];
            //    }
            
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
// method b/w 2 items item 1 or 2
{
    // brick collision
    for (UIView *brick in [bricks copy])
    {
        if ([item1 isEqual:brick] || [item2 isEqual:brick])
        {
            headerView.score +=100;
            
            random = arc4random_uniform(1);
            
            NSLog(@"random # = %d",random);
            
            powerUp = [[UIView alloc]initWithFrame:CGRectMake(brick.center.x,brick.center.y, 15, 15)];
            
            if (random == 4) {
                // Big Paddle
                powerUp.backgroundColor = [UIColor greenColor];
                
            } else if (random == 1) {
                // Small Paddle
                powerUp.backgroundColor = [UIColor redColor];
                
            } else if (random == 2) {
                // Big Ball
                powerUp.backgroundColor = [UIColor brownColor];
                
            } else if  (random == 3) {
                // Small Ball
                powerUp.backgroundColor = [UIColor orangeColor];
                
            } else if (random == 0) {
                // Mutli Ball
                powerUp.backgroundColor = [UIColor blackColor];
            }
            
            
            powerUp.layer.cornerRadius = 7.5;
            [self.view addSubview:powerUp];
            [gravityBehavior addItem:powerUp];
            [powerupCollision addItem:powerUp];
            
//             powerUp.tag = arc4random(4);
            
            [collisionBehavior removeItem:brick];
            [gravityBehavior addItem:brick];
            
            [bricks removeObjectIdenticalTo:brick];
            
            [UIView animateWithDuration:0.3 animations:^{
                brick.alpha = 0;
                
                
            } completion:^(BOOL finished) {
                
                [brick removeFromSuperview];
                
                if (bricks.count == 0)
                {
                    [collisionBehavior removeItem:ball];
                    [ball removeFromSuperview];
                    
                    //                    [collisionBehavior removeItem:ball2];
                    //                    [ball2 removeFromSuperview];
                    
                    // new level
                    headerView.level ++;
                    [BABLevelData mainData].currentLevel++;
                    
                    [self startNewGame];
                }
                
                //                if (headerView.lives == 0)
                //                {
                //                    [BABLevelData mainData].currentLevel--;
                //                }
                //
            }];
            
            
        }
    }
    //    for (UIView *powerUp in [powerUps copy])
    //    {
    //
    //    }
    
    if ([item1 isEqual:powerUp] || [item2 isEqual:powerUp])
    {
        [powerupCollision removeItem:powerUp];
        [powerUp removeFromSuperview];
        
        //        [powerUps removeobjectIdenticalto:powerUp];
        NSLog(@"boom");
        
        // paddle color change
        if ([powerUp.backgroundColor isEqual:[UIColor greenColor]])
        {
            paddle.backgroundColor = [UIColor greenColor];
        } else if ([powerUp.backgroundColor isEqual:[UIColor redColor]])
        {
            paddle.backgroundColor = [UIColor redColor];
        } else if ([powerUp.backgroundColor isEqual:[UIColor brownColor]])
        {
            paddle.backgroundColor = [UIColor brownColor];
        } else if ([powerUp.backgroundColor isEqual:[UIColor orangeColor]])
        {
            paddle.backgroundColor = [UIColor orangeColor];
        } else if ([powerUp.backgroundColor isEqual:[UIColor blackColor]])
        {
            paddle.backgroundColor = [UIColor blackColor];
        }
        
        //        NSLog(@"tag %d",powerUp.tag);
        
        //        switch (powerUp.tag
        //                ) {
        //            case 0: // small paddle
        //            {
        //                CGRect frame = paddle.frame;
        //                frame.size.width = (frame.size.width < 120) ? frame.size.width - 20 : frame.size.width;
        //                paddle.frame = frame;
        //            }
        //                break;
        //
        //            case 1: // bigget paddle
        //            {
        //                [self createNewBall];
        //            }
        //            default:
        //                break;
        
        
        
        
        
        
        powerUp = nil;
        
        if (powerUp == nil)
        {
            if (random == 4) {
                // big paddle = green ball
                CGRect frame = paddle.frame;
                frame.size.width = arc4random_uniform(150) + 20;
                paddle.frame = frame; // why pass it again?
                
            } else if (random == 1) {
                // small paddle =  red ball
                CGRect frame = paddle.frame;
                frame.size.width = arc4random_uniform(20) + 20;
                paddle.frame = frame; // why pass it again?
                
            } else if (random == 2) {
                // big ball = brown ball
                CGRect frame = ball.frame;
                frame.size.width = arc4random_uniform(50) + 20;
                frame.size.height = arc4random_uniform(50) + 20;
                ball.frame = frame; // why pass it again?
                
            } else if (random == 3) {
                // small ball = orange ball
                CGRect frame = ball.frame;
                frame.size.width = arc4random_uniform(20) + 20;
                frame.size.height = arc4random_uniform(20) + 20;
                ball.frame = frame; // why pass it again?
                
            } else if (random == 0) {
                // multi ball = black ball
                ball2 = [[UIView alloc]initWithFrame:CGRectMake(paddle.center.x, SCREEN_HEIGHT - 50, 20, 20)];
                ball2.layer.cornerRadius = ball2.frame.size.width / 2.0;
                ball2.backgroundColor = [UIColor yellowColor];
                [self.view addSubview:ball2];
                
                pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ball2] mode:UIPushBehaviorModeInstantaneous];
                pushBehavior.pushDirection = CGVectorMake(0.08, -0.08);
                [animator addBehavior:pushBehavior];
                
                [collisionBehavior addItem:ball2];
                [ballItemBehavior addItem:ball2];
            }
            
        }
        
    }
}

- (void)resetBricks
{
    // brick removal
    for (UIView *brick in bricks)
    {
        [brick removeFromSuperview];
        [collisionBehavior removeItem:brick];
        [brickItemBehavior removeItem:brick];
        
    }
    // brick layout creation
    int colCount = [[[BABLevelData mainData]levelInfo][@"cols"]intValue];
    //    int colCount = 7;
    //    int rowCount = 4;
    int rowCount = [[[BABLevelData mainData]levelInfo][@"rows"]intValue];
    int brickSpacimg = 8;
    
    for (int col = 0; col < colCount; col++)
    {
        for (int row = 0; row < rowCount; row++)
        {
            float width = (SCREEN_WIDTH - (10 * (colCount + 1))) / colCount;
            float height = ((SCREEN_HEIGHT / 3) - (10 * rowCount)) / rowCount;
            
            float x = brickSpacimg + (width + 10) * col;
            float y = brickSpacimg + (height + 10) * row + 30;
            
            // create the brick
            UIView *brick = [[UIView alloc]initWithFrame:CGRectMake(x, y, width, height)];
            brick.layer.cornerRadius = brick.frame.size.width / 10.0;
            
            CGFloat hue = (arc4random() % 256 / 256.0);
            CGFloat saturation = (arc4random() % 228 / 256.0) + 0.5;
            CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
            brick.layer.borderColor = [[UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1]CGColor];
            brick.layer.borderWidth = 10;
            
            [self.view addSubview:brick];
            
            
            NSLog(@"%f %f %f",hue,saturation,brightness);
            
            
            // aad the bricks to the array
            [bricks addObject:brick];
            
            [collisionBehavior addItem:brick];
            [brickItemBehavior addItem:brick];
            
        }
    }
}

- (void)createNewBall
{
    
    // VIEW DID LOAD
    ball = [[UIView alloc]initWithFrame:CGRectMake(paddle.center.x, SCREEN_HEIGHT - 50, 20, 20)];
    ball.layer.cornerRadius = ball.frame.size.width / 2.0;
    ball.backgroundColor = [UIColor magentaColor];
    [self.view addSubview:ball];
    
    // VIEW WILL APPEAR - that the init method may not have finished
    pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ball] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0.08, -0.08);
    [animator addBehavior:pushBehavior];
    
    [collisionBehavior addItem:ball];
    [ballItemBehavior addItem:ball];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (headerView.lives > -1)
    {
        [self createNewBall];
    }
    else
    {
        // reset the game
        [self startNewGame];
        
        for (UIView *brick in bricks)
        {
            [brick removeFromSuperview];
            [collisionBehavior removeItem:brick];
            [brickItemBehavior removeItem:brick];
            //            [BABLevelData mainData].currentLevel--;
            
        }
        
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self movePaddleWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self movePaddleWithTouches:touches];
}

- (void)movePaddleWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches allObjects][0];
    CGPoint location = [touch locationInView:self.view];
    
    float guard = paddle.frame.size.width / 2.0 + 10;
    float dragX = location.x;
    
    if (dragX < guard) dragX = guard;
    if (dragX > SCREEN_WIDTH - guard) dragX = SCREEN_WIDTH - guard;
    
    attachmentBehavior.anchorPoint = CGPointMake(dragX, paddle.center.y);
    
    //    paddle.center = CGPointMake(location.x, paddle.center.y);
}

- (BOOL)prefersStatusBarHidden{return YES;}


@end
