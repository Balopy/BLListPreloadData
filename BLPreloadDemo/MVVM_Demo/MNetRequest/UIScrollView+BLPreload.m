//
//  UIScrollView+BLPreload.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UIScrollView+BLPreload.h"
#import <objc/runtime.h>
#import "NSObject+BLPreload.h"
#import "BLCustomerViewIfNoData.h"

@interface UIScrollView ()
@property (nonatomic, strong) BLCustomerViewIfNoData *showView;
@property (nonatomic, strong) MJRefreshBackNormalFooter *bl_footer;
@end
@implementation UIScrollView (BLPreload)

- (BLPreloadBlock)bl_preloadBlock{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBl_preloadBlock:(BLPreloadBlock)bl_preloadBlock{
    
    objc_setAssociatedObject(self, @selector(bl_preloadBlock), bl_preloadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(CGFloat))placeHoder_bl_heigt {
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setPlaceHoder_bl_heigt:(void (^)(CGFloat))placeHoder_bl_heigt {
   
    objc_setAssociatedObject(self, @selector(placeHoder_bl_heigt), placeHoder_bl_heigt, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BLCustomerViewIfNoData *)showView{
    
    BLCustomerViewIfNoData *showView = objc_getAssociatedObject(self, _cmd);
    if (!showView) {
        
        CGRect frame = self.frame;
        frame.origin = CGPointZero;
        frame.size.height = kScreen_width;
        showView = [BLCustomerViewIfNoData showView:frame];
        showView.hidden = YES;
        showView.reloadDataBlock = ^(UIButton *paramer) {
            
            [self bl_StartRefreshing];
        };
        
        [self addSubview:showView];

        objc_setAssociatedObject(self, @selector(showView), showView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    return showView;
}
// 关联对象



- (void)setShowView:(BLCustomerViewIfNoData *)showView {
    
    objc_setAssociatedObject(self, @selector(showView), showView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MJRefreshBackNormalFooter *)bl_footer {
   
    MJRefreshBackNormalFooter *bl_footer = objc_getAssociatedObject(self, _cmd);
    
    if (!bl_footer) {

        bl_footer = [[MJRefreshBackNormalFooter alloc] init];
        objc_setAssociatedObject(self, @selector(bl_footer), bl_footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return bl_footer;
}

- (void)setBl_footer:(MJRefreshBackNormalFooter *)bl_footer {
   
    objc_setAssociatedObject(self, @selector(bl_footer), bl_footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bl_HeaderReloadBlock:(BLRefreshBlock)bl_reloadBlock{
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:bl_reloadBlock];
     self.mj_header = header;
    
    [self bl_StartRefreshing];
}

- (void)bl_StartRefreshing {
    [self.mj_header beginRefreshing];
    
    if (@available(iOS 11.0, *)) {
        
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
    }
}


- (void)endBLReloadWithPlaceHolder:(NSString *)imageName title:(NSString *)noDataTitle {
    
    if (self.mj_header.isRefreshing) {
        [self.bl_footer resetNoMoreData];
        [self.mj_header endRefreshing];
    } else  {
        
        if (self.noRefreshData) {
            [self.bl_footer endRefreshingWithNoMoreData];
            self.mj_footer = self.bl_footer;
        } else {

            self.mj_footer = nil;
        }
    }
    
    if ([self isKindOfClass:[UITableView class]]) {
        
        UITableView *tableView = (UITableView *)self;
        
        if ([self getUIScrollViewItemsCount]) {
            
            self.showView.hidden = YES;
            tableView.tableFooterView = nil;
        } else {
            
            tableView.tableFooterView = self.showView;;
            
            self.showView.hidden = NO;
            [self noDataPlaceholder:imageName firstTitle:noDataTitle];
        }
        
    } else {
        if ([self getUIScrollViewItemsCount]) {
            
            self.showView.hidden = YES;
        } else {
            
            self.showView.hidden = NO;
            [self noDataPlaceholder:imageName firstTitle:noDataTitle];
        }
    }
}

- (void)noDataPlaceholder:(NSString *)iconName firstTitle:(NSString *)title {
    
    [self.showView showViewWithFirstTitle:YES secondTitle:NO btnTitle:@"点击重试" imageName:iconName];
    [self.showView firstLabel:title normalColor:[UIColor darkGrayColor]];

    NSLog(@"----%@", NSStringFromCGSize(self.contentSize));

}


/*! currentindex，cell 当前行
 count，当前列表数据 */
- (void)bl_PreloadDataWithCurrentIndex:(NSInteger)currentIndex totalCount:(NSUInteger)count {
    
    BOOL same = (currentIndex == count - blPreloadMinCount);
    BOOL big = (currentIndex >= blPreloadMinCount);
    
    if (same && big && self.bl_preloadBlock) {
        
        self.bl_preloadBlock();
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
