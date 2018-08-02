//
//  HYLWebImageDownLoader.m
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//


#import "HYLWebImageDownLoader.h"

#define dispatch_main_async_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface HYLWebImageDownLoader ()

@property(nonatomic, copy) DownloadSuccess downloadSuccessBlock;
@property(nonatomic, copy) DownloadFailure downloadFailureBlock;
@property(nonatomic, strong) NSString *urlStr;

@end

@implementation HYLWebImageDownLoader


- (instancetype)initWithUrl:(NSString *)url withSuccess:(DownloadSuccess)successBlock withFailure:(DownloadFailure)failureBlock {
    self = [super init];
    if (self) {
        _downloadSuccessBlock = successBlock;
        _downloadFailureBlock = failureBlock;
        
        //  #TODO 未校验是http还是https
        
        if (url && [url isKindOfClass:[NSString class]]) {
            _urlStr = (NSString *)url;
        } else {
            NSLog(@"传入的url错误");
            return nil;
        }
        
        [self donwloadNetworkRequest]; // 开始下载
    }
    return self;
}


/*
 * 下载图片
 */
- (void)donwloadNetworkRequest {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    
    __weak typeof (self) weakSelf = self;
    _task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSLog(@"下载图片结束");
        if (!error) {

            // 下载成功
            NSError *dataError = nil;
            NSData *data = [NSData dataWithContentsOfURL:location options:NSDataReadingMappedAlways error:&dataError];
            if (data || !dataError) {

                // 转换成功
                NSLog(@"图片转换成功 线程%@", [NSThread currentThread]);
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image && weakSelf.downloadSuccessBlock) {
                    dispatch_main_async_safe(^{
                        weakSelf.downloadSuccessBlock(image, weakSelf);
                    });
                }

            } else {

                // 转换失败
                NSLog(@"图片转换失败 原因：%@", dataError);
                if (weakSelf.downloadFailureBlock) {
                    dispatch_main_async_safe(^{
                        weakSelf.downloadFailureBlock(dataError);
                    });
                }
                return;

            }

        } else {

            // 下载失败
            NSLog(@"图片下载失败 原因：%@", error);
            if (weakSelf.downloadFailureBlock) {
                dispatch_main_async_safe(^{
                    weakSelf.downloadFailureBlock(error);
                });
            }
            return;

        }
    }];
}

@end
