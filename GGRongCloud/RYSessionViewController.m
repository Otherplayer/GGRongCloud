//
//  RYSessionViewController.m
//  HotYQ
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 hotyq. All rights reserved.
//

#import "RYSessionViewController.h"
//#import "RYChatViewController.h"
#import "HYQRongYunManager.h"

@interface RYSessionViewController ()

@end

@implementation RYSessionViewController


- (void)loadView{
    [super loadView];
    self.title = @"会话列表";
    //设置要显示的会话类型
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
    //聚合会话类型
    [self setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
    [self addBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"chatList"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshConversationTableViewIfNeeded];
    [self.conversationListTableView reloadData];
    
    [[HYQRongYunManager sharedInstance] refreshUnreadMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick beginLogPageView:@"chatList"];
    [HYQShowTip hide:YES];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexRGB:@"333333"];
    
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorFromHexRGB:@"#dfdfdf"];
    self.conversationListTableView.tableFooterView = [UIView new];
    [self.navigationController applyGradientApprenceWithTranslucent:NO];
    self.navigationItem.rightBarButtonItem = nil;

}

- (void)goBackMethod{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[HYQRongYunManager sharedInstance] showInController:self userName:model.conversationTitle targetId:model.targetId];
    });
    
}



@end
