//
//  NSObject+BLPreload.h
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLRequestConfig;

@interface NSObject (BLPreload)


/**  *  当前页码 */
@property (nonatomic, assign) NSInteger currentblPage;


/** 上拉加载更多无更多数据 */
@property (nonatomic, assign)  BOOL noRefreshData;

/** *  模型数组 */
@property (nonatomic, strong) NSMutableArray *model_blArray;

/*! 未经处理的源数据 */
@property (nonatomic, strong) id orgin_Object;



/**
 预加载方法
 
 @param config 请求参数的一些配置，包括参数、刷新、模型、分页等
 @param success 请求成功能block，response参数，根据需要会传不同的值
 @param failure 加载失败或无数据return，当failure 为nil时，无数据，只结束刷新，不刷新tableView
 
 - (void) loadPlayerRecod:(BOOL)refresh {
 
 BLRequestConfig *config = [BLRequestConfig new];
 
 config.url = [HTTPInterface studyRecords];
 config.keyOfPage = @"page.currentPage";
 config.convertKeyPath = @"entity/studyList";
 config.modelClass = @"BLMyRecordDataModel";
 config.isRefreshing = refresh;
 config.requestDict =  @{ @"userId": USERID }.mutableCopy;
 config.dealSecond = YES;
 MJWeakSelf
 __block NSMutableArray *tempArr = @[].mutableCopy;
 [self.tableView request:config success:^(id response) {
 
 [weakSelf.myRecordTableView endBLReload];
 [weakSelf.myRecordTableView reloadData];
 
 } failure:^(NSError *failure) {
 
 [weakSelf.tableView endBLReload];
 if (failure) {
 [weakSelf.tableView reloadData];
 }
 }];
 
 }
 */
- (void)request:(BLRequestConfig *)config success:(void (^)(id response))success failure:(void (^)(NSError * failure))failure;

@end


