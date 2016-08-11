//
//  GCQiniuUploadManager.h
//  QiniuUploadManager
//
//  Created by 宫城 on 16/4/21.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^UploadProgressHandler)(float percent);
typedef void (^UploadDataCompletion)(NSError *error, NSString *link, NSInteger index);
typedef void (^UploadAllTasksCompletion)();

@interface GCQiniuUploadManager : NSObject

/**
 *  工作空间名称
 */
@property (nonatomic, strong) NSString *scope;
/**
 *  accessKey，可在七牛的密钥管理里查看
 */
@property (nonatomic, strong) NSString *accessKey;
/**
 *  secretKey，可在七牛的密钥管理里查看
 */
@property (nonatomic, strong) NSString *secretKey;
/**
 *  token有效时间，以天为单位，默认为5天
 */
@property (nonatomic, assign) NSInteger liveTime;
/**
 *  上传所需的token
 */
@property (nonatomic, strong) NSString *uploadToken;

+ (instancetype)sharedInstance;

- (void)registerWithScope:(NSString *)scrop
                accessKey:(NSString *)accessKey
                secretKey:(NSString *)secretKey;

- (void)registerWithScope:(NSString *)scrop
                accessKey:(NSString *)accessKey
                secretKey:(NSString *)secretKey
                 liveTime:(NSInteger)liveTime;

/**
 *  生成七牛token
 */
- (void)createToken;

/**
 *  上传单个数据
 *
 *  @param data       上传的数据
 *  @param progress   进度
 *  @param completion 完成回调
 */
- (void)uploadData:(NSData *)data
          progress:(UploadProgressHandler)progress
        completion:(UploadDataCompletion)completion;

/**
 *  上传多个数据
 *
 *  @param datas              上传的数据组
 *  @param progress           进度
 *  @param oneTaskCompletion  单个完成回调
 *  @param allTasksCompletion 全部完成回调
 */
- (void)uploadDatas:(NSArray<NSData *> *)datas
           progress:(UploadProgressHandler)progress
  oneTaskCompletion:(UploadDataCompletion)oneTaskCompletion
 allTasksCompletion:(UploadAllTasksCompletion)allTasksCompletion;

@end
