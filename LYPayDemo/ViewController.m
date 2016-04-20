//
//  ViewController.m
//  LYPayDemo
//
//  Created by liyang on 16/4/20.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "ViewController.h"
#import "LYWeiChatPay.h"
#import "WXApi.h"
#import "NSString+LYNSStringExtension.h"
#import "AliPay.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}
- (IBAction)weiChatPay
{
    LYWeiChatPay *pay = [LYWeiChatPay sharedInstance];
    // 吊起微信支付
    [pay weiChatPayWithBody:@"liyang" orderID:[NSString stringWithTradeNO] totalFee:@"1" resultDic:^(NSDictionary *dict, NSError *error) {
        if (!error) {
            
            PayReq* req             = [[PayReq alloc] init];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            req.prepayId            = [dict objectForKey:@"prepayid"];
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = [[dict objectForKey:@"timestamp"] intValue];
            req.package             = [dict objectForKey:@"package"];
            req.sign                = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
        }else{
            NSLog(@"error2 = %@", error);
        }
    }];
}
- (IBAction)aliPay
{
    AliPay *ali = [AliPay sharedInstance];
    [ali payTradeNO:[NSString stringWithTradeNO] ProductName:@"liyang" productDescription:@"haha" Amount:@"1" aliBlock:^(NSDictionary *dict, NSError *error) {
        if (!error) {
            NSLog(@"%@", dict);
        }else{
            NSLog(@"error1 = %@", error);
        }
    }];
}

@end
