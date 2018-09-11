//
//  UIScrollView+MPreload.h
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
static NSInteger const PreloadMinCount = 3;

/*! 预加载用 */
typedef void(^BLPreloadBlock)(BOOL refresh);

/*! 刷新用 */
typedef void(^BLRefreshBlock)(void);

@interface UIScrollView (MPreload)

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
- (void)preloadDataWithCurrentIndex:(NSInteger)currentIndex totalCount:(NSUInteger)count;

/**
 *  下拉刷新
 *  @param bl_reloadBlock 刷新回调
 */
- (void)headerReloadBlock:(BLRefreshBlock)bl_reloadBlock;


/**
 *  上拉加载更多
 *  @param bl_reloadBlock 刷新回调
 */
- (void)footerReloadBlock:(BLRefreshBlock)bl_reloadBlock;


/**
 *  结束上拉刷新
 */
- (void)endBLReload;



@end
