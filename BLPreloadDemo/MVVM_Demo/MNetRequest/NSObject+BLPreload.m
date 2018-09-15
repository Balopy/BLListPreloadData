//
//  NSObject+BLPreload.m
//  MVVM_Demo
//
//  Created by Balopy on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import "NSObject+BLPreload.h"
#import "BLRequestConfig.h"

@implementation NSObject (BLPreload)

- (void)request:(BLRequestConfig *)config success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    //默认上拉有数据 = NO
    BOOL nomore = self.noRefreshData;
    if (nomore && !config.isRefreshing) {//没的更多数据
        
        if (failure)  failure(nil);
        return;
    }
    NSMutableDictionary *paramer = @{}.mutableCopy;
    if (config.requestDict) {
        [paramer addEntriesFromDictionary:config.requestDict];
    }
    
    if (config.keyOfPage) {// 有分页才会走
        
        if (config.isRefreshing) {//如果刷新，置1
            self.currentPage = 1;
        }
        [paramer setValue:@(self.currentPage) forKey:config.keyOfPage];
        self.currentPage++;//加1，回到第一页
    }
    
    //请求数据
    [MNetRequestModel request:config.url withParamters:paramer success:^(id responseData) {
        
        config.orginObject = responseData;//源数据，后面需要针对模型进行处理
        
        if (!self.model_blArray) {
            self.model_blArray = @[].mutableCopy;
        }
        
        if (config.isRefreshing) {//如果刷新，清空旧数据
            [self.model_blArray removeAllObjects];
        }
        
        NSArray *separateKeyArray = [config.convertKeyPath componentsSeparatedByString:@"/"];
        //根据传回的待转模型路径，找相应的数据，如entity/courseList
        id result = responseData;
        for (NSString *key in separateKeyArray) {
            result = result[key];
        }
        
        //转模型
        NSArray *dataArray;
        
        if (config.modelClass && config.modelClass.length) {
            
            id class = NSClassFromString(config.modelClass);
            dataArray = [NSArray modelArrayWithClass:class json:result];
        } else {
            dataArray = result;
        }
        
        if (!dataArray || dataArray.count == 0) {
            
            self.noRefreshData = YES;//如果为空，则无数据
            if (config.isRefreshing) {
                if (success) success(nil);
            } else {
                if (failure)  failure(nil);
            }
            return;
            
        } else {
            
            [self.model_blArray addObjectsFromArray:dataArray];
            
            if (config.keyOfPage)
                self.noRefreshData = NO;//有数据，可以加载更多
            
            else
                self.noRefreshData = YES;//有数据，但没有加载更多
        }
        
        if (config.dealSecond) {
            
            //如果进一步处理数据，把数据返回
            if (success) success(dataArray);
        }else{
            
            //如果不需要处理，直接返回累加数据
            if (success)  success(self.model_blArray);
        }
        
    } failure:^(NSError *error) {
        
        //请求失败，刷新再次请求当前页
        if (self.currentPage > 1)  self.currentPage --;
        
        if (failure)  failure(error);
    }];
}


#pragma mark - 初始化属性
#pragma mark objc_setAssociatedObject/objc_getAssociatedObject 动态向类中添加方法
/*! _cmd, @selector(requestConfig), 要成对出现，
 还可以，声明一个参数， static NSString *key = @"key", 使用&key，要保持一致 */
- (BLRequestConfig *)requestConfig {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRequestConfig:(BLRequestConfig *)requestConfig {
    
    objc_setAssociatedObject(self, @selector(requestConfig), requestConfig, OBJC_ASSOCIATION_RETAIN);
}


- (NSInteger)currentPage{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setCurrentPage:(NSInteger)currentPage{
    
    objc_setAssociatedObject(self, @selector(currentPage), @(currentPage), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)noRefreshData {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setNoRefreshData:(BOOL)noRefreshData {
    
    objc_setAssociatedObject(self, @selector(noRefreshData), @(noRefreshData), OBJC_ASSOCIATION_ASSIGN);
}


- (NSMutableArray *)model_blArray {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setModel_blArray:(NSMutableArray *)model_blArray {
    
    objc_setAssociatedObject(self, @selector(model_blArray), model_blArray, OBJC_ASSOCIATION_RETAIN);
}


@end
