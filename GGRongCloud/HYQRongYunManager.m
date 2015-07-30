//
//  HYQRongYunManager.m
//  HotYQ
//
//  Created by __无邪_ on 15/6/29.
//  Copyright © 2015年 hotyq. All rights reserved.
//

#import "HYQRongYunManager.h"
#import "UserInfoNetwork.h"
#import "RYChatViewController.h"
#import "RYSessionViewController.h"
#import "HYQNetworkManager.h"
#import "AppDelegate.h"
#import "HYQLoginUser.h"

@interface HYQRongYunManager ()

@property (nonatomic, assign) NSInteger isComing;
@end

@implementation HYQRongYunManager

+ (instancetype)sharedInstance{
    static HYQRongYunManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HYQRongYunManager alloc] initConfig];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isConnecting = NO;
        
        /// 设置代理
        [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    }
    return self;
}

- (instancetype)initConfig
{
    self = [super init];
    if (self) {
        //初始化融云SDK
        [[RCIM sharedRCIM] initWithAppKey:kRongCloudAppKey];
        self.isConnecting = NO;
        self.isComing = NO;
        
        //设置会话列表头像和会话界面头像
        [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
        if (IS_IPHONE6_PLUS) {
            [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
        } else {
            [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
        }
        
        //设置用户信息源和群组信息源
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    }
    return self;
}


- (void)registerDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description] trimCharacterToToken];
//    daeb46e4b2af3f46941df3f8e029611c5c92bd00f56802c4e7d10a0056fad599
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
    
    
    [self startConnect];
}

- (void)startConnect{
    if (!self.isConnecting) {
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                GGLog(@"连接成功");
                [self refreshUnreadMessage];
                //[self showTip:@"连接成功"];
            }else{
                GGLog(@"连接失败");
                //[self showTip:@"连接错误，请稍后重试"];
            }
        }];
    }
}

- (void)connect:(void (^)(bool success, NSString *userId))successBlock{
    
    
    /// 连接
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *token        = [user objectForKey:@"rongyun_token"];
    
    if (!token || token.length <= 0 || self.isComing) {
        return;
//        token = @"vuuFZ5a0K0eIuVyXpMD6hPop+SLpL1tvozs6G9bXr6++bGkJ4oG7ujw3nOhw1sodp5uoO+Qcl4NgQLl3Gvg01Q==";
    }
    
    self.isComing = YES;
    

    //token = @"zXiRcwD8Rr/b7/c8rHPLsD8/LSO7/06DxArwkIfp777hsgm1xLNuATT7xktGvNH3j2EsSWG5v/Ni1bA8FSho0Q==";
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        ///连接成功
        
//        NSString *userId = [[HYQLoginUser sharedInstance] currentUserId];
        NSString *userName = [[HYQLoginUser sharedInstance] currentNickName];
        NSString *portrait = [[HYQLoginUser sharedInstance] currentUserImg];
        
        RCUserInfo *currentUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:userName portrait:portrait];
        [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
        [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:userId];
        
        [self refreshUnreadMessage];
        
        self.isConnecting = YES;
        self.isComing = NO;
        successBlock(YES, userId);
        
    } error:^(RCConnectErrorCode status) {
        
        self.isConnecting = NO;
        self.isComing = NO;
        successBlock(NO, nil);
        
    } tokenIncorrect:^{
        
        self.isConnecting = NO;
        self.isComing = NO;
        successBlock(NO, nil);
    }];
    
}


- (void)logout{
    [[RCIM sharedRCIM] logout];
    [[RCIM sharedRCIM] disconnect:NO];
}

- (int)unreadCount{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    return unreadMsgCount;
}



/// 去对话列表
- (void)showInController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid{
    
    
    if (self.isConnecting) {
        // 创建单聊视图控制器。
        [self gotoConversationController:controller userName:userName targetId:uid];
    }else{
        [HYQShowTip showProgressWithText:@"" dealy:40];
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                [HYQShowTip hide:YES];
                [self gotoConversationController:controller userName:userName targetId:uid];
            }else{
                [self showTip:@"连接错误，请稍后重试"];
            }
        }];
    }
    
}




/// 去会话列表
- (void)gotoConversationListViewController:(UIViewController *)controller{
    
    if (self.isConnecting) {
        // 创建单聊视图控制器。
        [self gotoConversationListController:controller];
    }else{
        [self connect:^(bool success, NSString *userId) {
            if (success) {
                [self gotoConversationListController:controller];
            }else{
                [self showTip:@"连接错误，请稍后重试"];
            }
        }];
    }
}




- (void)gotoConversationListController:(UIViewController *)controller{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [HYQShowTip hide:YES];
        RYSessionViewController *sessionVC = [[RYSessionViewController alloc]init];
        sessionVC.isEnteredToCollectionViewController = YES;
        [controller.navigationController pushViewController:sessionVC animated:YES];
    });
}

- (void)gotoConversationController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [HYQShowTip hide:YES];
        RYChatViewController *chatViewController = [[RYChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:uid];
        chatViewController.nameStr = @"约吗";
        chatViewController.currentTarget = uid;
        chatViewController.currentTargetName = userName;
        [controller setHidesBottomBarWhenPushed: YES];
        [controller.navigationController pushViewController:chatViewController animated:YES];
    });
}






#pragma mark - RCIMUserInfoDataSource

///获取用户信息
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    NSLog(@"=====%@",userId);
    
    if([userId length] == 0)
        return completion(nil);
    
    [[HYQNetworkManager shareManager] getUserInfoByUserID:userId completion:^(RCUserInfo *user) {
        dispatch_async(dispatch_get_main_queue(), ^{
            return completion(user);
        });
    }];
    
    return completion(nil);
}


- (void)refreshUnreadMessage{
    [self refreshTabBarItemWith:[self unreadCount]];
}

- (void)refreshTabBarItemWith:(int)count{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *countString = [NSString stringWithFormat:@"%d",count];
        AppDelegate *dgApp = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (count <= 0) {
            countString = nil;
        }
        
        BOOL shouldShow = NO;
        if (count > 0) {
            shouldShow = YES;
        }
        
        [dgApp.tabBarController showPoint:shouldShow];
//        [dgApp.myNavigationController.tabBarItem setBadgeValue:countString];
    });
}

#pragma mark - RCIMConnectionStatusDelegate

/// 监控连接状态
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    NSLog(@"【RONGYUN Status  %ld，0 is connected success !】",status);
    
    if (status == ConnectionStatus_Connected) {
        self.isConnecting = YES;
    }else{
        self.isConnecting = NO;
    }
}
///收到信息
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    GGLog(@"%@   %d",message,left);
    
    [self refreshUnreadMessage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUnreadNotificationKey object:@([self unreadCount])];
    
}
///收到本地通知
-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message withSenderName:(NSString *)senderName{
    [UIApplication sharedApplication].applicationIconBadgeNumber =
    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    return NO;
}
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message{
    return NO;
}
#pragma mark - Private

- (void)showTip:(NSString *)tip{
    [HYQShowTip showTipTextOnly:tip dealy:1.2];
}


@end
