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

/** *是否将 model 做二级处理, 很重要，必须要分清楚 */
@property (nonatomic, assign)  BOOL dealSecond;

/** *  原始请求数据，未经处理的 */
@property (nonatomic, strong) id orginObject;


/*! 网络返回分布字段，通过些字段处理分页 */
@property (nonatomic, copy) NSString *keyOfPage;
/** * 是否刷新 */
@property (nonatomic, assign) BOOL isRefreshing;

/*! 缓存时间 */
@property (nonatomic, assign) NSTimeInterval cashTime;
/*! 是否缓存 */
@property (nonatomic, assign) BOOL cashSeting;

/*! 显示提示文本 */
@property (nonatomic, copy) NSString *mbprogress;




/*! json字段检验 */
+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator;


/*! 与后台约定加密码规则，所有参数进行排序，用|分隔，生成MD5串，以sign=MD5作为一个参数 */
+(NSMutableDictionary *)parameterExchange:(NSDictionary *)setting url:(NSString *)url;


/*! 使用接口地址/后接参数字典，通过md5生成字符串 */
+ (NSString *)cacheFilePath:(NSString *)path;

/**
 比较当前时间与缓存本地文件是否过期
 
 @param cashTime 网络请求缓存时间
 @param cachPath 缓存路径
 @return 如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1(过期)
 */
+(BOOL) inAvailabilityWithCachTime:(NSTimeInterval)cashTime path:(NSString *)cachPath;

/**
 将请求数据保存到本地
 
 @param responseData 当前请求数据
 @param jsonValidator 需要验证字段，如entity/list
 @param cachPath 缓存路径
 */
+(void) saveCashDataForArchiver:(id)responseData jsonValidator:(NSString *)jsonValidator cachPath:(NSString *)cachPath;

/**
 将路径进行md5加密
 
 @param string 数据文件储存路径
 @return 加密后的文件路径
 */
+ (NSString *)md5StringFromString:(NSString *)string ;


/**
 wifi网络是否可用
 
 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWIFI;

/**
 蜂窝数据是否可用
 
 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWWAN;

/**
 当前网络状态是否可用
 
 @return YES,网络状态不可用 NO,网络状态可用
 */
+ (BOOL) isNoNet;







@end
