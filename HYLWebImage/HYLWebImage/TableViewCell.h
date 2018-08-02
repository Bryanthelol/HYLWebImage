//
//  TableViewCell.h
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/30.
//  Copyright © 2018年 BryantStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *testImageView;
- (void)setModel:(NSDictionary *)dict;

@end
