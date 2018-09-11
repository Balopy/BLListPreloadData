//
//  BLRequestConfig.h
//  MVVM_Demo
//
//  Created by Balopy on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLRequestConfig : NSObject

/*! 请求参数 */
@property (nonatomic, strong) NSMutableDictionary *requestDict;
/*! 接口地址 */
@property (nonatomic, copy) NSString *url;

/*! 需要转换的模型，使用字符串转成class */
@property (nonatomic, copy) NSString *modelClass;

/*! 模型转换数据关键字，如courseList：[]，需要转成模型 */
@property (nonatomic, copy) NSString *convertKeyPath;

/*! 验证待转数据是否是json类型 */
@property (nonatomic, strong) id jsonValidator;

/** *是否将 model 做二级处理*/
@property (nonatomic, assign)  BOOL dealSecond;

/** *  原始请求数据，未经处理的 */
@property (nonatomic, strong) id orginObject;


/*! 网络返回分布字段，通过些字段处理分页 */
@property (nonatomic, copy) NSString *keyOfPage;
/** * 是否刷新 */
@property (nonatomic, assign) BOOL isRefreshing;


@end
