//
//  MNetRequestModel.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "MNetRequestModel.h"

@implementation MNetRequestModel

/** 2 * 请求 */
+ (void)httpRequest:(BLRequestConfig *)config success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    
    __block MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    HUD.animationType=MBProgressHUDAnimationFade;
    if (config.mbprogress) HUD.label.text = config.mbprogress;
    else HUD.label.text = @"正在加载";
    [HUD showAnimated:YES];
    
    NSDictionary *paramet = [BLRequestConfig parameterExchange:config.requestDict url:config.url];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encoded = [config.url stringByAddingPercentEncodingWithAllowedCharacters:set];//请路径+加密参数
    
    
    
    NSString *tempstr = [NSString stringWithFormat:@"%@%@", config.url, config.requestDict];
    NSString *path = [BLRequestConfig cacheFilePath:tempstr];
    NSLog(@"缓存：%@", path);

    AFHTTPSessionManager *manager = [self sessionManager];
    [manager POST:encoded parameters:paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success != nil) {
            success(responseObject);
            [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        if (failure != nil) {
            failure(error);
            [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
        }
        BLLog(@"----failure---%@", error.description);
        
        HUD.animationType = MBProgressHUDModeText;
        
        HUD.label.text=@"请求失败,重新发送请求";
        [HUD performSelector:@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
    }];
    
}




/** 1 * post 请求 无进度 */
+ (void)request:(BLRequestConfig *)config success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *paramet = [BLRequestConfig parameterExchange:config.requestDict url:config.url];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encoded = [config.url stringByAddingPercentEncodingWithAllowedCharacters:set];//请路径+加密参数
    
    
    NSString *tempstr = [NSString stringWithFormat:@"%@%@", config.url, config.requestDict];
    NSString *path = [BLRequestConfig cacheFilePath:tempstr];//文件路径
    
    
    NSLog(@"缓存：%@", path);
    
    //设置缓存, 如果有缓存且没有过期,有就取。
    BOOL timeValide = false;
    timeValide = [BLRequestConfig inAvailabilityWithCachTime:config.cashTime path:path];

    if (config.cashSeting && timeValide) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL isFileExist = [fileManager fileExistsAtPath:path];
        
        if (isFileExist) { //文件存在
            //如果本地缓存存在
            dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                id cachedData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (success != nil)
                        success(cachedData);
                });
            });
            
        } else {//如果文件不存，则去请求数据，创建缓存，这个方法，可能不会走，因为一般都会创建成功
            
            AFHTTPSessionManager *manager = [self sessionManager];
            [manager POST:encoded parameters:paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (success) {
                    success(responseObject);
                    
                    // 既有设置缓存数据, 简单粗爆，
                    [self saveCashData:responseObject jsonValide:config.jsonValidator cachedPath:path];
                }
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
                BLLog(@"----failure---%@", error.description);
                if (failure != nil) {
                    failure(error);
                }
            }];
        }
    } else {

        ///增加这几行代码；
        AFHTTPSessionManager *manager = [self sessionManager];
        [manager POST:encoded parameters:paramet progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (success) {
                success(responseObject);
                
                if (config.cashSeting) {//如果设置缓存了，但是过期了
                    
                    if (!timeValide) {//如果过期了，重新缓存
                        
                        // 缓存数据, 简单粗爆，
                        [self saveCashData:responseObject jsonValide:config.jsonValidator cachedPath:path];
                    }
                } else {
                //没有缓存，pass
                }
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            BLLog(@"----failure---%@", error.description);
            if (failure != nil) {
                failure(error);
            }
        }];
    }
}

+ (AFHTTPSessionManager *) sessionManager {
    ///增加这几行代码；
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:10.f];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    return manager;
}

+(void)saveCashData:(id)responseData jsonValide:(NSString *)jsonValide cachedPath:(NSString *)path {
    // 异步处理耗时操作(缓存数据)
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [BLRequestConfig saveCashDataForArchiver:responseData jsonValidator:jsonValide cachPath:path];
    });
}


+ (void) uploadWithImagesInSeting:(BLRequestConfig *)config
                          success:(void (^)(id responseData))success
                          failure:(void (^)(NSError *error))failure{
    
    __block NSMutableArray *tempArr = @[].mutableCopy;
    /// UIImage对象 -> NSData对象
    NSArray *icons = config.orginObject;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *paramet = [BLRequestConfig parameterExchange:config.requestDict url:config.url];
    [manager POST:config.url parameters:paramet constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (icons.count > 0) {
            
            for (int i = 0; i < icons.count; i++) {
                UIImage *image = icons[i];
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                if (imageData.length > 1024*1024) {
                    //                    image = (UIImage *)[image imageByResizeToSize:CGSizeMake(kScreen_width, kScreen_width*(image.size.height/image.size.width)) contentMode:UIViewContentModeScaleAspectFill];
                    
                    imageData = UIImageJPEGRepresentation(image, 1);
                }
                // 可以在上传时使用当前的系统事件作为文件名
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                // 设置时间格式
                [formatter setDateFormat:@"yyyyMMddHHmmss"];
                NSString *dateString = [formatter stringFromDate:[NSDate date]];
                NSString *fileName = [NSString stringWithFormat:@"%d%@.png", i, dateString];
                
                [formData appendPartWithFileData:imageData name:@"fileupload" fileName:fileName mimeType:@"image/png"];
            }
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            NSData *reciveData = responseObject;
            NSString *reciveString = [[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding];
            [tempArr addObject:reciveString];
            if (success) {
                success(tempArr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        BLLog(@"Error: %@", error);
        if (failure)  failure(error);
    }];
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


