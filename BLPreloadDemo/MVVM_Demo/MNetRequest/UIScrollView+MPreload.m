//
//  UIScrollView+MPreload.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UIScrollView+MPreload.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>
#import "NSObject+BLPreload.h"
#import "BLShowViewIfNoData.h"

@interface UIScrollView ()
@property (nonatomic, strong) BLShowViewIfNoData *showView;

@end
@implementation UIScrollView (MPreload)

- (BLPreloadBlock)bl_preloadBlock{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBl_preloadBlock:(BLPreloadBlock)bl_preloadBlock{
    
    objc_setAssociatedObject(self, @selector(bl_preloadBlock), bl_preloadBlock, OBJC_ASSOCIATION_COPY);
}


- (BLShowViewIfNoData *)showView{
    
    BLShowViewIfNoData *showView = objc_getAssociatedObject(self, _cmd);
    if (!showView) {
        
        CGRect frame = self.frame;
        frame.origin = CGPointZero;
        showView = [BLShowViewIfNoData showView:frame];
        showView.reloadDataBlock = ^(UIButton *paramer) {
            
            if (self.bl_preloadBlock) self.bl_preloadBlock(YES);
        };
        [self addSubview:showView];
        
        objc_setAssociatedObject(self, @selector(showView), showView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return showView;
}
// 关联对象



- (void)setShowView:(BLShowViewIfNoData *)showView {
    
    objc_setAssociatedObject(self, @selector(showView), showView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)headerReloadBlock:(BLRefreshBlock)bl_reloadBlock{
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:bl_reloadBlock];
    [header beginRefreshing];
    self.mj_header = header;
    
}

- (void)footerReloadBlock:(BLRefreshBlock)bl_reloadBlock {
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:bl_reloadBlock];
    self.mj_footer = footer;
}

- (void)endBLReload{
    
    if (self.mj_header.isRefreshing) {
        
        [self.mj_header endRefreshing];
        [self.mj_footer resetNoMoreData];
        
    } else {
        
        if (self.noRefreshData) {
            
            [self.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.mj_footer endRefreshing];
        }
    }
    
    if ([self getUIScrollViewItemsCount]) {
        
        [self.showView removeFromSuperview];
    } else {
        
        [self.showView showViewWithFirstTitle:YES secondTitle:YES btnTitle:@"是不是没有数据" imageName:@"占位图"];
        [self.showView firstLabel:@"你好，你访问的数据" normalColor:[UIColor blueColor]];
        [self.showView secondLabel:@"我是老二" normalColor:[UIColor orangeColor]];
    }
}



/*! currentindex，cell 当前行
 count，当前列表数据 */
- (void)preloadDataWithCurrentIndex:(NSInteger)currentIndex totalCount:(NSUInteger)count{
    
    BOOL same = (currentIndex == count - PreloadMinCount);
    BOOL big = (currentIndex >= PreloadMinCount);
    
    if (same && big && self.bl_preloadBlock) {
        
        self.bl_preloadBlock(NO);
    }
}



- (NSInteger)getUIScrollViewItemsCount {
 
    NSInteger items = 0;
    
    // UIScollView 数据源不存在，退出
    if (![self respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    // UITableView support
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }
    // UICollectionView support
    else if ([self isKindOfClass:[UICollectionView class]]) {
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    
    return items;
}


@end
