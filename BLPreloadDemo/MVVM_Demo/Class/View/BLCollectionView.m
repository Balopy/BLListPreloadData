//
//  BLCollectionView.m
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import "BLCollectionView.h"
#import "CollectionViewCell.h"
#import "BLListItem.h"
@implementation BLCollectionView
static NSString *levelIdentifier = @"levelBtnCollectionViewCell";


+ (instancetype)collectionViewWithFrame:(CGRect)frame
{
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    return [[self alloc] initWithFrame:frame collectionViewLayout:flowLayout];
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
   
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:levelIdentifier];
        
    }
    return self;
}


- (void)setSourceData:(NSArray *)sourceData {
    
    _sourceData = sourceData;
    
    [self reloadData];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
#pragma mark ---- item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return self.sourceData.count;
}

#pragma mark ----  The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /// 重用cell
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:levelIdentifier forIndexPath:indexPath];
    
    BLListItem *model = self.sourceData[indexPath.row];
    
    cell.itemLabel.text = model.courseName;
    
    return cell;
}


#pragma mark ---- 定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(kScreen_width, 50);
    
}



#pragma mark ---- 定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}



@end
