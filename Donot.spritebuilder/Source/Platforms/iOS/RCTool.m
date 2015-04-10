//
//  RCTool.m
//  BeatMole
//
//  Created by xuzepei on 5/23/13.
//
//

#import "RCTool.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "AppDelegate.h"
#import "Reachability.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation RCTool

+ (NSString*)getUserDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];

    UIWindow *frontWindow = [windows lastObject];
    return frontWindow;
}

+ (UINavigationController*)getRootNavigationController
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    return (UINavigationController*)appDelegate.navController;
}

+ (void)resizeSprite:(CCSprite*)sprite toWidth:(float)width toHeight:(float)height
{
    sprite.scaleX = width / sprite.contentSize.width;
    sprite.scaleY = height / sprite.contentSize.height;
}

+ (float)getWidthScale
{
    return WIN_SIZE.width / 320.0;
}

+ (float)getHeightScale
{
    return WIN_SIZE.height / 568.0;
}

+ (float)getValueByWidthScale:(float)value
{
    return WIN_SIZE.width*value / 320.0;
}

+ (float)getValueByHeightScale:(float)value
{
    return WIN_SIZE.height*value / 568.0;
}

+ (int)randomByType:(int)type
{
    int array[20];
    
    if(RDM_BG == type)
    {
        if([RCTool isOpenAll])
        {
            int temp[20] = {2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3};
            memcpy(array,temp,20*sizeof(int));
        }
        else
        {
            int temp[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
            memcpy(array,temp,20*sizeof(int));
        }
    }
    else if(RDM_PIPE == type){
        
            int temp[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2};
            memcpy(array,temp,20*sizeof(int));
    }
    else if(RDM_ANGRY_PIPE == type)
    {
        int temp[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3};
        memcpy(array,temp,20*sizeof(int));
    }
    else if(RDM_DUCK == type){
        if([RCTool isOpenAll])
        {
            int temp[20] = {3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5};
            memcpy(array,temp,20*sizeof(int));
        }
        else
        {
            int temp[20] = {0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2};
            memcpy(array,temp,20*sizeof(int));
        }
        
    }
    else if(RDM_LAND == type){
        int temp[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2};
        memcpy(array,temp,20*sizeof(int));
    }
    
    int size = sizeof(array)/sizeof(int);
    
    //随机排序数组
    for (NSUInteger i = 0; i < size; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = size - i;
        int n = (arc4random() % nElements) + i;
        
        int temp = array[n];
        array[n] = array[i];
        array[i] = temp;
    }
    
    int rand = arc4random()%size;
    rand = array[rand];
    return rand;
}

+ (UIImage*)screenshotWithStartNode:(CCNode*)startNode
{
    [CCDirector sharedDirector].nextDeltaTimeZero = YES;
    
    CGSize winSize = [CCDirector sharedDirector].viewSize;
    CCRenderTexture* rtx =
    [CCRenderTexture renderTextureWithWidth:winSize.width
                                     height:winSize.height];
    [rtx begin];
    [startNode visit];
    [rtx end];
    
    return [rtx getUIImage];
}

+ (NSDictionary*)parseToDictionary:(NSString*)jsonString
{
    if(0 == [jsonString length])
        return nil;
    
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(nil == data)
        return nil;
    
    NSError* error = nil;
    NSJSONSerialization* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(error)
    {
        NSLog(@"parse errror:%@",[error localizedDescription]);
        return nil;
    }
    
    if([json isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)json;
    }
    
    return nil;
}

#pragma mark -

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: @"Ok"
										  otherButtonTitles: nil];
    alert.tag = 110;
	[alert show];
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}

+ (AppController*)getAppDelegate;
{
    UIApplication *app = [UIApplication sharedApplication];
    return (AppController*)app.delegate;
}

#pragma mark - Ad

+ (void)showBannerAd:(BOOL)b
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    if(appDelegate.banner && b)
    {
        CGRect rect = appDelegate.banner.frame;
        rect.origin.y = [RCTool getScreenSize].height - rect.size.height;
        appDelegate.banner.frame = rect;
        
        [[RCTool getRootNavigationController].topViewController.view addSubview:appDelegate.banner];
    }
    else if(appDelegate.banner)
        [appDelegate.banner removeFromSuperview];
        
}

