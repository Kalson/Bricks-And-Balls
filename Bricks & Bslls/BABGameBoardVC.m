//
//  BABGameBoardViewController.m
//  Bricks & Bslls
//
//  Created by KaL on 8/6/14.
//  Copyright (c) 2014 Kalson Kalu. All rights reserved.
//

#import "BABGameBoardVC.h"
#import "BABHeaderView.h"

//// 3 lives
//// after you hit floor start new ball and take away one life
//// once all 3 lives lost, game over alert, wtih option to restart (should restart life count)

//// score count, bricks broken add points to score count
//// create temporay label for score count

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
    
    UIView *ball;
    UIView *paddle;
    
//    int Lives;
//    int scoreBoard;
    
    BABHeaderView *headerView;
    
//    UILabel *scoreBoard;
//    UILabel *ballCount;
//
    NSMutableArray *bricks;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        bricks = [@[]mutableCopy];
        
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
//        collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        
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
        
//        Lives = 3;
//        score = 0;
        
        // alloc/init from the BAB Header View - so I can access its @property
        headerView = [[BABHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        [self.view addSubview:headerView];
//        
//        scoreBoard = [[UILabel alloc]initWithFrame:CGRectMake(10,SCREEN_HEIGHT - 215, 100, 30)];
//        scoreBoard.text = @"Score: 0";
//        [self.view addSubview:scoreBoard];
//        
//        ballCount = [[UILabel alloc]initWithFrame:CGRectMake(10,SCREEN_HEIGHT - 195, 100, 30)];
//        ballCount.text = @"Lives: 3";
//        [self.view addSubview:ballCount];
//    
       
        
    
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
    
    [self resetBricks];
    
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
    
     [self createNewBall];
    
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    // When the ball hits the floor
    if ([@"floor" isEqualToString:(NSString *)identifier])
    {
        UIView *ballItem = (UIView *)item;
        
        [collisionBehavior removeItem:ballItem];
        [ballItem removeFromSuperview];
        
        // ball dies, lose life, create new ball
        
        // here 3 balls
        // Balls --;
//        ballCount.text = [NSString stringWithFormat:@"Lives: %d",headerView.lives];
        
        if (headerView.lives > 0)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You lost a Life" message:nil delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [alert show];
            
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game Over" message:@"Ur Out of Lives" delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
            [alert show];
        }
        
        // here 4 balls
        headerView.lives --;
        
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    // brick collision
    for (UIView *brick in [bricks copy])
    {
        if ([item1 isEqual:brick] || [item2 isEqual:brick])
        {
            headerView.score +=100;
//            scoreBoard.text = [NSString stringWithFormat:@"Score: %d",headerView.score];
            
            [collisionBehavior removeItem:brick];
            [gravityBehavior addItem:brick];
            
            [bricks removeObjectIdenticalTo:brick];
            
            [UIView animateWithDuration:0.3 animations:^{
                brick.alpha = 0;
            } completion:^(BOOL finished) {
                [brick removeFromSuperview];
                
               
                
                
            }];
            
            
        }
    }
}

- (void)resetBricks
{
    
    for (UIView *brick in bricks) {
        [brick removeFromSuperview];
        [collisionBehavior removeItem:brick];
        [brickItemBehavior removeItem:brick];
        
    }
    int colCount = 7;
    int rowCount = 4;
    int brickSpacimg = 8;
    //    int ballCount = 3;
    
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
            brick.backgroundColor = [UIColor lightGrayColor];
            [self.view addSubview:brick];
            
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
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[ball] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(0.05, -0.05);
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
        [self createNewBall];
        [self resetBricks];
        headerView.score = 0;
//        scoreBoard.text = @"Score: 0";
        headerView.lives = 3;
//        ballCount.text = @"Lives: 3";
        

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
