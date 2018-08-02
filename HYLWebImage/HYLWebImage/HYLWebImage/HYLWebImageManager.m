//
//  HYLWebImageManager.m
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//

#import "HYLWebImageManager.h"
#import "HYLWebImageDownLoader.h"
#import "HYLWebImageCache.h"
#import <CommonCrypto/CommonCrypto.h>

#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@interface HYLWebImageManager ()

@property(nonatomic, strong) NSMutableArray *downloaderQueue; // 下载队列
@property(nonatomic, strong) NSMutableArray *preDownloaderQueue; // 预下载队列

@property(nonatomic, copy) ManagerSuccess managerSuccessBlock;
@property(nonatomic, copy) ManagerFailure managerFailureBlock;

@end

@implementation HYLWebImageManager

+ (HYLWebImageManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static HYLWebImageManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
        instance.maxCount = 6;
    });
    return instance;
}


- (HYLWebImageDownLoader *)downloadWebImageWithURL:(NSString *)url withOption:(HYLDownloaderOptions)options withSuccess:(ManagerSuccess)successBlock withFailure:(ManagerFailure)failureBlock {
    if (url == nil) {
        NSLog(@"URL 错误");
        return nil;
    }
    
    _managerSuccessBlock = successBlock;
    _managerFailureBlock = failureBlock;
    __weak typeof (self) weakself = self;
    
    NSString *key = [self md5:url];
    UIImage *image = nil;
    if (!(options & HYLDownloaderIgnoreMemoryOption)) {
        // 未忽略内存，从内存中读取
        image = [HYLWebImageCache memoryImageForKey:key];
    }
    
    if (!image) {
        // 内存中不存在，从本地读取
        if (!(options & HYLDownloaderIgnoreLocalStorageOption)) {
            // 未忽略本地
            image = [HYLWebImageCache localStorageImageForKey:key];
            if (image) {
                NSLog(@"从本地取到图片");
                [HYLWebImageCache saveImageToMemory:image forKey:key]; // 放入内存中
            }
        }
    } else {
        NSLog(@"从内存中取到图片");
    }
    
    if (image) {
        if (_managerSuccessBlock) {
            weakself.managerSuccessBlock(image, YES);
        }
        return nil;
    }
    
    
    // 创建downloader
    HYLWebImageDownLoader *downloader = [[HYLWebImageDownLoader alloc] initWithUrl:url withSuccess:^(UIImage *image, HYLWebImageDownLoader *loader) {
        
        // 下载结束删除，从下载队列删除当前downloader
        [weakself removeFromDownloaderQueue:loader];
        
        // 检查条件：max和preDownloaderQueue
        [weakself inspectPreDownloaderQueue];
        
        // 将图片保存到内存和本地
        if (image) {
            [HYLWebImageCache saveImageToMemory:image forKey:key];
            [HYLWebImageCache saveImageToLocalStorage:image forKey:key];
        }
        
        if (weakself.managerSuccessBlock) {
            weakself.managerSuccessBlock(image, NO);
        }
        
    } withFailure:^(NSError *error) {
        
        if (weakself.managerFailureBlock) {
            weakself.managerFailureBlock(error);
        }
        
    }];
    
    // 加入到下载队列中
    [self putDownloaderInQueue:downloader];
    
    return downloader;
}

// 放入下载队列
- (void)putDownloaderInQueue:(HYLWebImageDownLoader *)downloader {
    if (self.downloaderQueue.count >= _maxCount) {
        [self.preDownloaderQueue addObject:downloader];
        NSLog(@"超过maxCount，移入预下载队列 %d  线程:%@", (int)self.preDownloaderQueue.count, [NSThread currentThread]);
    } else {
        [self.downloaderQueue addObject:downloader];
        [downloader.task resume];
        NSLog(@"加入下载队列，开始下载 %d  线程:%@", (int)self.downloaderQueue.count, [NSThread currentThread]);
    }
}

// 从下载队列删除
- (void)removeFromDownloaderQueue:(HYLWebImageDownLoader *)downloader {
    if (downloader == nil) {
        return;
    }
    if ([self.downloaderQueue containsObject:downloader]) {
        [self.downloaderQueue removeObject:downloader];
        [downloader.task cancel]; // 假如正在下载，则取消
        downloader = nil;
    }
}

// 从预下载队列删除
- (void)removeFromPreDownloaderQueue:(HYLWebImageDownLoader *)downloader {
    if (downloader == nil) {
        return;
    }
    if ([self.preDownloaderQueue containsObject:downloader]) {
        [self.preDownloaderQueue removeObject:downloader];
        downloader = nil;
    }
}

// 检查条件：max和preDownloaderQueue
- (void)inspectPreDownloaderQueue {
    if (self.downloaderQueue.count < _maxCount && self.preDownloaderQueue.count > 0) {
        HYLWebImageDownLoader *downloader = [self.preDownloaderQueue firstObject];
        [self.preDownloaderQueue removeObjectAtIndex:0];
        [self putDownloaderInQueue:downloader];
        NSLog(@"从预下载队列移入下载队列");
    }
}

- (void)removeDownloader:(HYLWebImageDownLoader *)downloader {
    if (downloader == nil) {
        return;
    }
    [self removeFromDownloaderQueue:downloader];
    [self removeFromPreDownloaderQueue:downloader];
}

#pragma mark - MD5 加密工具
- (NSString *)stringToMD5:(NSString *)str{
    //1.首先将字符串转换成UTF-8编码，因为MD5加密是基于C语言的，要把字符串转成C的字符串
    const char * fooData = [str UTF8String];
    //2.然后创建一个字符串数组，接收MD5的值
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //3.计算MD5的值，这是官方封装好的加密方法，把我们输入的字符串转换成16进制的32位数，然后存储到result
    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    /*
     第一个参数，要加密的字符串
     第二个参数，获取加密字符串额长度
     第三个参数 接收结果的数组
     */
    //4.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    //5.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i <CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x",result[i]];
    }
    return  saveResult;
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


#pragma mark - lazyload
- (NSMutableArray *)downloaderQueue {
    if (_downloaderQueue == nil) {
        _downloaderQueue = [NSMutableArray array];
    }
    return _downloaderQueue;
}

- (NSMutableArray *)preDownloaderQueue {
    if (_preDownloaderQueue == nil) {
        _preDownloaderQueue = [NSMutableArray array];
    }
    return _preDownloaderQueue;
}

@end