+ (void)showInterstitialAd
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    [appDelegate showInterstitialAd:[RCTool getRootNavigationController].topViewController];
}

#pragma mark - Get Random Number

+ (float)randFloat:(float)max min:(float)min
{
    float temp = (float)arc4random()/UINT_MAX;
    return min + (max-min)*temp;
}

#pragma mark - Settings

+ (void)setBKVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"bk_volume"];
    [temp synchronize];
}

+ (CGFloat)getBKVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"bk_volume"];
    if(value)
        return [value floatValue];
    
    return 0.5;
}

+ (void)setEffectVolume:(CGFloat)volume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setFloat:volume forKey:@"effect_volume"];
    [temp synchronize];
}

+ (CGFloat)getEffectVolume
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [temp objectForKey:@"effect_volume"];
    if(value)
        return [value floatValue];
    
    return 1.0;
}

#pragma mark - Network

+ (BOOL)isReachableViaWiFi
{
	Reachability* wifiReach = [Reachability reachabilityForLocalWiFi];
	[wifiReach startNotifier];
	NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	return NO;
}

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

#pragma mark - Play Sound

+ (void)preloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[OALSimpleAudio sharedInstance] preloadEffect:soundName];
}

+ (void)unloadEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[OALSimpleAudio sharedInstance] unloadEffect:soundName];
}

+ (void)playEffectSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[OALSimpleAudio sharedInstance] setEffectsVolume:[RCTool getEffectVolume]];
    
    [[OALSimpleAudio sharedInstance] playEffect:soundName];
}

+ (void)playBgSound:(NSString*)soundName
{
    if(0 == [soundName length])
        return;
    
    [[OALSimpleAudio sharedInstance] setBgVolume:[RCTool getBKVolume]];
    
    [[OALSimpleAudio sharedInstance] playBg:soundName loop:YES];
}

+ (void)pauseBgSound
{
    [[OALSimpleAudio sharedInstance] stopBg];
}

#pragma mark - Record

+ (int)getRecordByType:(int)type
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* key = [NSString stringWithFormat:@"RT_%d",type];
    if(type == RT_SCORE || type == RT_BEST)
    {
        NSString* leaderboardId = [RCTool md5:LEADERBOARD_SCORES_ID];
        key = [NSString stringWithFormat:@"RT_%d_%@",type,leaderboardId];
    }
    
    
    NSString* encryptedString = [defaults objectForKey:key];
    if(0 == [encryptedString length])
        return 0;
    
    return [[RCTool decrypt:encryptedString] intValue];
}

+ (void)setRecordByType:(int)type value:(int64_t)value
{
    NSString* key = [NSString stringWithFormat:@"RT_%d",type];
    if(type == RT_SCORE || type == RT_BEST)
    {
        NSString* leaderboardId = [RCTool md5:LEADERBOARD_SCORES_ID];
        key = [NSString stringWithFormat:@"RT_%d_%@",type,leaderboardId];
    }
    
    NSString* encryptedString = [RCTool encrypt:[NSString stringWithFormat:@"%lld",value]];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedString forKey:key];
    [defaults synchronize];
}

#pragma mark - Achievement

+ (BOOL)checkAchievementByType:(int)type
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [NSString stringWithFormat:@"AT_%d",type];
    int value = [[defaults objectForKey:key] intValue];
    switch (type) {
        case AT_ESCAPE:
        {
            if(value)
                return YES;
            
            break;
        }
        case AT_SHOOTER:
        {
            if(value > 30)
                return YES;
            
            break;
        }
        case AT_MARATHON:
        {
            //value = [RCTool getRecordByType:RT_DISTANCE];
            if(value > 42195)
                return YES;
            
            break;
        }
        case AT_CAKE:
        {
            if(value > 2000)
                return YES;
            
            break;
        }
        case AT_KUNGFU:
        {
            if(value > 300)
                return YES;
            
            break;
        }
        case AT_MILLIONAIRE:
        {
            if(value >= 50000)
                return YES;
            else
            {
                //value = [RCTool getRecordByType:RT_MONEY];
                if(value >= 20000)
                    return YES;
            }
            
            break;
        }
        default:
            break;
    }
    
    return NO;
}

