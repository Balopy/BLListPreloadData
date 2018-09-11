//
//  BLCollectionView.h
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCollectionView : UICollectionView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
+ (instancetype)collectionViewWithFrame:(CGRect)frame;

/*! <#注释#> */
@property (nonatomic, strong) NSArray *sourceData;
@end
