//
//  LYWeiChatPay.m
//  LYPayDemo
//
//  Created by liyang on 16/4/19.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "LYWeiChatPay.h"
#import "NSString+LYNSStringExtension.h"
#import "XMLDictionary.h"

@implementation LYWeiChatPay

+ (instancetype)sharedInstance
{
    static LYWeiChatPay *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

#pragma mark - 微信的代理回调
-(void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}


#pragma mark - 提交订单信息到微信微信服务器，生成预支付订单,并且以字典的形式返回
- (void)weiChatPayWithBody:(NSString *)body orderID:(NSString *)orderID totalFee:(NSString *)totalFee resultDic:(weiChatBlock)resultblock
{
#pragma mark 预付单参数订单设置
    srand((unsigned)time(0));
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSString *spbill_ip = [NSString stringWithIP];
    
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    [packageParams setObject: APP_ID             forKey:@"appid"];       //开放平台appid
    [packageParams setObject: MCH_ID             forKey:@"mch_id"];      //商户号
    [packageParams setObject: @"APP-001"        forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr          forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"APP"            forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject: body              forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject: @"www.baidu.com"  forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: orderID           forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: spbill_ip    forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: totalFee          forKey:@"total_fee"];       //订单金额，单位为分

#pragma mark 处理这预支付订单,并且向微信服务器发送预支付信息，生成一个预支付订单id
    NSString *getPrePayid = [self createMd5Sign:packageParams]; // dictionary转key=value字符串，排序，并在末尾添加商户API秘钥,并且MD5加密处理后传过来
    
    // 提交给微信服务器的预支付订单
    NSString *orderString = [self getPackage:packageParams prePayString:getPrePayid];
    
#pragma mark 提交给微信服务器预支付订单，返回真正的订单信息
    NSString *urlStr = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    request.HTTPMethod = @"POST";
    //设置数据类型
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    //设置编码
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    //如果是POST
    [request setHTTPBody:[orderString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSString *xmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            // 字典的一个类别，把xml转成字典
            NSDictionary *dic = [NSDictionary dictionaryWithXMLString:xmlStr];
            
            NSString *return_code = [dic objectForKey:@"return_code"];
            NSString *result_code = [dic objectForKey:@"result_code"];
            
            if (([return_code isEqualToString:@"SUCCESS"])&&([result_code isEqualToString:@"SUCCESS"])) {
                NSString *prePayid = [dic objectForKey:@"prepay_id"];
                
#pragma mark 生成正式的订单信息
                NSString *package, *time_stamp, *nonce_str;
                //设置支付参数
                time_t now;
                time(&now);
                time_stamp  = [NSString stringWithFormat:@"%ld", now];
                nonce_str	= [NSString stringWithMD5:time_stamp];
                package         = @"Sign=WXPay";
                //第二次签名参数列表
                NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
                [signParams setObject: APP_ID        forKey:@"appid"];
                [signParams setObject: nonce_str    forKey:@"noncestr"];
                [signParams setObject: package      forKey:@"package"];
                [signParams setObject: MCH_ID        forKey:@"partnerid"];
                [signParams setObject: time_stamp   forKey:@"timestamp"];
                [signParams setObject: prePayid     forKey:@"prepayid"];
                /**
                 *  把字典key=value形式拼接成字符串，并且签名
                 */
                NSString *signStr = [self createMd5Sign:signParams];
                [signParams setObject:signStr forKey:@"sign"];
                /**
                 *  用block把请求下来的订单信息传回去
                 */
                resultblock(signParams, nil);
            }else{
                resultblock(nil, [NSError errorWithDomain:@"返回的状态不对" code:1000 userInfo:nil]);
            }
        }else{
            NSLog(@"error = %@", error);
            resultblock(nil, error);
        }
    }];
    [dataTask resume];
}

#pragma mark - 把字典中的键值对拼接成字符串
- (NSString*)createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", PARTNER_key];
    //得到MD5 sign签名
    NSString *md5Sign =[NSString stringWithMD5:contentString];
    
    return md5Sign;
}



/**
 *  把字典数据拼接成xml格式字符串，并且在字符串最后签名，形成签名包（package）
 *
 *  @param packageParams 原始的数据字典（不带sign签名的字典）
 *  @param sign          把原始的数据字典转成字符串，然后拼接上用户私钥，最后md5加密得到的字符串
 *
 *  @return 提交给微信服务器的预支付订单
 */
- (NSString *)getPackage:(NSMutableDictionary*)packageParams prePayString:(NSString *)sign
{
    NSMutableString *reqPars=[NSMutableString string];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}

@end
