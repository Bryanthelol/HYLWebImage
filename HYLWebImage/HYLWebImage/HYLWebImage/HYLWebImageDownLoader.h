//
//  HYLWebImageDownLoader.h
//  HYLWebImage
//
//  Created by 何玉龙 on 2018/7/28.
//  Copyright © 2018 BryantStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYLWebImageDownLoader : NSObject

typedef void(^DownloadSuccess)(UIImage *image, HYLWebImageDownLoader *loader);
typedef void(^DownloadFailure)(NSError *error);


@property(nonatomic, strong) NSURLSessionTask *task;

/*
 * @prama url 图片的url
 * @prama successBlock 下载成功的回调
 * @prama failureBlock 下载失败的回调
 */
- (instancetype)initWithUrl:(NSString *)url withSuccess:(DownloadSuccess)successBlock withFailure:(DownloadFailure)failureBlock;



@end
