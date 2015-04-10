//
//  GameScene.h
//  Donot
//
//  Created by xuzepei on 3/22/15.
//  Copyright (c) 2015 TapGuilt. All rights reserved.
//

#import "CCNode.h"

@interface GameScene : CCNode<CCPhysicsCollisionDelegate>
{
    CCPhysicsNode* _physicsWorld;
    CCSprite* _ring;
    CCSprite* _bird;
    CCLabelTTF* _tipLabel;
    CCLabelTTF* _scoreLabel;
    
    int _score;
    BOOL _isOut;
    BOOL _isOver;
}

@end
