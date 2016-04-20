

//
//  AliPay.m
//  TestAliPayTwo
//
//  Created by ly on 16/1/15.
//  Copyright © 2016年 yinxingkeji. All rights reserved.
//

#import "AliPay.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import <UIKit/UIKit.h>
#define kPrivate @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBALPHX1LIwTrTd7/Y/nvcF1TQgW+0eWkb2nFSwQnBXmhKyC4jOn/N02rPkQRFbE4bANVKhqTN9XLrj+uu    6XGfp57oIIFcwjZ9YiaVKAVobZUujFTOXf5c6nyNP8eSbdFPXDGy69PnRJoOg9u4    9iB90LXbD7e2qZ9VwqOeV55p23wPAgMBAAECgYEAn13tsoUkRfGQBhFmBoZkaFst    Ysipl/OJAUxKs0snVWx1Z/DyurjK4bR+6TpheBuX8XvPP+kT3HvVaSf06TSOcWLR    UU2Of1jcXTuMAHebG+P7iGLWdE8Hz4VJk57tXRl0yeS//fzgtLvynbe+MMQP3cgQ    m7zNctdqGXtgsCwnVwECQQDfCDmJRVckfD330v2PWGM3orvAp1eJS891iILTh4/x    6MxhRJnw1bpbWwHUUv4t/hkXuLZdOO59J7G1WkOluqxnAkEAzlplKSao4sCVztsT    iSaYIPh9fmJMImPPyxvEmjunNphBLcsr4CjbM8wGefuUPIB3ko7l70qMugUeuf07    sBJqGQJAJQzRugsJ0ebNyIiFVLXDLa/b7sId2ZH9cbHuwcMIV5Bru1DRHd/zaE+y    +xmaXfuTIYyuxse5XpMkg1LuX+6lywJBAK78euJ9lSPMen1Sy+s3HjR/ZDQDeVqE    V5Z+MqczxOWIEWWa79cD7narIibZD2iK7FsM8LGN/25Tny3LL41s4CkCQByLMvib    rdNIYk5PXRI7Bvc97FsQTDKzIKaC8kFLw/LDS3Sh3Ncsu8lrLNnGa0avPnR7mNH1    zb7KIWqO4zQFwwE="
@implementation AliPay
static AliPay *_tool;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_tool == nil) {
            _tool = [[self alloc] init];
        }
    });
    return _tool;
}
- (void)payTradeNO:(NSString *)tradeNO ProductName:(NSString *)productName productDescription:(NSString *)productDescription Amount:(NSString *)amount aliBlock:(aliBlock)block
{
    NSString *partner = @"2088121525289760";  // 合作身份者ID，以2088开头由16位纯数字组成的字符串。请参考查看PID。
    NSString *seller = @"dreamer@yesingbeijing.com"; // 支付宝收款账号，手机号码或邮箱格式
    NSString *privateKey = kPrivate; // 商户方的私钥
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    // 检查下订单信息
    if (!tradeNO.length && !productName.length && !productName.length && !amount.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请先完善订单信息"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
    order.productName = productName; //商品标题
    order.productDescription = productDescription; //商品描述
    order.amount = [NSString stringWithFormat:@"%@", amount]; //商品价格
    order.notifyURL =  @"120.24.1.189:80/ali/"; //回调URL
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m"; // 时间
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"liyang";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            block(resultDic, nil);
            
        }];
    }
}
/*
 支付宝返回码的含义
 9000 订单支付成功
 8000 正在处理中
 4000 订单支付失败
 6001 用户中途取消
 6002 网络链接出错
 */

@end
