//
//  UIScrollView+BLPreload.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWeakSelf(type)__weak typeof(type)weak##type = type;

#define kStrongSelf(type)__strong typeof(type)type = weak##type;

/**
 *  预加载触发的数量
 */
static NSInteger const blPreloadMinCount = 3;

/*! 预加载用 */
typedef void(^BLPreloadBlock)(void);

/*! 刷新用 */
typedef void(^BLRefreshBlock)(void);

@interface UIScrollView (BLPreload)

/**
 *  点击无数据view，重新刷新
 *  refresh 刷新回调， 默认是预加载
 */
@property (nonatomic, copy) BLPreloadBlock bl_preloadBlock;
/**
 *  计算当前index是否达到预加载条件并回调
 *
 *  @param currentIndex row or section
 */
- (void)bl_PreloadDataWithCurrentIndex:(NSInteger)currentIndex totalCount:(NSUInteger)count;

/**
 *  下拉刷新
 *  @param bl_reloadBlock 刷新回调
 */
- (void)bl_HeaderReloadBlock:(BLRefreshBlock)bl_reloadBlock;


/*! 开始刷新 */
- (void) bl_StartRefreshing;
/**
 *  结束上拉刷新
 *  @param imageName 无数据图片占位图
 *  @param noDataTitle 无数据显示文字
 *  如果请求失败，则只用于error 不为空时的情况
 */
- (void)endBLReloadWithPlaceHolder:(NSString *)imageName title:(NSString *)noDataTitle;


@property (nonatomic, copy) void (^placeHoder_bl_heigt) (CGFloat maxY);

@end
