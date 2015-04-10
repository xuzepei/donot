//
//  GameScene.m
//  Donot
//
//  Created by xuzepei on 3/22/15.
//  Copyright (c) 2015 TapGuilt. All rights reserved.
//

#import "GameScene.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GCHelper.h"

#define MAX_VELOCITY_Y 500.f
#define MIN_VELOCITY_Y -500.f

@implementation GameScene

- (id)init
{
    if(self = [super init])
    {
        self.userInteractionEnabled = YES;
        
        [RCTool preloadEffectSound:SOUND_HIT];
        [RCTool preloadEffectSound:SOUND_JUMP];
        
        //[self schedule:@selector(drop) interval:0.1];
    }
    
    return self;
}

- (void)didLoadFromCCB {
    
    [self initWorld];
    
    [self rotate];
    
    if(_bird)
        [_bird.physicsBody applyForce:ccp(0, 60000)];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [RCTool showBannerAd:YES];
}

- (void)update:(CCTime)delta
{
    //CCLOG(@"delta:%lf",delta);
    
    [self drop];
    
    
    if(_bird && _ring)
    {
        [self clampVelocity];
        
        CGSize screenSize = [RCTool getScreenSize];
        CGFloat birdY = _bird.position.y*screenSize.height;
        CGSize birdSize = [_bird contentSizeInPoints];
        CGFloat birdHeight = [_bird boundingBox].size.height;
        
        //CCLOG(@"The bird's position:%@",NSStringFromCGPoint(_bird.position));
        //CCLOG(@"The bird's size:%@",NSStringFromCGSize(birdSize));
        //CCLOG(@"The bird's height:%f",birdHeight);
        
        CGFloat ringY = _ring.position.y*screenSize.height;
        CGSize ringSize = [_ring contentSizeInPoints];
        CGFloat rightHeight = [_ring boundingBox].size.height;
        //CCLOG(@"The ring's position:%@",NSStringFromCGPoint(_ring.position));
        //CCLOG(@"The ring's size:%@",NSStringFromCGSize([_ring contentSizeInPoints]));
        //CCLOG(@"The ring's height:%f",rightHeight);
        
        CGFloat distance = fabs(birdY - ringY);
        
        if(birdY < -birdHeight)
        {
            [self over:NO up:NO];
        }
        else if(_isOut && NO == _isOver)
        {
            if(distance < rightHeight/2.0 - birdHeight)
            {
                _isOut = NO;
                _score++;
                
                //CCLOG(@"Is in,score:%d",_score);
                
                if(_scoreLabel)
                    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
                
                [self record];

                if(_score < 1)
                    _tipLabel.string = @"Get Out";
                else
                    _tipLabel.string = [NSString stringWithFormat:@"%d",_score];
            }
        }
        else if(NO == _isOut)
        {
            if(distance > rightHeight/2.0 + birdHeight)
            {
                //CCLOG(@"Is out");
                _isOut = YES;
                
                if(_score < 1)
                    _tipLabel.string = @"Get In";
                else
                    _tipLabel.string = [NSString stringWithFormat:@"%d",_score];
            }
        }
    }
}

- (void)initWorld
{
    if(_physicsWorld)
    {
        //_physicsWorld.debugDraw = TRUE;
        _physicsWorld.collisionDelegate = self;
    }
}

- (void)rotate
{
    if(_ring)
    {
        //[_ring.physicsBody applyTorque:-2000000];
        //_ring.physicsBody.angularVelocity = 1;
        //[_ring.physicsBody applyAngularImpulse:200];

        CCActionRotateBy* rotate = [CCActionRotateBy actionWithDuration:5.0f angle:360];
        [_ring runAction:[CCActionRepeatForever actionWithAction:rotate]];
    }
}

- (void)drop
{
    if(_bird)
    {
        //_bird.physicsBody.affectedByGravity = NO;
        [_bird.physicsBody applyForce:ccp(0, -4500)];//-4500
        //_bird.physicsBody.velocity = ccp(0, -100);
        //[_bird.physicsBody applyImpulse:ccp(0, -100)];
    }
}

- (void)jump
{
    if(_bird)
    {
        [RCTool playEffectSound:SOUND_JUMP];
        [_bird.physicsBody applyForce:ccp(0, 210000)];//200000
        //_bird.physicsBody.velocity = ccp(0, 300);
        //[_bird.physicsBody applyImpulse:ccp(0, 5000)];
        
        [self clampVelocity];
    }
}

