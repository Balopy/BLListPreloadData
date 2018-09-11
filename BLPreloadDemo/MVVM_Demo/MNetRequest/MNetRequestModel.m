//
//  MNetRequestModel.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "MNetRequestModel.h"
#import<CommonCrypto/CommonDigest.h>

@implementation MNetRequestModel


/** 1 * post 请求 无进度 */
+ (void)request:(NSString *)urlString withParamters:(NSDictionary *)dic success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure {
    
    
   NSDictionary *dictiont = [self parameterExchange:dic url:urlString];
    
    ///增加这几行代码；
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.f];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    [manager POST:urlString parameters:dictiont progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        if (failure != nil) {
            failure(error);
        }
        BLLog(@"----failure---%@", error.description);
    }];
}



/**
 将路径进行md5加密
 
 @param string 数据文件储存路径
 @return 加密后的文件路径
 */
+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


/*! 与后台约定加密码规则，所有参数进行排序，用|分隔，生成MD5串，以sign=MD5作为一个参数 */
+(NSMutableDictionary *)parameterExchange:(NSDictionary *)setting url:(NSString *)url{
    //获取时间戳
    UInt64 timestamps = [[NSDate date] timeIntervalSince1970]*1000;
   
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];

        parameter = setting.mutableCopy;
    
    [parameter setValue:@(timestamps) forKey:@"timestamps"];
    [parameter setValue:@"YaIHNMXmx19560uE124SImc6Yyv85j943S7885M41Bs20v02L1oYY4b94QL3j72x9YfE37814h7092fGf9f054S6J83G1o3bT48I4p0s5KbS3Bd09A3q0C61vaL2audzr89Av258D5H32wr754d7Gzd0xe0D79zGd70703Iu642M5165VyyE3Lg4QF9524T956U4uR7HKZz0nYX236eC9von069nz7r7P" forKey:@"privateKey"];
    
    NSArray *dicKeysArray = [parameter allKeys];
    //对 key 进行排序
    NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        
        NSRange range = NSMakeRange(0,obj1.length);
        
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    
    NSArray *resultArray = [dicKeysArray sortedArrayUsingComparator:sort];
    //拼接sign字符串
    NSString *signForString = @"";
    //拼接url参数
    NSString *urlWithParamterString = [url stringByAppendingString:@"?"];
    
    for (NSString *key in resultArray){
        
        NSString *temp = [NSString stringWithFormat:@"%@|%@|", key, [parameter objectForKey:key]];
        signForString = [signForString stringByAppendingString:temp];
        
        NSString *paramer = [NSString stringWithFormat:@"%@=%@&", key, [parameter objectForKey:key]];
        urlWithParamterString = [urlWithParamterString stringByAppendingString:paramer];
    }
    
    
    //删除最后一个字符"|"
    signForString = [signForString substringToIndex:signForString.length - 1];
    
    //进行 md5 编码,生成 sign 值
    NSString *sign = [self md5StringFromString:signForString];
    [parameter setValue:sign forKey:@"sign"];
    
    //将最后一个 sign 值也拼接到字符串中打印
    urlWithParamterString = [urlWithParamterString stringByAppendingString:[NSString stringWithFormat:@"%@=%@", @"sign", sign]];
    BLLog(@"\n\n路径--%@\n\n", urlWithParamterString);
    return parameter;
}



#pragma mark ---- 打印路径  ----
+ (void)printRequestUrlString:(NSString *)urlString withParamter:(NSDictionary *)dic {
    
    if (!dic) {
        BLLog(@"\n\n路径--%@", urlString);
        return;
    }
    __block NSString *tempStr = [urlString stringByAppendingString:@"?"];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *key_Value = [NSString stringWithFormat:@"%@=%@&", key, obj];
        tempStr = [tempStr stringByAppendingString:key_Value];
    }];
    
    if (dic.allKeys.count) {
        
        tempStr = [tempStr substringToIndex:tempStr.length-1];
    }
    BLLog(@"\n\n路径--%@", tempStr);
}

@end