+ (void)setAchievementByType:(int)type value:(int)value
{
    NSString* key = [NSString stringWithFormat:@"AT_%d",type];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    int temp = [[defaults objectForKey:key] intValue];
    switch (type) {
        case AT_ESCAPE:
        {
            temp = value;
            break;
        }
        case AT_SHOOTER:
        {
            if(temp <= 30)
            {
                temp += value;
            }
            
            break;
        }
        case AT_MARATHON:
        {
            break;
        }
        case AT_CAKE:
        {
            if(temp <= 2000)
            {
                if(-1 == value)
                {
                    temp = 0;
                }
                else
                    temp = value;
            }
            break;
        }
        case AT_KUNGFU:
        {
            if(temp <= 300)
            {
                if(-1 == value)
                {
                    temp = 0;
                }
                else
                    temp += value;
            }
            
            break;
        }
        case AT_MILLIONAIRE:
        {
            if(temp <= 50000)
            {
                temp += value;
            }
            break;
        }
        default:
            break;
    }
    
    [defaults setObject:[NSNumber numberWithInt:temp] forKey:key];
    [defaults synchronize];
}

/*
#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
    if(nil == context)
        context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
	//															initWithFetchRequest:fetchRequest
	//															managedObjectContext:context
	//															sectionNameKeyPath:nil
	//															cacheName:@"Root"];
	//
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (void)saveCoreData
{
	AppController* appDelegate = (AppController*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil)
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error])
		{
            
        }
    }
}

+ (void)deleteOldData
{
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
    //    NSArray* translations = [RCTool getExistingEntityObjectsForName:@"Translation" predicate:nil sortDescriptors:nil];
    //    NSManagedObjectContext* context = [RCTool getManagedObjectContext];
    //    for(Translation* translation in translations)
    //    {
    //        [context deleteObject:translation];
    //    }
    //    [RCTool saveCoreData];
    //
    //    NSString* recorDirectoryPath = [NSString stringWithFormat:@"%@/record",[RCTool getUserDocumentDirectoryPath]];
    //    [RCTool removeFile:recorDirectoryPath];
    //
    //    NSString* ttsDirectoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    //    [RCTool removeFile:ttsDirectoryPath];
}
 */

#pragma mark - Ad
/*
+ (void)showAd:(BOOL)b
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    if(appDelegate.adMobAd && appDelegate.adMobAd.superview)
    {
        if(b)
        {
//            if([RCTool getRecordByType:RT_BEST] <= 2)
//                return;
            
            CGRect temp = appDelegate.adMobAd.frame;
            if(temp.origin.y == [RCTool getScreenSize].height - appDelegate.adMobAd.frame.size.height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adMobAd.frame;
                rect.origin.y = [RCTool getScreenSize].height - appDelegate.adMobAd.frame.size.height;
                appDelegate.adMobAd.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdMobVisible = YES;
            }];
        }
        else
        {
            CGRect temp = appDelegate.adMobAd.frame;
            if(temp.origin.y == [RCTool getScreenSize].height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adMobAd.frame;
                rect.origin.y = [RCTool getScreenSize].height;
                appDelegate.adMobAd.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdMobVisible = NO;
            }];
        }
    }
    
    if(appDelegate.isAdMobVisible)
        return;
    
    if(appDelegate.adView && appDelegate.adView.superview)
    {
        if(b)
        {
//            if([RCTool getRecordByType:RT_BEST] <= 2)
//                return;
            
            CGRect temp = appDelegate.adView.frame;
            if(temp.origin.y == [RCTool getScreenSize].height - appDelegate.adView.frame.size.height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adView.frame;
                rect.origin.y = [RCTool getScreenSize].height - appDelegate.adView.frame.size.height;
                appDelegate.adView.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdViewVisible = YES;
            }];
        }
        else
        {
            CGRect temp = appDelegate.adView.frame;
            if(temp.origin.y == [RCTool getScreenSize].height)
                return;
            
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = appDelegate.adView.frame;
                rect.origin.y = [RCTool getScreenSize].height;
                appDelegate.adView.frame = rect;
            }completion:^(BOOL finished) {
                appDelegate.isAdViewVisible = NO;
            }];
        }
    }
}

+ (void)showInterstitialAd
{
    AppController* appDelegate =(AppController*)[UIApplication sharedApplication].delegate;
    [appDelegate showInterstitialAd:nil];
}
*/

