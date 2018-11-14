//
//  HomeViewController.m
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/3/31.
//  Copyright © 2018年 Balopy. All rights reserved.
/*
 RAC 的核心思想：创建信号 - 订阅信号 - 发送信号
 
 */

#import "HomeViewController.h"
#import "BLRequestConfig.h"
#import "BLListItem.h"
#import "NSObject+BLPreload.h"
#import "BLCollectionView.h"
#import "TableViewController.h"
@interface HomeViewController ()


/*! <#注释#> */
//@property (nonatomic, strong) BLCollectionView *tableView;
@property (nonatomic, strong) TableViewController *tableView;

@end


@implementation HomeViewController

static NSString *const Test_Page_URL = @"http://t.268xue.com/app/study/records.json";

static NSString *classGrandDynamicID = @"classGrandDynamicID";

- (void)viewDidLoad {
    [super viewDidLoad];
  
//    self.tableView = [BLCollectionView collectionViewWithFrame:self.view.bounds];
   
    CGRect frame = self.view.bounds;
    self.tableView = [[TableViewController alloc] initWithFrame:frame style:UITableViewStylePlain];
    
    [self.view addSubview:self.tableView];
    
    
    [self addRefreshFromDynamicClass];
}

-(void) signalFromTableViewRefresh:(BOOL)refresh{
  
    BLRequestConfig *config = [BLRequestConfig new];
  
    config.url = Test_Page_URL;
    config.keyOfPage = @"page.currentPage";
    config.convertKeyPath = @"entity/studyList";
    config.modelClass = @"BLListItem";
    config.isRefreshing = refresh;
    config.cashSeting = YES;
    
    config.requestDict = @{ @"userId": @"97" }.mutableCopy;
    config.jsonValidator = @{@"entity":[NSArray class]};
    
    __weak typeof(self) weakSelf = self;
    
    [self.tableView request:config success:^(id response) {
        
        weakSelf.tableView.dataArray = response;

        [weakSelf.tableView endBLReloadWithPlaceHolder:@"占位图" title:@"暂无数据"];
   
    } failure:^(NSError *failure) {
        [weakSelf.tableView endBLReloadWithPlaceHolder:@"占位图" title:@"暂无数据"];
        if (failure) {
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)addRefreshFromDynamicClass {
   
    __weak typeof(self) weakself = self;

    [self.tableView bl_HeaderReloadBlock:^{
        
        
        [weakself signalFromTableViewRefresh:YES];
    }];

    self.tableView.bl_preloadBlock = ^{
        
        [weakself signalFromTableViewRefresh:NO];
    };

    
}



@end
