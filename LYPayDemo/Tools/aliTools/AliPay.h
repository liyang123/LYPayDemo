//
//  AliPay.h
//  TestAliPayTwo
//
//  Created by ly on 16/1/15.
//  Copyright © 2016年 yinxingkeji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^aliBlock)(NSDictionary *dict, NSError *error);

@interface AliPay : NSObject

/** 支付结果  */
@property (nonatomic, copy) aliBlock aliBlock;


/**
 *  实例方法
 *
 *  @return 返回一个AliPay实例
 */
+(instancetype)sharedInstance;


/**
 *  支付宝支付
 *
 *  @param tradeNO            订单编号（注意不能出现汉字）
 *  @param productName        订单名称
 *  @param productDescription 订单描述
 *  @param amount             订单价格
 */
- (void)payTradeNO:(NSString *)tradeNO ProductName:(NSString *)productName productDescription:(NSString *)productDescription Amount:(NSString *)amount aliBlock:(aliBlock)block;


@end
