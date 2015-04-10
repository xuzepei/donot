#import "MainScene.h"
#import "GCHelper.h"

typedef enum
{
    ST_HIDE = 0,
    ST_SHOW
}ShowType;

@implementation MainScene

- (id)init
{
    if(self = [super init])
    {
        CCLOG(@"call init function");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScore:) name:MYSCORE_NOTIFICATION object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

- (void)onEnter
{
    [super onEnter];
    
    //[self animate];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [RCTool showBannerAd:NO];
    
    [[GCHelper sharedInstance] reportScore:[RCTool getRecordByType:RT_BEST]];
    
    [self updatePlayerInfo];
    
    [self updateScore];
    
    [self animateTo:ST_SHOW];
    
    [self showAd];
}

- (void)showAd
{
    static int i = 1;
    
    int rate = [RCTool getScreenAdRate];
    
    if(0 == i%rate)
    {
        [RCTool showInterstitialAd];
    }
    
    i++;
}

- (void)updateScore
{
    if(_scoreLabel)
    {
        int score = [RCTool getRecordByType:RT_BEST];
        NSString* scoreStr = [NSString stringWithFormat:@"Best %d",score];
        if(score > 9999999)
            scoreStr = [NSString stringWithFormat:@"Best %d+",score];
        
        _scoreLabel.string = scoreStr;
    }
}

- (void)animateTo:(ShowType)type
{
    if(nil == _menuBar || nil == _bird || nil == _scoreBar)
        return;
    
    if(type == ST_SHOW && _menuBar.position.y != 0)
    {
        //Menu Bar
        CGPoint oldPoint = _menuBar.position;
        id moveUp = [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(oldPoint.x, 0)];
        [_menuBar runAction:moveUp];
        
        //Score Bar
        oldPoint = _scoreBar.position;
        id moveDown = [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(oldPoint.x, 88/100.0)];
        [_scoreBar runAction:moveDown];
        
        //Bird
        id fadeIn = [CCActionFadeIn actionWithDuration:0.3];
        [_bird runAction:fadeIn];
        
        //TapLabel
        [self showTapLabel];
        
    }
    else if(type == ST_HIDE)
    {
        //Menu Bar
        CGPoint oldPoint = _menuBar.position;
        id moveDown = [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(oldPoint.x, -15/100.0)];
        id block = [CCActionCallBlock actionWithBlock:^{
            [self goToGameScene];
        }];
        id sequence = [CCActionSequence actionWithArray:@[moveDown,block]];
        
        [_menuBar runAction:sequence];
        
        
        //Score Bar
        oldPoint = _scoreBar.position;
        id moveUp = [CCActionMoveTo actionWithDuration:0.3 position:CGPointMake(oldPoint.x, 100/100.0)];
        [_scoreBar runAction:moveUp];
        
        //Bird
        id fadeOut = [CCActionFadeOut actionWithDuration:0.3];
        [_bird runAction:fadeOut];
        
        //TapLabel
        [_tapLabel runAction:[fadeOut copy]];
    }
    
}

- (void)showTapLabel
{
    if(nil == _tapLabel)
        return;
    
    _tapLabel.opacity = 1.0;
    
    id blink = [CCActionBlink actionWithDuration:0.7 blinks:1];
    id forever = [CCActionRepeatForever actionWithAction:blink];
    [_tapLabel runAction:forever];
    
    id delay = [CCActionDelay actionWithDuration:0.7];
    id block = [CCActionCallBlock actionWithBlock:^{
        CGFloat x = [RCTool randFloat:0.75 min:0.70];
        CGFloat y = [RCTool randFloat:0.65 min:0.6];
        _tapLabel.position = ccp(x, y);
        
        CGFloat rotation = [RCTool randFloat:30 min:-30];
        _tapLabel.rotation = rotation;
    }];
    id sequence = [CCActionSequence actionWithArray:@[delay,block]];
    id forever2 = [CCActionRepeatForever actionWithAction:sequence];
    [_tapLabel runAction:forever2];
}

- (void)clickedShareButton
{
    CCLOG(@"clickedShareButton");
    [self performSelector:@selector(share) withObject:nil afterDelay:0.1];

}

- (void)clickedScoreButton
{
    CCLOG(@"clickedScoreButton");
    
    [self showLeaderboard];
}

- (void)goToGameScene
{
    CCScene *gameScene = [CCBReader loadAsScene:@"GameScene"];
    [[CCDirector sharedDirector] replaceScene:gameScene];
    //id transition = [CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:1.0];
    //[[CCDirector sharedDirector] replaceScene:gameScene withTransition:transition];
}

- (void)share
{
    NSMutableArray* itemsToShare = [[NSMutableArray alloc] init];
    
    NSArray* excludedActivityTypes;
    if([RCTool systemVersion] >= 7.0)
    {
        excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList];
    }
    else{
        excludedActivityTypes = @[UIActivityTypePrint,UIActivityTypeAssignToContact,UIActivityTypeCopyToPasteboard,UIActivityTypeSaveToCameraRoll];
    }
    
    UIImage* screen = [self copyScreen];
    if(screen)
        [itemsToShare addObject:screen];
    
    NSString* rank = @"";
    if([GCHelper sharedInstance].myScore)
    {
        int i = [GCHelper sharedInstance].myScore.rank;
        if(i > 0)
            rank = [NSString stringWithFormat:@"my rank in Game Center is #%d, ",i];
    }
    
    NSString* scoreStr = @"";
    int bestScore = [RCTool getRecordByType:RT_BEST];
    if(bestScore > 1)
        scoreStr = [NSString stringWithFormat:@"%d points",bestScore];
    else
        scoreStr = [NSString stringWithFormat:@"%d point",bestScore];
    
    NSString* text = [NSString stringWithFormat:@"Hey, I'm playing with Don't Duang~! \r\n\r\nI scored %@, %@do you dare to compare?\r\n\r\n%@",scoreStr,rank,[RCTool getAppURL]];
    
    
    if([text length])
        [itemsToShare addObject:text];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    //if([RCTool systemVersion] >= 8)
    //{
       if([activityViewController respondsToSelector:@selector(popoverPresentationController)])
        activityViewController.popoverPresentationController.sourceView = [RCTool getRootNavigationController].topViewController.view;
    //}
    [[RCTool getRootNavigationController] presentViewController:activityViewController animated:YES completion:^{
    }];
}

