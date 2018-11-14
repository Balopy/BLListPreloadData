//
//  TableViewController.m
//  MVVM_Demo
//
//  Created by Balopy on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import "TableViewController.h"
#import "BLRequestConfig.h"
#import "BLListItem.h"
#import "NSObject+BLPreload.h"


@interface TableViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation TableViewController
static NSString *classGrandDynamicID = @"classGrandDynamicID";

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:classGrandDynamicID];
    }
    
    return self;
    
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classGrandDynamicID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [tableView bl_PreloadDataWithCurrentIndex:indexPath.row totalCount:self.dataArray.count];
    BLListItem *item = self.dataArray[indexPath.row];
    
    cell.textLabel.text = item.courseName;
    cell.detailTextLabel.text = item.title;

//    [cell.imageView setImageURL:[NSURL URLWithString:@"http://img.51xiaoniu.cn/product/main_assets/assets/5712/0941/206a/af16/68f3/088a/569869fbaf4843084c0007ba.jpg"]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
