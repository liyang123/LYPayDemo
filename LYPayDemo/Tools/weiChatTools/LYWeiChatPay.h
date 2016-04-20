//
//  LYWeiChatPay.h
//  LYPayDemo
//
//  Created by liyang on 16/4/19.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

typedef void(^weiChatBlock)(NSDictionary *dict, NSError *error);

@interface LYWeiChatPay : NSObject<WXApiDelegate>

/** block传回订单信息  */
@property (nonatomic, copy) weiChatBlock weiChatblock;


+ (instancetype)sharedInstance;

/**
 *  去微信服务器请求支付订单，并以字典的形式传回
 *
 *  @param body     订单描述，展示给用户的
 *  @param orderID  订单编号
 *  @param totalFee 订单金额(单位是分)
 *  @param resultblock 用block传回订单信息
 *
 *  @return 微信的支付订单
 */
- (void)weiChatPayWithBody:(NSString *)body orderID:(NSString *)orderID totalFee:(NSString *)totalFee resultDic:(weiChatBlock)resultblock;
@end
