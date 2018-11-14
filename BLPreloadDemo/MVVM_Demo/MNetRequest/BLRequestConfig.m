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
        NSLog(@"创建成功");
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
    NSLog(@"--fileCreateDate--%@", fileCreateDate);
    
    return fileCreateDate;
}

//currentTime，加了 60*s 之后，与创建时间比，返回0，否则返回1, 如果>0则失效
+ (BOOL) compareCurrentTime:(NSDate *)currentTime withFileCreatTime:(NSDate *)fileCreatTime
{
    
    NSComparisonResult result = [currentTime compare:fileCreatTime];
    NSLog(@"--result-%lu--%@---%@", (long)result, currentTime, fileCreatTime);
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
                        NSLog(@"本地数据缓存成功");
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
            NSLog(@"Save cache failed, reason = %@", exception.reason);
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
    NSLog(@"---datenow--%@", datenow);
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
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    
    if(setting)
        parameter = setting.mutableCopy;
  
    //拼接url参数
   __block NSString *urlWithParamterString = [url stringByAppendingString:@"?"];
    
    [parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *paramer = [NSString stringWithFormat:@"%@=%@&", key, obj];
      
        urlWithParamterString = [urlWithParamterString stringByAppendingString:paramer];
    }];

    urlWithParamterString = [urlWithParamterString substringToIndex:urlWithParamterString.length-1];

    NSLog(@"\n\n路径--%@\n\n", urlWithParamterString);
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
    AFNetworkReachabilityManager *reachable = [AFNetworkReachabilityManager sharedManager];
   
    BOOL iswifi = NO;
    if (reachable.networkReachabilityStatus ==  AFNetworkReachabilityStatusReachableViaWiFi){
        iswifi = YES;
    }
    return iswifi;
}

// 是否3G
+ (BOOL)isEnableWWAN{
   
    AFNetworkReachabilityManager *reachable = [AFNetworkReachabilityManager sharedManager];
    if ( reachable.networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN)//有网且不是wifi
        return YES;
    else
        return NO;
}

//网络是否可用
+ (BOOL)isNoNet{
  
    AFNetworkReachabilityManager *reachable = [AFNetworkReachabilityManager sharedManager];
    if (reachable.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        return YES;
    }
    else
        return NO;
}



@end
