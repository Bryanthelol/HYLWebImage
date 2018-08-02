//
//  HYLWebImageManager.h
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class HYLWebImageDownLoader;

typedef NS_ENUM(NSInteger, HYLDownloaderOptions) {
    HYLDownloaderDefaultOption = 1 << 0,
    HYLDownloaderIgnoreMemoryOption = 1 << 1,
    HYLDownloaderIgnoreLocalStorageOption = 1 << 2
};

typedef void(^ManagerSuccess)(UIImage *image, BOOL cache);
typedef void(^ManagerFailure)(NSError *error);

@interface HYLWebImageManager : NSObject

@property(nonatomic, assign) NSInteger maxCount; // 当前可下载数的最大值 默认为6

+ (HYLWebImageManager *)sharedInstance;
- (HYLWebImageDownLoader *)downloadWebImageWithURL:(NSString *)url withOption:(HYLDownloaderOptions)options withSuccess:(ManagerSuccess)successBlock withFailure:(ManagerFailure)failureBlock;

- (void)removeDownloader:(HYLWebImageDownLoader *)downloader; 

@end
