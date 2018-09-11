//
//  MNetRequestModel.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MNetRequestModel : NSObject

+ (void)request:(NSString *)urlString withParamters:(NSDictionary *)dic success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure;

@end

