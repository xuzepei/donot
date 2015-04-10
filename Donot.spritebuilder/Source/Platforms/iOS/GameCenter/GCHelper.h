//
//  GCHelper.h
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate <NSObject>

@optional
- (void)matchStarted;
- (void)matchEnded:(id)token;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;


@end

@interface GCHelper : NSObject

@property(assign)BOOL userAuthenticated;
@property(assign, readonly)BOOL gameCenterAvailable;
@property(nonatomic,strong)GKScore* myScore;
@property(nonatomic,weak)id<GCHelperDelegate> delegate;

+ (GCHelper*)sharedInstance;
- (void)authenticateLocalUser;
- (BOOL)reportScore:(int64_t)score;
- (BOOL)reportPlayTimes:(int64_t)times;
- (void)getPlayerInfo;

@end
