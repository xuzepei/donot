//
//  GCHelper.m
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import "GCHelper.h"
#import <UIKit/UIKit.h>
#import "RCTool.h"

@implementation GCHelper

+ (GCHelper*)sharedInstance
{
    static GCHelper* sharedInstance = nil;
    
    if(nil == sharedInstance)
    {
        @synchronized([GCHelper class])
        {
            if(nil == sharedInstance)
            {
                sharedInstance = [[GCHelper alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (BOOL)isGameCenterAvailable
{
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    //check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    
    if (self = [super init])
    {
        _gameCenterAvailable = [self isGameCenterAvailable];
        if(_gameCenterAvailable)
        {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.myScore = nil;
    self.delegate = nil;
}

- (void)authenticationChanged
{
    if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated){
        CCLOG(@"Authentication changed: player authenticated.");
        _userAuthenticated = TRUE;
        
        //[self reportScore:[RCTool getRecordByType:RT_BEST]];
        
        [self getPlayerInfo];
    }
    else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated) {
        CCLOG(@"Authentication changed: player not authenticated");
        _userAuthenticated = FALSE;
    }
}

- (void)authenticateLocalUser
{
    if(!_gameCenterAvailable)
        return;
    
    if(_userAuthenticated)
        return;
    
    CCLOG(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error){
            if(viewController != nil)
            {
                [[RCTool getRootNavigationController] presentViewController:viewController animated:YES completion:nil];
            }
            else if ([GKLocalPlayer localPlayer].isAuthenticated)
            {
                self.userAuthenticated = YES;
            }
            else
            {
                CCLOG(@"authenticate user:%@",[error localizedDescription]);
            }
        };
    } else {
        CCLOG(@"Already authenticated!");
        self.userAuthenticated = YES;
    }
}

- (BOOL)reportScore:(int64_t)score
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;

    BOOL __block b = YES;
    GKScore* reporter = [[GKScore alloc] initWithCategory:LEADERBOARD_SCORES_ID];
    reporter.value = score;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
    {
        CCLOG(@"reportScore,error:%@",error);
        
        if(error)
            b = NO;
    }];
    
    return b;
}

- (BOOL)reportPlayTimes:(int64_t)times
{
    if(NO == _userAuthenticated)
        return NO;
    
    if(NO == [RCTool isReachableViaInternet])
        return NO;
    
    BOOL __block b = YES;
    GKScore* reporter = [[GKScore alloc] initWithCategory:LEADERBOARD_PLAYTIMES_ID];
    reporter.value = times;
    [reporter reportScoreWithCompletionHandler: ^(NSError *error)
     {
         CCLOG(@"reportPlayTimes,error:%@",error);
         
         if(error)
             b = NO;
     }];
    
    return b;
}

#pragma mark - Player Info

- (void)getPlayerInfo
{
    if(NO == _userAuthenticated)
        return;
    
    if(NO == [RCTool isReachableViaInternet])
        return;
    
    if(NO == [GKLocalPlayer localPlayer].authenticated)
        return;
    
    NSArray *playerIds = [[NSArray alloc] initWithObjects:[GKLocalPlayer localPlayer].playerID, nil];
    GKLeaderboard *leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:playerIds];
    if(nil == leaderboard)
        return;
    
    leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboard.category = LEADERBOARD_SCORES_ID;
    leaderboard.range = NSMakeRange(1,1);
    
    [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error)
    {
        if(error != nil)
        {
            CCLOG(@"loadScoresWithCompletionHandler,error:%@",[error localizedDescription]);
        }
        else
        {
            if([scores count])
            {
                self.myScore = (GKScore*)[scores objectAtIndex:0];
                CCLOG(@"player's id:%@, rank:%d, score:%lld",self.myScore.playerID,self.myScore.rank,self.myScore.value);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:MYSCORE_NOTIFICATION object:nil];
            }
        }
    }];
}

@end