#pragma mark - Play Times

+ (void)addPlayTimes
{
    int64_t oldPlayTimes = [RCTool getRecordByType:RT_PLAYTIMES];
    oldPlayTimes += 1;
    [RCTool setRecordByType:RT_PLAYTIMES value:oldPlayTimes];
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* date = [userDefaults objectForKey:@"date"];
    if(nil == date)
    {
        int count = [[userDefaults objectForKey:@"play_count"] intValue];
        count++;
        [userDefaults setObject:[NSNumber numberWithDouble:now] forKey:@"date"];
        [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
        [userDefaults synchronize];
    }
    else
    {
        NSTimeInterval last = [date doubleValue];
        if(last + 24*60*60 >= now)
        {
            int count = [[userDefaults objectForKey:@"play_count"] intValue];
            count++;
            [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
            [userDefaults synchronize];
        }
        else
        {
            int count = 1;
            [userDefaults setObject:[NSNumber numberWithDouble:now] forKey:@"date"];
            [userDefaults setObject:[NSNumber numberWithInt:count] forKey:@"play_count"];
            [userDefaults synchronize];
        }
    }
    
    
}

+ (int)getPlayTimes
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:@"play_count"] intValue];
}

#pragma mark - UMeng

+ (void)sendStatisticInfo:(NSString*)eventName
{
    if(0 == [eventName length])
        return;

    //[MobClick event:eventName];
}

#pragma mark - Angry Pipe

+ (BOOL)hasChance:(int)x y:(int)y
{
    if(x >= y)
        return YES;
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for(int i = 0; i < y; i++)
    {
        int value = 0;
        if(i < x)
            value = 1;
        [array addObject:[NSNumber numberWithInt:value]];
    }
    
    //随机排序数组
    int i = [array count];
    while(--i > 0) {
        int j = arc4random() % (i+1);
        [array exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    
    int rand = arc4random()%[array count];
    NSNumber* number = [array objectAtIndex:rand];
    if(1 == [number intValue])
        return YES;
    
    return NO;
}

+ (BOOL)isAngry
{
    BOOL isAngry = NO;
    int score = [RCTool getRecordByType:RT_SCORE];
    if(score >= 20)
    {
        isAngry = [RCTool hasChance:1 y:20];
    }
    
    return isAngry;
}

+ (BOOL)isRotated
{
    BOOL b = NO;
    int score = [RCTool getRecordByType:RT_SCORE];
    if(score >= 30)
    {
        b = [RCTool hasChance:1 y:10];
    }
    else if(score >= 20)
    {
        b = [RCTool hasChance:1 y:20];
    }

    return b;
}

#pragma mark - Fit Screen Size

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isIpad
{
    UIDevice* device = [UIDevice currentDevice];
    if(device.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        return NO;
    }
    else if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isIpadMini
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if([platform length])
    {
        if([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"])
            return YES;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [UIScreen mainScreen].scale == 1)
        {
            // old iPad
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - App Info

+ (NSString*)getAdId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_id = [app_info objectForKey:@"ad_id"];
        if([ad_id length])
            return ad_id;
    }
    
    return AD_ID;
}

+ (NSString*)getScreenAdId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_id = [app_info objectForKey:@"mediation_id"];
        if(0 == [ad_id length])
            ad_id = [app_info objectForKey:@"screen_ad_id"];
        
        if([ad_id length])
            return ad_id;
    }
    
    return SCREEN_AD_ID;
}

+ (int)getScreenAdRate
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* ad_rate = [app_info objectForKey:@"screen_ad_rate"];
        if([ad_rate intValue] > 0)
            return [ad_rate intValue];
    }
    
    return SCREEN_AD_RATE;
}

+ (NSString*)getAppURL
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* link = [app_info objectForKey:@"link"];
        if([link length])
            return link;
    }
    
    return APP_URL;
}

