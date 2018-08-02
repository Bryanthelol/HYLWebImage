//
//  UIImageView+cache.h
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/30.
//  Copyright © 2018年 BryantStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYLWebImageManager.h"

typedef void(^ImageViewCategorySuccessBlock)(UIImage *image, BOOL cache);

@interface UIImageView (cache)


- (void)hyl_setImageWithURL:(NSString *)url;

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(nullable UIImage *)placeholder;

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(nullable UIImage *)placeholder withSuccess:(ImageViewCategorySuccessBlock)success;

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(nullable UIImage *)placeholder withOptions:(HYLDownloaderOptions)options withSuccess:(ImageViewCategorySuccessBlock)success;


@end
