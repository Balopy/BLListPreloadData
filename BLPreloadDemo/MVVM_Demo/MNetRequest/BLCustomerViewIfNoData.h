//
//  BLCustomerViewIfNoData.h
//  Demo_268EDU
//
//  Created by 268 on 2017/11/22.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BLSuccessBlock)(UIButton *paramer);
@interface BLCustomerViewIfNoData : UIView


+ (instancetype) showView:(CGRect)frame;

@property (copy, nonatomic) BLSuccessBlock reloadDataBlock;

@property (copy, nonatomic) NSString *secondTitle;

- (void)showViewWithFirstTitle:(BOOL)isfirst secondTitle:(BOOL)isSecond btnTitle:(NSString *)title imageName:(NSString *)imagename;

- (void) secondLabel:(NSString *)mark normalColor:(UIColor *)color;

- (void) firstLabel:(NSString *)mark normalColor:(UIColor *)color;
    
- (void)firstLabel:(NSString *)mark attributedStr:(NSString *)attributed normalColor:(UIColor *)color selectedColor:(UIColor *)selected;


@end
