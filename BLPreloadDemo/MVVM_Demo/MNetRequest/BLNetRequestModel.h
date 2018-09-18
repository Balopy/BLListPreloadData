//
//  BLNetRequestModel.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLRequestConfig;

@interface BLNetRequestModel : NSObject

/** 1 * post 请求 无进度 */
+ (void)httpRequest:(BLRequestConfig *)config success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure;


/** 2 * post 请求 无进度 */
+ (void)request:(BLRequestConfig *)config success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure;


+ (void) uploadWithImagesInSeting:(BLRequestConfig *)config
                          success:(void (^)(id responseData))success
                          failure:(void (^)(NSError *error))failure;

@end

