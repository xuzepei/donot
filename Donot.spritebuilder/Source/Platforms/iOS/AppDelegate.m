/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"

#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "GameScene.h"
#import "RCHttpRequest.h"
#import "GCHelper.h"

#define APP_ALERT 113

@implementation AppController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"];
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive:application];
    
    //推送设置
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    
    
    [[GCHelper sharedInstance] authenticateLocalUser];
    
    self.showFullScreenAd = YES;
    [self getAppInfo];
}

- (CCScene*) startScene
{
    return [CCBReader loadAsScene:@"MainScene"];
    //return [RCGameScene scene];
}


#pragma mark - App Info

- (void)getAppInfo
{
    NSString* urlString = APP_INFO_URL;
    
    RCHttpRequest* temp = [RCHttpRequest sharedInstance];
    [temp request:urlString delegate:self resultSelector:@selector(finishedGetAppInfoRequest:) token:nil];
}

- (void)doAlert
{
    NSDictionary* alert = [RCTool getAlert];
    if(alert)
    {
        int type = [[alert objectForKey:@"type"] intValue];
        NSString* title = [alert objectForKey:@"title"];
        NSString* message = [alert objectForKey:@"message"];
        
        NSString* b0_name = @"Cancel";
        b0_name = [alert objectForKey:@"b0_name"];
        
        NSString* b1_name = @"OK";
        b1_name = [alert objectForKey:@"b1_name"];
        
        if(0 == type)
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
        else
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:b1_name,nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(APP_ALERT == alertView.tag)
    {
        NSDictionary* alert = [RCTool getAlert];
        if(alert)
        {
            [RCTool setAlertHasBeenShown:[alert objectForKey:@"id"]];
            
            int type = [[alert objectForKey:@"type"] intValue];
            if(0 == type || (1 == type && 1 == buttonIndex))
            {
                NSString* urlString = [alert objectForKey:@"url"];
                if([urlString length])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
        }
    }
}

#pragma mark - AdMob

- (void)finishedGetAppInfoRequest:(NSString*)jsonString
{
    if(0 == [jsonString length])
    {
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
        
        return;
    }
    
    NSDictionary* result = [RCTool parseToDictionary:[RCTool decrypt:jsonString]];
    if(result && [result isKindOfClass:[NSDictionary class]])
    {
        //保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"app_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self doAlert];
        
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
    }
    
}

- (void)initAdMob
{
    NSString* adId = [RCTool getAdId];
    if(0 == [adId length])
        return;
    
    if(_banner)
    {
        [_banner removeFromSuperview];
        _banner.delegate = nil;
        _banner = nil;
    }
    
    _banner = [[GADBannerView alloc]
               initWithAdSize:kGADAdSizeSmartBannerPortrait];
    
    _banner.adUnitID = [RCTool getAdId];
    _banner.delegate = self;
    _banner.rootViewController = [RCTool getRootNavigationController].topViewController;
    [_banner loadRequest:[GADRequest request]];
}

- (void)getAD
{
    NSLog(@"getAD");
    
    if(self.banner)
    {
        [self.banner removeFromSuperview];
        self.banner = nil;
    }
    
    self.interstitial = nil;
    
    [self initAdMob];
    
    [self getAdInterstitial];
}

#pragma mark - GADBannerDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidReceiveAd");
    
//    [[RCTool getRootNavigationController].topViewController.view addSubview:bannerView];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"didFailToReceiveAdWithError");

    [self performSelector:@selector(initAdMob) withObject:nil afterDelay:10];
}

- (void)getAdInterstitial
{
    if(nil == _interstitial)
    {
        _interstitial = [[GADInterstitial alloc] init];
        _interstitial.adUnitID = [RCTool getScreenAdId];
        _interstitial.delegate = self;
    }
    
    [_interstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd");
    
    if(self.showFullScreenAd)
    {
        //self.showFullScreenAd = NO;
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FULLSCREENAD_NOTIFICATION object:nil userInfo:nil];
        
        //[RCTool showInterstitialAd:[RCTool getRootNavigationController].topViewController];
    }
    
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    [self performSelector:@selector(getAdInterstitial) withObject:nil afterDelay:10];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    _interstitial = nil;
    [self getAdInterstitial];
}

- (void)showInterstitialAd:(UIViewController*)rootViewController
{
    if(_interstitial && _interstitial.isReady)
    {
        [_interstitial presentFromRootViewController:rootViewController];
    }
}

@end
