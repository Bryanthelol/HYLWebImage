//
//  HYLWebImageCache.m
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//

#import "HYLWebImageCache.h"
#import <objc/runtime.h>

static char *memoryKey;

@implementation HYLWebImageCache

+ (void)saveImageToLocalStorage:(UIImage *)image forKey:(NSString *)key {
    if (image != nil && key != nil) {
        NSString *filePath = [[self getLocalStorageDirectory] stringByAppendingPathComponent:key];
        NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        if ([data writeToFile:filePath atomically:YES]) {
            NSLog(@"保存图片到本地成功");
        } else {
            NSLog(@"保存图片到本地失败");
        }
    }
}

+ (UIImage *)localStorageImageForKey:(NSString *)key {
    if (key != nil) {
        NSString *filePath = [[self getLocalStorageDirectory] stringByAppendingPathComponent:key];
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        if (data) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            return image;
        } else {
            return nil;
        }
    }
    return nil;
}

+ (NSString *)getLocalStorageDirectory {
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"HYLWebImageDefault"];
    BOOL isDirectory = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}





+ (void)saveImageToMemory:(UIImage *)image forKey:(NSString *)key{
    if (image != nil && key != nil) {
        NSMutableArray *imageMutaArray = [self getMemoryMutaArray];
        NSDictionary *KeyImageDict = @{@"key": key, @"image": image};
        [imageMutaArray addObject:KeyImageDict];
        NSLog(@"保存图片到内存成功");
        if (imageMutaArray.count > 10) {
            [imageMutaArray removeObjectAtIndex:0];
        }
    }
}

+ (UIImage *)memoryImageForKey:(NSString *)key {
    if (key != nil) {
        NSMutableArray *imageMutaArray = [self getMemoryMutaArray];
        __block UIImage *image = nil;
        [imageMutaArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *keyImageDict = (NSDictionary *)obj;
            if ([keyImageDict[@"key"] isEqualToString:key]) {
                image = keyImageDict[@"image"];
                *stop = YES;
            }
        }];
        return image;
    }
    return  nil;
}

+ (NSMutableArray *)getMemoryMutaArray {
    NSMutableArray *imageMutaArray = objc_getAssociatedObject(self, &memoryKey);
    if (!imageMutaArray) {
        imageMutaArray = [NSMutableArray arrayWithCapacity:0];
        objc_setAssociatedObject(self, &memoryKey, imageMutaArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageMutaArray;
}


@end
