//
//  HYQRongYunManager.h
//  HotYQ
//
//  Created by __无邪_ on 15/6/29.
//  Copyright © 2015年 hotyq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYQRongYunManager : NSObject<RCIMUserInfoDataSource,RCIMConnectionStatusDelegate,RCIMReceiveMessageDelegate>

+ (instancetype)sharedInstance;

/// 设置 DeviceToken，用于 APNS 的设备唯一标识。请在调用 connectWithToken 之前调用该方法。
- (void)registerDeviceToken:(NSData *)deviceToken;

/// 获取当前连接状态
@property (nonatomic, assign)BOOL isConnecting;

/// 连接
- (void)startConnect;
/// Log out。不会接收到push消息。
- (void)logout;

/// 获取未读消息数量
- (int)unreadCount;

/// 刷新未读消息数量
- (void)refreshUnreadMessage;


/// 推出私信聊天界面
- (void)showInController:(UIViewController *)controller userName:(NSString *)userName targetId:(NSString *)uid;
/// 推出私信对话列表
- (void)gotoConversationListViewController:(UIViewController *)controller;


@end
