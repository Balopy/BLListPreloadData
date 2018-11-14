//
//  BLCustomerViewIfNoData.m
//  Demo_268EDU
//
//  Created by 268 on 2017/11/22.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "BLCustomerViewIfNoData.h"
#import <Masonry.h>
#import "UIButton+Balopy.h"


@interface BLCustomerViewIfNoData ()

/*! 显示文字 */
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UILabel *firstLabel;
@property (weak, nonatomic) UILabel *secondLabel;
@property (weak, nonatomic) UIButton *reloadBtn;

@end

@implementation BLCustomerViewIfNoData

+ (instancetype) showView:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _imageView = imageView;
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        reloadBtn.blTitle = @"";
        reloadBtn.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        reloadBtn.blColor = [UIColor whiteColor];
        reloadBtn.blFont = [UIFont systemFontOfSize:14];
        reloadBtn.layer.cornerRadius = 15;
        reloadBtn.bl_acceptEventInterval = 1.5;
        [reloadBtn addTarget:self action:@selector(reloadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:reloadBtn];
        _reloadBtn = reloadBtn;
        
    }
    return self;
}

- (void) reloadBtnClick:(UIButton *)sender {
    if (self.reloadDataBlock) {
        self.reloadDataBlock(sender);
    }
}
- (void)showViewWithFirstTitle:(BOOL)isfirst secondTitle:(BOOL)isSecond btnTitle:(NSString *)title imageName:(NSString *)imagename {
    
    if (!title) {
        title = @"";
    }
    UIImage *image = [UIImage imageNamed:imagename];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            [self.reloadBtn setTitle:title forState:UIControlStateNormal];
        });
    });
    
    NSLog(@"------%@", NSStringFromCGRect(self.frame));
    
    if (isfirst) {//有值
        
        [self.firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);//图片上边距，下间距
        }];
    }
    
    if (isSecond) {//有值
        
        [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.firstLabel.mas_bottom).offset(8);
            make.centerX.equalTo(self);
        }];
    }
    
    
    /*! 如果有二，用二，如果无二有一，用一，如果两者都没有，用image */
    [self.reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (isSecond) {//默认有二
            make.top.equalTo(self.secondLabel.mas_bottom).offset(20);
        } else if (isfirst) {
            make.top.equalTo(self.firstLabel.mas_bottom).offset(20);
        } else {
            make.top.equalTo(self.imageView.mas_bottom).offset(20);
        }
        make.centerX.equalTo(self);
        
        CGFloat width = [title sizeWithFont:self.reloadBtn.blFont].width + 30;
        if (title.length == 0) {
            width = 0;
        }
        make.width.equalTo(@(width));
        make.height.equalTo(@(30));
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (isfirst) {
           
            make.bottom.equalTo(self.firstLabel.mas_top)
            .offset(-15);
        } else {
            
            make.centerY.equalTo(self);
        }
        make.centerX.equalTo(self);
    }];
}

- (void)firstLabel:(NSString *)mark attributedStr:(NSString *)attributed normalColor:(UIColor *)color selectedColor:(UIColor *)selected {
    
    NSString *period = [attributed stringByAppendingString:@"。"];
    NSString *temp = [NSString stringWithFormat:@"%@，%@", mark, period];
    NSRange range = [temp rangeOfString:period];
    
    NSDictionary *dict = @{NSForegroundColorAttributeName : color};
    
    NSMutableAttributedString *attrubStrig = [[NSMutableAttributedString alloc] initWithString:temp attributes:dict];
    
    [attrubStrig addAttribute:NSForegroundColorAttributeName value:selected range:range];
    
    self.firstLabel.attributedText = attrubStrig;
}

- (void) firstLabel:(NSString *)mark normalColor:(UIColor *)color {
    self.firstLabel.text = mark;
    self.firstLabel.textColor = color;
}
- (void) secondLabel:(NSString *)mark normalColor:(UIColor *)color {
    self.secondLabel.text = mark;
    self.secondLabel.textColor = color;
}



- (UILabel *)firstLabel {
    
    if (!_firstLabel) {
        
        UILabel *firstLabel = [[UILabel alloc] init];
        firstLabel.textColor = [UIColor darkGrayColor];
        firstLabel.font = [UIFont systemFontOfSize:14];
        firstLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:firstLabel];
        _firstLabel = firstLabel;
    }
    
    return _firstLabel;
}

- (UILabel *)secondLabel {
    
    if (!_secondLabel) {
        
        UILabel *secondLabel = [[UILabel alloc] init];
        secondLabel.textColor = [UIColor darkGrayColor];
        secondLabel.font = [UIFont systemFontOfSize:14];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:secondLabel];
        _secondLabel = secondLabel;
    }
    return _secondLabel;
}

@end
