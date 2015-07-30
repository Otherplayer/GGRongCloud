//
//  RYChatViewController.m
//  HotYQ
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 hotyq. All rights reserved.
//

#import "RYChatViewController.h"
#import "OtherUserInforViewController.h"
#import "CompanyInfomationViewController.h"
#import "HYQRedsDetailController.h"
#import "HYQRongYunManager.h"

@interface RYChatViewController ()

@end

@implementation RYChatViewController
@synthesize nameStr;

- (void)loadView{
    [super loadView];
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];//必须在viewdidload之前调用
    [self addBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"chat"];
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController applyGradientApprenceWithTranslucent:NO];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick beginLogPageView:@"chat"];
    
    [[HYQRongYunManager sharedInstance] refreshUnreadMessage];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setEnableSaveNewPhotoToLocalSystem:YES];
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexRGB:@"333333"];

    
    self.navigationItem.rightBarButtonItem = nil;
}



//重新1.0版本set,get方法

-(void)setPortraitStyle:(RCUserAvatarStylee)portraitStyle{
    [self setMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
}

- (void)setCurrentTarget:(NSString *)currentTarget{
    [self setTargetId:currentTarget];
}

- (void)setCurrentTargetName:(NSString *)currentTargetName{
    [self setTitle:currentTargetName];
    [self setUserName:currentTargetName];
}


-(NSString *)currentTarget{
    return self.targetId;
}


-(NSString *)currentTargetName{
    return self.userName;
}

#pragma mark - Action


- (void)didTapCellPortrait:(NSString *)userId{
    
    HYQSXUserInfo *userInfo = [HYQSXUserInfo getUserInfoWithUserId:userId];
    
    if (userInfo.type.intValue == HYQUserInfoType_User) {//个人
        // 点击头像后进入个人资料页面
//        OtherUserInforViewController *controller = [[OtherUserInforViewController alloc] init];
//        controller.suid = userId;
//        controller.nickName = self.userName;
        
        HYQRedsDetailController *controller = [[HYQRedsDetailController alloc] init];
        controller.userId = userId;
        controller.nickname = self.userName;
        controller.userType = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:controller animated:YES];
        });
        
    }else{
        // 点击头像后进入机构页面
//        CompanyInfomationViewController *controller = [[CompanyInfomationViewController alloc] init];
//        controller.c_suid = userId;
//        controller.c_nickName = self.userName;
        
        HYQRedsDetailController *controller = [[HYQRedsDetailController alloc] init];
        controller.userId = userId;
        controller.nickname = self.userName;
        controller.userType = 1;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:controller animated:YES];
        });
    }
    
    
    
}

#pragma mark override
/**
 *  返回方法，如果继承，请重写该方法，并且优先调用父类方法;
 *
 *  @param sender 发送者
 */
- (void)leftBarButtonItemPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}









@end
