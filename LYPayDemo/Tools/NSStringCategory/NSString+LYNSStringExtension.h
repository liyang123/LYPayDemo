//
//  NSString+LYNSStringExtension.h
//  LYPayDemo
//
//  Created by liyang on 16/4/19.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LYNSStringExtension)

/**
 *  获取客户端网络IP
 *
 *  @return 返回客户端网络IP
 */
+ (instancetype)stringWithIP;

/**
 *  获取随机订单号
 *
 *  @return 返回一个随机订单号
 */
+ (instancetype)stringWithTradeNO;


/**
 *  md5加密
 *
 *  @param str 要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+ (instancetype)stringWithMD5:(NSString *)str;

/**
 *  sha1加密
 *
 *  @param str 要加密的字符串
 *
 *  @return 返回加密后的字符串
 */
+ (instancetype)stringWithsha1:(NSString *)str;
@end
