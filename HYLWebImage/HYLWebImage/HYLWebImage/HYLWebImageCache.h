//
//  HYLWebImageCache.h
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYLWebImageCache : NSObject

+ (void)saveImageToLocalStorage:(UIImage *)image forKey:(NSString *)key; // 保存图片到本地
+ (UIImage *)localStorageImageForKey:(NSString *)key; // 根据key取出本地图片

+ (void)saveImageToMemory:(UIImage *)image forKey:(NSString *)key; // 保存图片到内存
+ (UIImage *)memoryImageForKey:(NSString *)key; // 根据key取出内存图片
@end
