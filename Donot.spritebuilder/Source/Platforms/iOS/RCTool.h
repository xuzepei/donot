//
//  RCTool.h
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface RCTool : NSObject

+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (NSDictionary*)parseToDictionary:(NSString*)jsonString;
+ (UIWindow*)frontWindow;
+ (UINavigationController*)getRootNavigationController;
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (CGFloat)systemVersion;
+ (AppController*)getAppDelegate;

+ (int)randomByType:(int)type;

+ (UIImage*)screenshotWithStartNode:(CCNode*)startNode;

#pragma mark - Get Random Number

+ (float)randFloat:(float)max min:(float)min;

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume;
+ (CGFloat)getBKVolume;

+ (void)setEffectVolume:(CGFloat)volume;
+ (CGFloat)getEffectVolume;

#pragma mark - Network
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

#pragma mark - Play Sound
+ (void)preloadEffectSound:(NSString*)soundName;
+ (void)unloadEffectSound:(NSString*)soundName;
+ (void)playEffectSound:(NSString*)soundName;

+ (void)playBgSound:(NSString*)soundName;
+ (void)pauseBgSound;
+ (void)resumeBgSound;

#pragma mark - Record

+ (int)getRecordByType:(int)type;
+ (void)setRecordByType:(int)type value:(int64_t)value;

#pragma mark - Achievement
+ (BOOL)checkAchievementByType:(int)type;
+ (void)setAchievementByType:(int)type value:(int)value;

/*
#pragma mark - Core Data
+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (void)saveCoreData;

+ (void)deleteOldData;
 */

#pragma mark - Ad
+ (void)showBannerAd:(BOOL)b;
+ (void)showInterstitialAd;

#pragma mark - Play Times

+ (void)addPlayTimes;
+ (int)getPlayTimes;

#pragma mark - UMeng

+ (void)sendStatisticInfo:(NSString*)eventName;

#pragma mark - Angry Pipe
+ (BOOL)hasChance:(int)x y:(int)y;
+ (BOOL)isAngry;
+ (BOOL)isRotated;

#pragma mark - Fit Screen Size
+ (CGSize)getScreenSize;
+ (CGRect)getScreenRect;
+ (BOOL)isIphone5;
+ (BOOL)isIpad;
+ (BOOL)isIpadMini;

#pragma mark - App Info
+ (NSString*)getAdId;
+ (NSString*)getScreenAdId;
+ (int)getScreenAdRate;
+ (NSString*)getAppURL;
+ (BOOL)isOpenAll;
+ (UIView*)getAdView;
+ (NSString*)decrypt:(NSString*)text;
+ (NSString*)getTextById:(NSString*)textId;
+ (NSArray*)getOtherApps;
+ (NSDictionary*)getAlert;
+ (void)setAlertHasBeenShown:(NSString*)alertId;
+ (BOOL)hasAlertBeenShown:(NSString*)alertId;

@end
