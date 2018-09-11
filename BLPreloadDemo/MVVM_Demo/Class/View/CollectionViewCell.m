//
//  CollectionViewCell.m
//  MVVM_Demo
//
//  Created by 王春龙 on 2018/9/7.
//  Copyright © 2018年 Balopy. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
        self.itemLabel = [[UILabel alloc] init];
        self.itemLabel.frame = self.bounds;
        self.itemLabel.font = [UIFont systemFontOfSize:20];
        self.itemLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.itemLabel];

    }
    return self;
}
@end
