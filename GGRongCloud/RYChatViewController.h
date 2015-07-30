//
//  RYChatViewController.h
//  HotYQ
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 hotyq. All rights reserved.
//

//#import "RCConversationViewController.h"
//#import <RCConversationViewController.h>
#import <RongIMKit/RongIMKit.h>

typedef NS_ENUM(NSInteger, RCUserAvatarStylee) {
    /**
     *  矩形边角
     */
    RCUserAvatarRect = 0,
    /**
     *  圆形边角
     */
    RCUserAvatarCycle
    
};

@interface RYChatViewController : RCConversationViewController

/**
 *  会话数据模型
 */
@property (strong,nonatomic) RCConversationModel *conversation;

@property (nonatomic, strong)NSString *nameStr;

@property (nonatomic, strong)NSString *currentTarget;

@property (nonatomic, strong)NSString *currentTargetName;

@property (nonatomic, assign)RCUserAvatarStylee portraitStyle;






@end