+ (BOOL)isOpenAll
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* openall = [app_info objectForKey:@"openall"];
        if([openall isEqualToString:@"1"])
            return YES;
    }
    
    return NO;
}

+ (UIView*)getAdView
{
//    RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
//    
//    if(appDelegate.adMobAd.alpha)
//    {
//        UIView* adView = appDelegate.adMobAd;
//        if(adView)
//            return adView;
//    }
    
    return nil;
}

+ (NSString*)decryptUseDES:(NSString*)cipherText key:(NSString*)key {
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[4096];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    // IV 偏移量不需使用
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          4096,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

+ (NSString *)encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[4096];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          4096,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }else{
        NSLog(@"DES加密失败");
    }
    return plainText;
}

+ (NSString *)encrypt:(NSString*)text
{
    if(0 == [text length])
        return @"";
    
    NSString* key = SECRET_KEY;
    NSString* encryptString = [RCTool encryptUseDES:text key:key];
    
    if([encryptString length])
        return encryptString;
    
    return nil;
}

+ (NSString*)decrypt:(NSString*)text
{
    if(0 == [text length])
        return @"";
    
    NSString* key = SECRET_KEY;
    NSString* encrypt = text;
    NSString* decryptString = [RCTool decryptUseDES:encrypt key:key];
    
    if([decryptString length])
        return decryptString;
    
    return @"";
}

+ (NSString*)getTextById:(NSString*)textId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* text_dict = [app_info objectForKey:@"text_dict"];
        if([text_dict isKindOfClass:[NSDictionary class]])
        {
            if([RCTool isOpenAll])
            {
                NSString* text = [text_dict objectForKey:textId];
                if([text length])
                    return text;
            }
        }
    }
    
    if([textId isEqualToString:@"ti_0"])
    {
        return @"设置";
    }
    else if([textId isEqualToString:@"ti_1"])
    {
        return @"精品应用推荐";
    }
    else if([textId isEqualToString:@"ti_2"])
    {
        return @"点击清除缓存";
    }
    else if([textId isEqualToString:@"ti_3"])
    {
        return @"去评价";
    }
    else if([textId isEqualToString:@"ti_4"])
    {
        return @"意见反馈";
    }
    else if([textId isEqualToString:@"ti_5"])
    {
        return @"缓存已成功清除";
    }
    else if([textId isEqualToString:@"ti_6"])
    {
        return @"下拉可以刷新了";
    }
    else if([textId isEqualToString:@"ti_7"])
    {
        return @"松开马上刷新了";
    }
    else if([textId isEqualToString:@"ti_8"])
    {
        return @"正在帮你刷新中...";
    }
    else if([textId isEqualToString:@"ti_9"])
    {
        return @"上拉可以加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_10"])
    {
        return @"松开马上加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_11"])
    {
        return @"正在帮你加载中...";
    }
    
    return @"";
}

+ (NSArray*)getOtherApps
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        if([RCTool isOpenAll])
        {
            return [app_info objectForKey:@"other_apps"];
        }
    }
    
    return nil;
}

+ (NSDictionary*)getAlert
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* dict = [app_info objectForKey:@"alert"];
        
        if(dict && [dict isKindOfClass:[NSDictionary class]])
        {
            if([RCTool hasAlertBeenShown:[dict objectForKey:@"id"]])
                return nil;
            
            return dict;
        }
    }
    
    return nil;
}

+ (void)setAlertHasBeenShown:(NSString*)alertId
{
    if(0 == [alertId length])
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* array = [userDefaults objectForKey:@"alerts_have_been_shown"];
    NSMutableArray* mutableArray = [[NSMutableArray alloc] init];
    if([array count])
        [mutableArray addObjectsFromArray:array];
    [mutableArray addObject:alertId];
    [userDefaults setObject:mutableArray forKey:@"alerts_have_been_shown"];
    [userDefaults synchronize];
    
}

+ (BOOL)hasAlertBeenShown:(NSString*)alertId
{
    if(0 == [alertId length])
        return NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* array = [userDefaults objectForKey:@"alerts_have_been_shown"];
    for(NSString* temp in array)
    {
        if([temp isEqualToString:alertId])
            return YES;
    }
    
    return NO;
}


@end
