//
//  TableViewCell.m
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/30.
//  Copyright © 2018年 BryantStudio. All rights reserved.
//

#import "TableViewCell.h"
#import "UIImageView+cache.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@implementation TableViewCell

- (void)setModel:(NSDictionary *)dict {
    [self.contentView addSubview:self.testImageView];
    [_testImageView hyl_setImageWithURL:dict[@"picture"] withPlaceHolder:[UIImage imageNamed:@"default"] withSuccess:^(UIImage *image, BOOL cache) {
        
    }];
}


- (UIImageView *)testImageView {
    if (!_testImageView) {
        _testImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 90) / 2, (120 - 90) / 2, 90, 90)];
        _testImageView.contentMode = UIViewContentModeScaleAspectFill;
        _testImageView.clipsToBounds = YES;
        
    }
    return _testImageView;
}

@end
