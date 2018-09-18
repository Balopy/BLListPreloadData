//
//  BLRequestConfig.m
//  MVVM_Demo
//
//  Created by Balopy on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import "BLRequestConfig.h"
#import<CommonCrypto/CommonDigest.h>

@implementation BLRequestConfig


+ (NSString *)cacheBasePath {
    
    //放入cash文件夹下,为了让手机自动清理缓存文件,避免产生垃圾
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"MLazyRequestCache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (exist) {//存在
        
        if (!isDir) {//如果不是文件夹，删了重建
            
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    } else {//不存，去创建
        
        [self createBaseDirectoryAtPath:path];
    }
    return path;
}

//创建文件夹
+(void)createBaseDirectoryAtPath:(NSString *)path {
    
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (success) {
        BLLog(@"创建成功");
    }
}

/*! 判断缓存时间是否过期 */
+(BOOL) inAvailabilityWithCachTime:(NSTimeInterval)cashTime path:(NSString *)path {
    
    NSDate *date = [NSDate date];
    NSTimeInterval time = (cashTime == 0 ? 3 * 60 : cashTime * 60);
    NSDate *currentTime = [NSDate dateWithTimeInterval:-time sinceDate:date];
    
    //创建文件时间
    NSDate *setData = [self getFileCreateTimeWithPath:path];
    
    BOOL value = [self compareCurrentTime:currentTime withFileCreatTime:setData];
    
    return value;
}

/*! 使用接口地址/后接参数字典，通过md5生成字符串 */
+ (NSString *)cacheFilePath:(NSString *)path{
    
    NSString *cacheFileName = [self md5StringFromString:path];
    
    NSString *pathMd5 = [self cacheBasePath];
    
    pathMd5 = [pathMd5 stringByAppendingPathComponent:cacheFileName];
    
    return pathMd5;
}



//获取文件夹创建时间
+ (NSDate *)getFileCreateTimeWithPath:(NSString *)path{
    
    NSError * error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //通过文件管理器来获得属性
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
    BLLog(@"--fileCreateDate--%@", fileCreateDate);
    
    return fileCreateDate;
}

//currentTime，加了 60*s 之后，与创建时间比，返回0，否则返回1, 如果>0则失效
+ (BOOL) compareCurrentTime:(NSDate *)currentTime withFileCreatTime:(NSDate *)fileCreatTime
{
    
    NSComparisonResult result = [currentTime compare:fileCreatTime];
    BLLog(@"--result-%lu--%@---%@", (long)result, currentTime, fileCreatTime);
    NSInteger aa = 0;
    
    if (result == NSOrderedDescending) {//降--大
        //文件创建时间超过当前时间,刷新数据
        aa = 1;
    }else if (result == NSOrderedAscending){//升--小
        //文件创建时间小于当前时间,取出缓存数据
        aa = -1;
    }
    //返回一个没有过期的结果，
    return aa < 0;
}

+(void)saveCashDataForArchiver:(id)responseData jsonValidator:(NSString *)jsonValidator cachPath:(NSString *)path{
    
    if (responseData != nil) {
        @try {
            if (jsonValidator) {
                //如果有格式验证就进行验证
                BOOL result = [self validateJSON:responseData withValidator:jsonValidator];
                if (result) {
                    BOOL cashResule = [NSKeyedArchiver archiveRootObject:responseData toFile:path];
                    if (cashResule) {
                        BLLog(@"本地数据缓存成功");
                    }
                }else{
                    //格式不正确
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    //检测文件路径存不存在
                    BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
                    if (isFileExist) {
                        //如果文件存在,肯定是老数据,把文件删掉
                        NSError *error = nil;
                        [fileManager removeItemAtPath:path error:&error];
                    }
                }
            }else{
                //没有验证直接存储
                [NSKeyedArchiver archiveRootObject:responseData toFile:path];
            }
        } @catch (NSException *exception) {
            BLLog(@"Save cache failed, reason = %@", exception.reason);
        }
    }
}


+(NSString *)currentTimesTamps{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];
    BLLog(@"---datenow--%@", datenow);
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
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
    [parameter setValue:PrivateKey forKey:@"privateKey"];
    
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


//json字段检验
+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        
        while ((key = [enumerator nextObject]) != nil) {
            
            id value = dict[key];
            id format = validator[key];
            
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                
                result = [self validateJSON:value withValidator:format];
                
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    
                    result = NO;
                    break;
                }
            }
        }
        return result;
        
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        
        NSArray * validatorArray = (NSArray *)jsonValidator;
        
        if (validatorArray.count > 0) {
            
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            
            for (id item in array) {
                
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}



// 是否wifi
+ (BOOL)isEnableWIFI{
    YYReachability *reachable = [[YYReachability alloc] init];
    BOOL iswifi = NO;
    if (reachable.status ==  YYReachabilityStatusWiFi){
        iswifi = YES;
    }
    return iswifi;
}

// 是否3G
+ (BOOL)isEnableWWAN{
    YYReachability *reachable = [[YYReachability alloc] init];
    if ( reachable.status == YYReachabilityStatusWWAN)//有网且不是wifi
        return YES;
    else
        return NO;
}

//网络是否可用
+ (BOOL)isNoNet{
    YYReachability *reachable = [[YYReachability alloc] init];
    if (reachable.status == YYReachabilityStatusNone) {
        return YES;
    }
    else
        return NO;
}



@end