- (UIImage*)copyScreen
{
    CCScene*scene = [[CCDirector sharedDirector] runningScene];
    CCNode *n = [scene.children objectAtIndex:0];
    return [RCTool screenshotWithStartNode:n];
}

#pragma mark - Touch Events

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //[super touchBegan:touch withEvent:event];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //[super touchEnded:touch withEvent:event];
    
    [self animateTo:ST_HIDE];
}

#pragma mark - GameCenter

- (void)updatePlayerInfo
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        return;
    }
    
    [[GCHelper sharedInstance] getPlayerInfo];
}

- (void)showGameCenter
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        [RCTool showAlert:@"Hint" message:@"Need sign in Game Center first!"];
        return;
    }
    
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        //gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        [[RCTool getRootNavigationController] presentViewController: gameCenterController animated: YES
                                                         completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController
                                           *)gameCenterViewController
{
    [[RCTool getRootNavigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)showLeaderboard
{
    if(NO == [GCHelper sharedInstance].userAuthenticated)
    {
        [RCTool showAlert:@"Hint" message:@"Need sign in Game Center first!"];
        return;
    }
    
    GKLeaderboardViewController* leaderboardController = [[GKLeaderboardViewController alloc] init];
    if(leaderboardController != NULL)
    {
        leaderboardController.category = LEADERBOARD_SCORES_ID;
        leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardController.leaderboardDelegate = self;
        [[RCTool getRootNavigationController] presentViewController:leaderboardController animated:YES completion:^{}];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [[RCTool getRootNavigationController] dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)updateScore:(NSNotification*)notification
{
    if([GCHelper sharedInstance].myScore)
    {
        [RCTool setRecordByType:RT_BEST value:[GCHelper sharedInstance].myScore.value];
        [self updateScore];
    }
}

@end
