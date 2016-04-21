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
    BOOL isOpen = [WXApi isWXAppInstalled];
//    NSString *str = [WXApi getWXAppInstallUrl];
    if (isOpen == NO) {
        NSLog(@"用户没有安装微信");
        return;
    }
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
- (IBAction)btn3:(id)sender {
    // 分享到微信
    
//    [self shareUrl];
    
    BOOL isInstall = [WXApi isWXAppInstalled];
    if (isInstall == NO) {
        NSString *urlStr = [WXApi getWXAppInstallUrl];
        NSLog(@"%@", urlStr);
        NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", 414478124];
        // 微信的appStore下载地址
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            //
            NSLog(@"能打开");
        }else{
            NSLog(@"不能打开");
        }
        
    }
    
}

- (void)shareUrl
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setTitle:@"标题"];
    message.description = @"描述";
    // 分享网页到聊天界面的话，就不需要设置图片了
//    [message setThumbImage:[UIImage imageNamed:@"1"]];
    
    WXWebpageObject *urlObj = [WXWebpageObject object];
    urlObj.webpageUrl = @"http://tech.qq.com/zt2012/tmtdecode/252.htm";
    message.mediaObject = urlObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO; // NO 多媒体消息
    req.scene = WXSceneSession; //聊天
    [WXApi sendReq:req];
}

- (void)shareImg
{
    // 分享图片
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"me"]];
    WXImageObject *imgObj = [WXImageObject object];
    imgObj.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"me" ofType:@"png"]];
    message.mediaObject = imgObj;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    req.bText = NO; // NO 多媒体消息
    req.scene = WXSceneSession; //聊天
    [WXApi sendReq:req];
}

- (void)shareText
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = @"微信分享文字";
    req.bText = YES; //YES 普通消息类型
    req.scene = WXSceneSession; //聊天
    [WXApi sendReq:req];
}

@end