- (void)over:(BOOL)needJump up:(BOOL)isUp
{
    CCLOG(@"over");
    
    if(_isOver == YES)
        return;
    
    _isOver = YES;

    
    //    if(_bird)
    //    {
    //        [_bird.physicsBody applyForce:ccp(0, 200000)];
    //        [_bird.physicsBody applyTorque:-200000];
    //    }
    //
    //    [self performSelector:@selector(over) withObject:nil afterDelay:1.0];
    //
    //    return;
    
    if(isUp)
    {
        _bird.physicsBody = nil;
        _ring.physicsBody = nil;
        
        id jump = [CCActionJumpBy actionWithDuration:0.5 position:ccp(0, 0) height:0.05 jumps:1];
        id rotate = [CCActionRotateTo actionWithDuration:0.5 angle:190];
        id fade = [CCActionFadeOut actionWithDuration:0.5];
        
        NSArray* array = [NSArray arrayWithObjects:jump,rotate,fade,nil];
        id spawn = [CCActionSpawn actionWithArray:array];
        
        id block = [CCActionCallBlock actionWithBlock:^{
            id fade = [CCActionFadeOut actionWithDuration:0.3];
            id block = [CCActionCallBlock actionWithBlock:^{
                CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
                //id transition = [CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.1];
                [[CCDirector sharedDirector] replaceScene:mainScene];
            }];
            id sequence = [CCActionSequence actionWithArray:@[fade,block]];
            [_ring runAction:sequence];
        }];
        
        id sequence = [CCActionSequence actionWithArray:@[spawn,block]];
        [_bird runAction:sequence];
    }
    else
    {
        _bird.physicsBody = nil;
        _ring.physicsBody = nil;
        
        id jump = [CCActionJumpBy actionWithDuration:0.5 position:ccp(0, 0) height:0.15 jumps:1];
        id rotate = [CCActionRotateTo actionWithDuration:0.5 angle:190];
        id fade = [CCActionFadeOut actionWithDuration:0.5];
        
        NSArray* array = nil;
        if(needJump)
            array = [NSArray arrayWithObjects:jump,rotate,fade,nil];
        else
            array = [NSArray arrayWithObjects:rotate,fade,nil];
        
        id spawn = [CCActionSpawn actionWithArray:array];
        
        id block = [CCActionCallBlock actionWithBlock:^{
            id fade = [CCActionFadeOut actionWithDuration:0.3];
            id block = [CCActionCallBlock actionWithBlock:^{
                CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
                //id transition = [CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.1];
                [[CCDirector sharedDirector] replaceScene:mainScene];
            }];
            id sequence = [CCActionSequence actionWithArray:@[fade,block]];
            [_ring runAction:sequence];
        }];
        
        id sequence = [CCActionSequence actionWithArray:@[spawn,block]];
        [_bird runAction:sequence];
    }
}

- (void)record
{
    int oldScore = [RCTool getRecordByType:RT_SCORE];
    if(_score == oldScore + 1)
    {
        [RCTool setRecordByType:RT_SCORE value:_score];
        
        int bestScore = [RCTool getRecordByType:RT_BEST];
        if(bestScore < _score)
        {
            [RCTool setRecordByType:RT_BEST value:_score];
        }
    }
}

- (void)clampVelocity
{
    // clamp velocity
    float yVelocity = clampf(_bird.physicsBody.velocity.y, MIN_VELOCITY_Y, MAX_VELOCITY_Y);
    _bird.physicsBody.velocity = ccp(0, yVelocity);
}

#pragma mark - CCPhysicsCollisionDelegate

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(CCNode *)bird ring:(CCNode *)ring
{
    CCLOG(@"collided.");
    
    //从动态刚体变为静态刚体
    //    [[_physicsWorld space] addPostStepBlock:^{
    //        _ring.physicsBody.type = CCPhysicsBodyTypeStatic;
    //    } key:_ring];
    
    [RCTool playEffectSound:SOUND_HIT];
    
    CGSize screenSize = [RCTool getScreenSize];
    CGFloat birdY = _bird.position.y*screenSize.height;
    //CGSize birdSize = [_bird contentSizeInPoints];
    CGFloat ringY = _ring.position.y*screenSize.height;
    //CGSize ringSize = [_ring contentSizeInPoints];
    
    CGFloat offset = birdY - ringY;
    
    if(offset < 0)
        [self over:YES up:NO];
    else
        [self over:YES up:YES];
    
    return NO;
}

#pragma mark - Touch Events

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //[super touchBegan:touch withEvent:event];
    
    [self jump];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    //[super touchEnded:touch withEvent:event];
    
    
}

@end
