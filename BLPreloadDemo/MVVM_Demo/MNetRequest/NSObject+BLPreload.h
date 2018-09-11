//
//  NSObject+BLPreload.h
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLRequestConfig;

@interface UIScrollView (BLPreload)


/**  *  当前页码 */
@property (nonatomic, assign) NSInteger currentPage;


/** 上拉加载更多无更多数据 */
@property (nonatomic, assign)  BOOL noRefreshData;

/** *  模型数组 */
@property (nonatomic, strong) NSMutableArray *model_blArray;



- (void)request:(BLRequestConfig *)config success:(void (^)(id response))success failure:(void (^)(NSError * failure))failure;

@end


