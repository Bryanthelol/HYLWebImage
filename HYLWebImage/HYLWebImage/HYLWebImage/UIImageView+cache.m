//
//  UIImageView+cache.m
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/30.
//  Copyright © 2018年 BryantStudio. All rights reserved.
//

#import "UIImageView+cache.h"
#import <objc/runtime.h>

static char *imageViewCateKey;

@implementation UIImageView (cache)

- (void)hyl_setImageWithURL:(NSString *)url {
    [self hyl_setImageWithURL:url withPlaceHolder:nil withOptions:HYLDownloaderDefaultOption withSuccess:nil];
}

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(UIImage *)placeholder {
    [self hyl_setImageWithURL:url withPlaceHolder:placeholder withOptions:HYLDownloaderDefaultOption withSuccess:nil];
}

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(UIImage *)placeholder withSuccess:(ImageViewCategorySuccessBlock)success {
    [self hyl_setImageWithURL:url withPlaceHolder:placeholder withOptions:HYLDownloaderDefaultOption withSuccess:success];
}

- (void)hyl_setImageWithURL:(NSString *)url withPlaceHolder:(UIImage *)placeholder withOptions:(HYLDownloaderOptions)options withSuccess:(ImageViewCategorySuccessBlock)success {
    
    // 把downloader和UIImageView解绑
    [self unbindDownloaderWithKey:@"currentAddedDownloader" isRemoveFromQueue:YES];
    
    if (placeholder != nil) {
        self.image = placeholder;
    }
    ImageViewCategorySuccessBlock successBlock = success;
    
    __weak typeof (self) weakself = self;
    HYLWebImageDownLoader *downloader = [[HYLWebImageManager sharedInstance] downloadWebImageWithURL:url withOption:options withSuccess:^(UIImage *image, BOOL cache) {
        
        // 把downloader和UIImageView解绑
        [weakself unbindDownloaderWithKey:@"currentAddedDownloader" isRemoveFromQueue:NO];
        
        if (image) {
            NSLog(@"---%@---",[NSThread currentThread]);
            weakself.image = image;
            NSLog(@"给UIimageView赋值");
        }
        if (successBlock) {
            successBlock(image, cache);
        }
        
    } withFailure:^(NSError *error) {}];
    
    // 把downloader和UIImageView绑定
    if (downloader) {
        [[self getDownloaderMutaDict] setObject:downloader forKey:@"currentAddedDownloader"];
    }
}


- (void)unbindDownloaderWithKey:(NSString *)key isRemoveFromQueue:(BOOL)isRemoveFromQueue {
    HYLWebImageDownLoader *downloader = [[self getDownloaderMutaDict] objectForKey:key];
    if (downloader) {
        if (isRemoveFromQueue) {
            [[HYLWebImageManager sharedInstance] removeDownloader:downloader];
        }
        [((NSMutableDictionary *)[self getDownloaderMutaDict]) removeObjectForKey:key];
    }
}

- (NSMutableDictionary *)getDownloaderMutaDict {
    NSMutableDictionary *downloaderMutaDict = objc_getAssociatedObject(self, &imageViewCateKey);
    if (!downloaderMutaDict) {
        downloaderMutaDict = [NSMutableDictionary dictionaryWithCapacity:0];
        objc_setAssociatedObject(self, &imageViewCateKey, downloaderMutaDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return downloaderMutaDict;
}




@end
